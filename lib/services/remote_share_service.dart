import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/share_exceptions.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:uuid/uuid.dart';

class RemoteShareService {
  final http.Client httpClient;

  RemoteShareService({http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  Future<String> getShareToken(Match match) async {
    try {
      final response = await httpClient.post(
        Uri.parse('${getApiBaseUrl()}/v1/shares/'),
        body: jsonEncode(match.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 201) {
        throw ServerException(response.statusCode);
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey('token')) {
        throw ParsingException();
      }

      return data['token'] as String;
    } on SocketException {
      // No internet connection or server down
      throw NetworkException();
    } on FormatException {
      //jsonDecode fails
      throw ParsingException();
    }
  }

  Future<Match> getMatchByToken(String token) async {
    try {
      final response = await httpClient.get(
        Uri.parse('${getApiBaseUrl()}/v1/shares/$token'),
      );

      if (response.statusCode != 200) {
        throw ServerException(response.statusCode);
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey('payload')) {
        throw ParsingException();
      }

      return Match.fromJson(data['payload']);
    } on SocketException catch (e) {
      print(e);
      print(e.message);
      throw NetworkException();
    } on FormatException {
      throw ParsingException();
    } on NetworkException catch (e) {
      print(e);
      throw NetworkException();
    }
  }

  String getApiBaseUrl() {
    if (kDebugMode) {
      return Platform.isAndroid
          ? dotenv.get('DEV_ANDROID_API_URL')
          : dotenv.get('DEV_IOS_API_URL');
    } else {
      return dotenv.get('PROD_API_URL');
    }
  }

  Future<void> shareMatchAsFile(
    Match match, {
    required String text,
    required String title,
  }) async {
    String formattedMatchName = match.name.toSafeFilename();
    var filename = '$formattedMatchName.tallee';
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/$filename';
    File(path).writeAsString(jsonEncode(match));
    await SharePlus.instance.share(
      ShareParams(text: text, title: title, files: [XFile(path)]),
    );
  }

  Future<void> saveMatchToCustomLocation(
    Match match, {
    required String dialogTitle,
  }) async {
    String formattedMatchName = match.name.toSafeFilename();
    var filename = '$formattedMatchName.tallee';

    String jsonString = jsonEncode(match.toJson());
    Uint8List fileBytes = utf8.encode(jsonString);

    await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: filename,
      bytes: fileBytes,
    );
  }

  /// Parses and validates a match JSON string against schemas and content rules.
  Future<(ImportResult, Match?, String)> parseAndValidateMatch(
    String jsonString,
    String fileName,
  ) async {
    try {
      final isValid = await validateJsonSchema(
        jsonString,
        'assets/match_schema.json',
      );
      if (!isValid) {
        return (ImportResult.invalidSchema, null, fileName);
      }

      final decoded = json.decode(jsonString) as Map<String, dynamic>;

      if (!validateContent(decoded)) {
        return (ImportResult.invalidData, null, fileName);
      }

      return (ImportResult.success, Match.fromJson(decoded), fileName);
    } on FormatException catch (e, stack) {
      print('[parseAndValidateMatch] FormatException');
      print('[parseAndValidateMatch] $e');
      print(stack);
      return (ImportResult.formatException, null, fileName);
    } on Exception catch (e, stack) {
      print('[parseAndValidateMatch] Exception');
      print('[parseAndValidateMatch] $e');
      print(stack);
      return (ImportResult.unknownException, null, fileName);
    }
  }

  /// Loads a match from a given file path without opening a file picker.
  Future<(ImportResult, Match?, String)> loadMatchFromFile(
    String filePath,
  ) async {
    final file = File(filePath);

    try {
      final jsonString = await file.readAsString();
      return await parseAndValidateMatch(jsonString, filePath);
    } on Exception catch (e, stack) {
      print('[loadMatchFromFile] Exception reading file');
      print('[loadMatchFromFile] $e');
      print(stack);
      return (ImportResult.fileReadError, null, filePath);
    }
  }

  /// Maps imported match data to local entities and saves it to the database.
  Future<Match> saveImportedMatch({
    required AppDatabase db,
    required Match importedMatch,
    required Map<String, Player> playerAssociations,
    required Game? associatedGame,
    required Group? associatedGroup,
  }) async {
    // Helper to get local player or fall back to imported one if missing
    Player getLocalPlayer(Player imported) =>
        playerAssociations[imported.id] ?? imported;

    // 1. Map players to local ones
    final localPlayers = importedMatch.players.map(getLocalPlayer).toList();

    // 2. Map scores to local player IDs
    final localScores = importedMatch.scores.map((
      importedPlayerId,
      scoreEntry,
    ) {
      final localPlayer = playerAssociations[importedPlayerId];
      if (localPlayer == null) {
        return MapEntry(importedPlayerId, scoreEntry);
      }
      return MapEntry(localPlayer.id, scoreEntry);
    });

    // 3. Map teams and their members to local ones
    final localTeams = importedMatch.teams?.map((team) {
      final teamMembers = team.members.map(getLocalPlayer).toList();
      return team.copyWith(members: teamMembers);
    }).toList();

    // 4. Ensure group exists
    Group? localGroup = associatedGroup;
    if (importedMatch.group != null && localGroup == null) {
      final newGroupMembers = importedMatch.group!.members
          .map(getLocalPlayer)
          .toList();
      localGroup = Group(
        name: importedMatch.group!.name,
        description: importedMatch.group!.description,
        members: newGroupMembers,
      );
      await db.groupDao.addGroup(group: localGroup);
    }

    // 5. Ensure game exists
    Game localGame = associatedGame ?? importedMatch.game;
    if (associatedGame == null) {
      // Create new game if not associated with an existing one
      await db.gameDao.addGame(game: localGame);
    }

    // 6. Ensure all players (mapped and new) exist in the database
    // This handles players from the match list, teams, and groups.
    final allMappedPlayers = {
      ...localPlayers,
      if (localGroup != null) ...localGroup.members,
      if (localTeams != null) ...localTeams.expand((t) => t.members),
    }.toList();

    await db.playerDao.addPlayersAsList(players: allMappedPlayers);

    final localMatch = importedMatch.copyWith(
      id: const Uuid().v4(),
      game: localGame,
      players: localPlayers,
      scores: localScores,
      teams: localTeams,
      group: localGroup,
    );

    await db.matchDao.addMatch(match: localMatch);
    return localMatch;
  }

  Future<(ImportResult, Match?, String)> chooseFileToImport() async {
    final path = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['tallee'],
    );

    if (path == null || path.files.isEmpty) {
      return (ImportResult.canceled, null, '');
    }

    final file = path.files.single;
    final jsonString = await readFileContent(file);
    final filePath = file.path ?? file.name;
    if (jsonString == null) {
      return (ImportResult.fileReadError, null, filePath);
    }

    return await parseAndValidateMatch(jsonString, filePath);
  }

  /// Validates field lengths against the defined constants.
  static bool validateContent(Map<String, dynamic> decoded) {
    // Validate match name
    final name = decoded['name'] as String?;
    if (name != null && name.length > MAX_MATCH_NAME_LENGTH) {
      return false;
    }

    // Validate game
    final game = decoded['game'] as Map<String, dynamic>?;
    if (game != null) {
      final gameName = game['name'] as String?;
      if (gameName != null && gameName.length > MAX_GAME_NAME_LENGTH) {
        return false;
      }
      final gameDesc = game['description'] as String?;
      if (gameDesc != null && gameDesc.length > MAX_GAME_DESCRIPTION_LENGTH) {
        return false;
      }
    }

    // Validate players
    final players = decoded['players'] as List<dynamic>?;
    if (players != null) {
      for (final p in players) {
        final playerName = p['name'] as String?;
        if (playerName != null && playerName.length > MAX_PLAYER_NAME_LENGTH) {
          return false;
        }
      }
    }

    // Validate group
    final group = decoded['group'] as Map<String, dynamic>?;
    if (group != null) {
      final groupName = group['name'] as String?;
      if (groupName != null && groupName.length > MAX_GROUP_NAME_LENGTH) {
        return false;
      }
    }

    // Validate teams
    final teams = decoded['teams'] as List<dynamic>?;
    if (teams != null) {
      for (final t in teams) {
        final teamName = t['name'] as String?;
        if (teamName != null && teamName.length > MAX_TEAM_NAME_LENGTH) {
          return false;
        }
      }
    }

    return true;
  }
}
