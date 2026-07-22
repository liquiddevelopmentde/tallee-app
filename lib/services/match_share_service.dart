import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:json_schema/json_schema.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/services/share_exceptions.dart';

class MatchShareService {
  Future<String> getShareToken(Match match) async {
    try {
      final response = await http.post(
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
      // Wenn kein Internet oder Server down
      throw NetworkException();
    } on FormatException {
      // Wenn jsonDecode fehlschlägt
      throw ParsingException();
    }
  }

  Future<Match> getMatchByToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/v1/shares/$token'),
      );

      if (response.statusCode != 200) {
        throw ServerException(response.statusCode);
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      print(data['payload']);

      if (!data.containsKey('payload')) {
        throw ParsingException();
      }

      print(Match.fromJson(data['payload']));
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

  Future<void> shareMatchAsFile(Match match) async {
    String formattedMatchName = match.name.replaceAll(' ', '_');
    var filename = '$formattedMatchName.tallee';
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/$filename';
    File(path).writeAsString(jsonEncode(match));
    await SharePlus.instance.share(
      ShareParams(
        text: 'Here is the shared match "${match.name}"',
        title: 'Tallee Match Share',
        files: [XFile(path)],
      ),
    );
    //TODO: add locs
  }

  Future<void> saveMatchToCustomLocation(Match match) async {
    String formattedMatchName = match.name.replaceAll(' ', '_');
    var filename = '$formattedMatchName.tallee';

    String jsonString = jsonEncode(match.toJson());
    Uint8List fileBytes = utf8.encode(jsonString);

    await FilePicker.saveFile(
      dialogTitle: 'Choose where to save your match:',
      fileName: filename,
      bytes: fileBytes,
    );
    // TODO: add locs
  }

  /// Maps imported match data to local entities and saves it to the database.
  Future<void> saveImportedMatch({
    required AppDatabase db,
    required Match importedMatch,
    required Map<String, Player> playerAssociations,
    required Game? associatedGame,
    required Group? associatedGroup,
  }) async {
    // 1. Map players to local ones
    final localPlayers = importedMatch.players
        .map((p) => playerAssociations[p.id]!)
        .toList();

    // 2. Map scores to local player IDs
    final localScores = importedMatch.scores.map((
      importedPlayerId,
      scoreEntry,
    ) {
      final localPlayer = playerAssociations[importedPlayerId]!;
      return MapEntry(localPlayer.id, scoreEntry);
    });

    // 3. Map teams and their members to local ones
    final localTeams = importedMatch.teams?.map((team) {
      final teamMembers = team.members
          .map((m) => playerAssociations[m.id]!)
          .toList();
      return team.copyWith(members: teamMembers);
    }).toList();

    // 4. Ensure group exists
    Group? localGroup = associatedGroup;
    if (importedMatch.group != null && localGroup == null) {
      final newGroupMembers = importedMatch.group!.members
          .map((m) => playerAssociations[m.id]!)
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

    final localMatch = importedMatch.copyWith(
      game: localGame,
      players: localPlayers,
      scores: localScores,
      teams: localTeams,
      group: localGroup,
    );

    final success = await db.matchDao.addMatch(match: localMatch);
    if (!success) {
      throw MatchAlreadyExistsException();
    }
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

    try {
      final jsonString = await _readFileContent(path.files.single);
      if (jsonString == null) {
        return (ImportResult.fileReadError, null, path.files.single.name);
      }

      final isValid = await validateJsonSchema(jsonString);
      if (!isValid) {
        return (ImportResult.invalidSchema, null, path.files.single.name);
      }

      final decoded = json.decode(jsonString) as Map<String, dynamic>;

      if (!validateContent(decoded)) {
        return (ImportResult.invalidData, null, path.files.single.name);
      }

      return (
        ImportResult.success,
        Match.fromJson(decoded),
        path.files.single.name,
      );
    } on FormatException catch (e, stack) {
      print('[importData] FormatException');
      print('[importData] $e');
      print(stack);
      return (ImportResult.formatException, null, path.files.single.name);
    } on Exception catch (e, stack) {
      print('[importData] Exception');
      print('[importData] $e');
      print(stack);
      return (ImportResult.unknownException, null, path.files.single.name);
    }
  }

  /// Helper method to read file content from either bytes or path
  static Future<String?> _readFileContent(PlatformFile file) async {
    if (file.bytes != null) return utf8.decode(file.bytes!);
    if (file.path != null) return await File(file.path!).readAsString();
    return null;
  }

  /// Validates the given JSON string against the schema
  /// in `assets/app_schema.json`.
  @visibleForTesting
  static Future<bool> validateJsonSchema(String jsonString) async {
    final String schemaString;

    schemaString = await rootBundle.loadString('assets/match_schema.json');

    try {
      final schema = JsonSchema.create(json.decode(schemaString));
      final jsonData = json.decode(jsonString);
      final result = schema.validate(jsonData);

      if (result.isValid) {
        return true;
      }
      return false;
    } catch (e, stack) {
      print('[validateJsonSchema] $e');
      print(stack);
      return false;
    }
  }

  /// Validates field lengths against the defined constants.
  @visibleForTesting
  static bool validateContent(Map<String, dynamic> decoded) {
    // Validate match name
    final name = decoded['name'] as String?;
    if (name != null && name.length > Constants.MAX_MATCH_NAME_LENGTH) {
      return false;
    }

    // Validate teams
    final teams = decoded['teams'] as List<dynamic>?;
    if (teams != null) {
      for (final t in teams) {
        final teamName = t['name'] as String?;
        if (teamName != null &&
            teamName.length > Constants.MAX_TEAM_NAME_LENGTH) {
          return false;
        }
      }
    }

    return true;
  }
}
