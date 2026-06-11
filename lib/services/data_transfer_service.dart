import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_schema/json_schema.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';
import 'package:tallee/data/models/team.dart';

class DataTransferService {
  /// Deletes all data from the database.
  static Future<void> deleteAllData(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);

    await db.statisticDao.deleteAllStatistics();
    await db.matchDao.deleteAllMatches();
    await db.teamDao.deleteAllTeams();
    await db.groupDao.deleteAllGroups();
    await db.gameDao.deleteAllGames();
    await db.playerDao.deleteAllPlayers();
  }

  /// Retrieves all application data and converts it to a JSON string.
  /// Returns the JSON string representation of the data in normalized format.
  static Future<String> getAppDataAsJson(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final matches = await db.matchDao.getAllMatches();
    final groups = await db.groupDao.getAllGroups();
    final players = await db.playerDao.getAllPlayers();
    final games = await db.gameDao.getAllGames();

    final Map<String, dynamic> jsonMap = {
      'players': players.map((player) => player.toJson()).toList(),
      'games': games.map((game) => game.toJson()).toList(),
      'groups': groups.map((group) => group.toJson()).toList(),
      'matches': matches.map((match) => match.toJson()).toList(),
    };

    return json.encode(jsonMap);
  }

  /// Exports the given JSON string to a file with the specified name.
  /// Returns an [ExportResult] indicating the outcome.
  ///
  /// - [jsonString]: The JSON string to be exported.
  /// - [fileName]:  The desired name for the exported file (without extension).
  static Future<ExportResult> exportData(
    String jsonString,
    String fileName,
  ) async {
    try {
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      final path = await FilePicker.saveFile(
        fileName: '$fileName.json',
        bytes: bytes,
      );

      if (path == null) {
        return ExportResult.canceled;
      } else {
        return ExportResult.success;
      }
    } catch (e, stack) {
      print('[exportData] $e');
      print(stack);
      return ExportResult.unknownException;
    }
  }

  /// Imports data from a selected JSON file into the database.
  static Future<ImportResult> importData(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);

    final path = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (path == null) {
      return ImportResult.canceled;
    }

    try {
      final jsonString = await _readFileContent(path.files.single);
      if (jsonString == null) return ImportResult.fileReadError;

      final isValid = await validateJsonSchema(jsonString);
      if (!isValid) return ImportResult.invalidSchema;

      final decoded = json.decode(jsonString) as Map<String, dynamic>;

      if (!validateContent(decoded)) {
        return ImportResult.invalidData;
      }

      await importDataToDatabase(db, decoded);

      return ImportResult.success;
    } on FormatException catch (e, stack) {
      print('[importData] FormatException');
      print('[importData] $e');
      print(stack);
      return ImportResult.formatException;
    } on Exception catch (e, stack) {
      print('[importData] Exception');
      print('[importData] $e');
      print(stack);
      return ImportResult.unknownException;
    }
  }

  /// Überprüft die Längen der Felder gegen die definierten Constants.
  @visibleForTesting
  static bool validateContent(Map<String, dynamic> decoded) {
    // Spieler validieren
    final players = decoded['players'] as List<dynamic>? ?? [];
    for (final p in players) {
      final name = p['name'] as String?;
      if (name != null && name.length > Constants.MAX_PLAYER_NAME_LENGTH)
        return false;
    }

    // Spiele validieren
    final games = decoded['games'] as List<dynamic>? ?? [];
    for (final g in games) {
      final name = g['name'] as String?;
      if (name != null && name.length > Constants.MAX_GAME_NAME_LENGTH)
        return false;
      final desc = g['description'] as String?;
      if (desc != null && desc.length > Constants.MAX_GAME_DESCRIPTION_LENGTH)
        return false;
    }

    // Gruppen validieren
    final groups = decoded['groups'] as List<dynamic>? ?? [];
    for (final g in groups) {
      final name = g['name'] as String?;
      if (name != null && name.length > Constants.MAX_GROUP_NAME_LENGTH)
        return false;
    }

    // Matches und Teams validieren
    final matches = decoded['matches'] as List<dynamic>? ?? [];
    for (final m in matches) {
      final name = m['name'] as String?;
      if (name != null && name.length > Constants.MAX_MATCH_NAME_LENGTH)
        return false;

      final teams = m['teams'] as List<dynamic>? ?? [];
      for (final t in teams) {
        final teamName = t['name'] as String?;
        if (teamName != null &&
            teamName.length > Constants.MAX_TEAM_NAME_LENGTH)
          return false;
      }
    }

    return true;
  }

  /// Imports parsed JSON data into the database.
  @visibleForTesting
  static Future<void> importDataToDatabase(
    AppDatabase db,
    Map<String, dynamic> decodedJson,
  ) async {
    // Fetch all entities first to create lookup maps for relationships
    final importedPlayers = parsePlayersFromJson(decodedJson);
    final playerById = {for (final p in importedPlayers) p.id: p};

    final importedGames = parseGamesFromJson(decodedJson);
    final gameById = {for (final g in importedGames) g.id: g};

    final importedGroups = parseGroupsFromJson(decodedJson, playerById);
    final groupById = {for (final g in importedGroups) g.id: g};

    final importedMatches = parseMatchesFromJson(
      decodedJson,
      gameById,
      groupById,
      playerById,
    );

    await db.playerDao.addPlayersAsList(players: importedPlayers);
    await db.gameDao.addGamesAsList(games: importedGames);
    await db.groupDao.addGroupsAsList(groups: importedGroups);
    await db.matchDao.addMatchesAsList(matches: importedMatches);
  }

  /* Parsing Methods */

  @visibleForTesting
  static List<Player> parsePlayersFromJson(Map<String, dynamic> decodedJson) {
    final playersJson = (decodedJson['players'] as List<dynamic>?) ?? [];
    return playersJson
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  @visibleForTesting
  static List<Game> parseGamesFromJson(Map<String, dynamic> decodedJson) {
    final gamesJson = (decodedJson['games'] as List<dynamic>?) ?? [];
    return gamesJson
        .map((g) => Game.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  @visibleForTesting
  static List<Group> parseGroupsFromJson(
    Map<String, dynamic> decodedJson,
    Map<String, Player> playerById,
  ) {
    final groupsJson = (decodedJson['groups'] as List<dynamic>?) ?? [];
    return groupsJson.map((g) {
      final map = g as Map<String, dynamic>;
      final memberIds = (map['memberIds'] as List<dynamic>? ?? [])
          .cast<String>();

      final members = memberIds
          .map((id) => playerById[id])
          .whereType<Player>()
          .toList();

      return Group(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        members: members,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    }).toList();
  }

  /// Parses teams from a list of JSON objects.
  @visibleForTesting
  static List<Team> parseTeamsFromJson(
    List<dynamic> teamsJson,
    Map<String, Player> playerById,
  ) {
    return teamsJson.map((t) {
      final map = t as Map<String, dynamic>;
      final memberIds = (map['memberIds'] as List<dynamic>? ?? [])
          .cast<String>();

      final members = memberIds
          .map((id) => playerById[id])
          .whereType<Player>()
          .toList();
      final team = Team.fromJson(map);

      return team.copyWith(members: members);
    }).toList();
  }

  /// Parses matches from JSON data.
  @visibleForTesting
  static List<Match> parseMatchesFromJson(
    Map<String, dynamic> decodedJson,
    Map<String, Game> gamesMap,
    Map<String, Group> groupsMap,
    Map<String, Player> playersMap,
  ) {
    final matchesJson = (decodedJson['matches'] as List<dynamic>?) ?? [];
    return matchesJson.map((m) {
      final map = m as Map<String, dynamic>;

      // Extract attributes from json
      final id = map['id'] as String;
      final name = map['name'] as String;
      final gameId = map['gameId'] as String;
      final groupId = map['groupId'] as String?;
      final createdAt = DateTime.parse(map['createdAt'] as String);
      final endedAt = map['endedAt'] != null
          ? DateTime.parse(map['endedAt'] as String)
          : null;
      final isTeamMatch = map['isTeamMatch'] as bool;
      final notes = map['notes'] as String? ?? '';
      final scoresJson = map['scores'] as Map<String, dynamic>? ?? {};
      final scores = scoresJson.map(
        (key, value) => MapEntry(
          key,
          value != null
              ? ScoreEntry.fromJson(value as Map<String, dynamic>)
              : null,
        ),
      );

      // Link attributes to objects
      final game = gamesMap[gameId] ?? getFallbackGame();
      final group = groupId != null ? groupsMap[groupId] : null;

      final playerIds = (map['playerIds'] as List<dynamic>? ?? [])
          .cast<String>();
      final players = playerIds
          .map((id) => playersMap[id])
          .whereType<Player>()
          .toList();

      final teamsJson = (map['teams'] as List<dynamic>?) ?? [];
      final teams = parseTeamsFromJson(teamsJson, playersMap);

      return Match(
        id: id,
        name: name,
        game: game,
        group: group,
        players: players,
        isTeamMatch: isTeamMatch,
        teams: teams.isEmpty ? null : teams,
        createdAt: createdAt,
        endedAt: endedAt,
        notes: notes,
        scores: scores,
      );
    }).toList();
  }

  /// Creates a fallback game when the referenced game is not found.
  @visibleForTesting
  static Game getFallbackGame() {
    return Game(
      name: 'Unknown',
      ruleset: Ruleset.singleWinner,
      description: '',
      color: AppColor.blue,
      icon: '',
    );
  }

  /// Helper method to read file content from either bytes or path
  static Future<String?> _readFileContent(PlatformFile file) async {
    if (file.bytes != null) return utf8.decode(file.bytes!);
    if (file.path != null) return await File(file.path!).readAsString();
    return null;
  }

  /// Validates the given JSON string against the schema
  /// in `assets/schema.json`.
  @visibleForTesting
  static Future<bool> validateJsonSchema(String jsonString) async {
    final String schemaString;

    schemaString = await rootBundle.loadString('assets/schema.json');

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
}
