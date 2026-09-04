import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_schema/json_schema.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/services/shared_preferences_service.dart';

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
    SharedPreferencesService.deleteAllFilters(includeFavourites: true);
  }

  /// Retrieves all application data and converts it to a JSON string.
  /// Returns the JSON string representation of the data in normalized format.
  static Future<String> getAppDataAsJson(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);

    final matches = await db.matchDao.getAllMatches(includeDeletedPlayer: true);
    final groups = await db.groupDao.getAllGroups();
    final players = await db.playerDao.getAllPlayers(
      includeDeletedPlayer: true,
    );
    final games = await db.gameDao.getAllGames();
    final statistics = await db.statisticDao.getAllStatistics();

    if (matches.isEmpty &&
        groups.isEmpty &&
        players.isEmpty &&
        games.isEmpty &&
        statistics.isEmpty) {
      return '';
    }

    final Map<String, dynamic> jsonMap = {
      'players': players.map((player) => player.toJson()).toList(),
      'groups': groups.map((group) => group.toJson()).toList(),
      'games': games.map((game) => game.toJson()).toList(),
      'matches': matches.map((match) => match.toJson()).toList(),
      'statistics': statistics.map((stat) => stat.toJson()).toList(),
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
        fileName: '$fileName.tallee',
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

  /// Opens the file picker and returns the path of the selected `.tallee`
  /// file, or `null` if the picker was cancelled or no path is available.
  static Future<String?> pickImportFilePath() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['tallee'],
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    return result.files.single.path;
  }

  /// Reads and validates a .tallee file at [filePath].
  /// Returns `(ImportResult, jsonString)`.
  /// If validation fails, `jsonString` is `null`.
  static Future<(ImportResult, String?)> getDataFromPath(
    String filePath,
  ) async {
    final file = File(filePath);
    final exists = await file.exists();
    if (!exists) {
      return (ImportResult.fileNotFound, null);
    }

    final String jsonString;
    try {
      jsonString = await file.readAsString();
    } on Exception catch (e, stack) {
      print('[getDataFromPath] Failed to read file');
      print('[getDataFromPath] $e');
      print(stack);
      return (ImportResult.fileReadError, null);
    }

    final (status, _) = await _validateJson(jsonString);
    if (status != ImportResult.success) {
      return (status, null);
    }

    return (ImportResult.success, jsonString);
  }

  /// Validates [jsonString] against the schema and the content length rules.
  ///
  /// Returns the decoded map on success, or an error status with a `null` map
  /// when validation fails or the JSON is malformed.
  static Future<(ImportResult, Map<String, dynamic>?)> _validateJson(
    String jsonString,
  ) async {
    try {
      final isValid = await validateJsonSchema(jsonString);
      if (!isValid) return (ImportResult.invalidSchema, null);

      final decoded = json.decode(jsonString) as Map<String, dynamic>;

      if (!validateContent(decoded)) {
        return (ImportResult.invalidData, null);
      }

      return (ImportResult.success, decoded);
    } on FormatException catch (e, stack) {
      print('[validateJson] FormatException');
      print('[validateJson] $e');
      print(stack);
      return (ImportResult.formatException, null);
    } on Exception catch (e, stack) {
      print('[validateJson] Exception');
      print('[validateJson] $e');
      print(stack);
      return (ImportResult.unknownException, null);
    }
  }

  /// Validates the given [jsonString] and writes its content to the database.
  static Future<ImportResult> commitImport(
    AppDatabase db,
    String jsonString,
  ) async {
    final (status, decoded) = await _validateJson(jsonString);
    if (status != ImportResult.success || decoded == null) {
      return status;
    }

    try {
      await importDataToDatabase(db, decoded);
      return ImportResult.success;
    } on Exception catch (e, stack) {
      print('[commitImport] Failed to write data');
      print('[commitImport] $e');
      print(stack);
      return ImportResult.unknownException;
    }
  }

  /// Validates field lengths against the defined
  @visibleForTesting
  static bool validateContent(Map<String, dynamic> decoded) {
    // Validate players
    final players = decoded['players'] as List<dynamic>? ?? [];
    for (final p in players) {
      final name = p['name'] as String?;
      if (name != null && name.length > MAX_PLAYER_NAME_LENGTH) {
        return false;
      }
    }

    // Validate games
    final games = decoded['games'] as List<dynamic>? ?? [];
    for (final g in games) {
      final name = g['name'] as String?;
      if (name != null && name.length > MAX_GAME_NAME_LENGTH) {
        return false;
      }
      final desc = g['description'] as String?;
      if (desc != null && desc.length > MAX_GAME_DESCRIPTION_LENGTH) {
        return false;
      }
    }

    // Validate groups
    final groups = decoded['groups'] as List<dynamic>? ?? [];
    for (final g in groups) {
      final name = g['name'] as String?;
      if (name != null && name.length > MAX_GROUP_NAME_LENGTH) {
        return false;
      }
    }

    // Validate matches and teams
    final matches = decoded['matches'] as List<dynamic>? ?? [];
    for (final m in matches) {
      final name = m['name'] as String?;
      if (name != null && name.length > MAX_MATCH_NAME_LENGTH) {
        return false;
      }

      final teams = m['teams'] as List<dynamic>? ?? [];
      for (final t in teams) {
        final teamName = t['name'] as String?;
        if (teamName != null && teamName.length > MAX_TEAM_NAME_LENGTH) {
          return false;
        }
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

    final importedStats = parseStatsFromJson(decodedJson, gameById, groupById);

    await db.playerDao.addPlayersAsList(players: importedPlayers);
    await db.gameDao.addGamesAsList(games: importedGames);
    await db.groupDao.addGroupsAsList(groups: importedGroups);
    await db.matchDao.addMatchesAsList(matches: importedMatches);
    await db.statisticDao.addStatisticsAsList(statistics: importedStats);
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

      // Drop score entries that reference players which are not part of the
      // imported data. This keeps referential integrity and prevents foreign
      // key violations when importing inconsistent or legacy files.
      scores.removeWhere((playerId, _) => !playersMap.containsKey(playerId));

      // Link attributes to objects
      final game = ArgumentError.checkNotNull(
        gamesMap[gameId],
        'game for id $gameId',
      );
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

  /// Parses statistics from JSON data.
  @visibleForTesting
  static List<Statistic> parseStatsFromJson(
    Map<String, dynamic> decodedJson,
    Map<String, Game> gamesMap,
    Map<String, Group> groupsMap,
  ) {
    final statsJson = (decodedJson['statistics'] as List<dynamic>?) ?? [];
    return statsJson.map((s) {
      final map = s as Map<String, dynamic>;

      final selectedGameIds = (map['selectedGames'] as List<dynamic>? ?? [])
          .cast<String>();
      final selectedGroupIds = (map['selectedGroups'] as List<dynamic>? ?? [])
          .cast<String>();

      final selectedGames = selectedGameIds
          .map((id) => gamesMap[id])
          .whereType<Game>()
          .toList();
      final selectedGroups = selectedGroupIds
          .map((id) => groupsMap[id])
          .whereType<Group>()
          .toList();

      return Statistic(
        id: map['id'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        startDate: map['startDate'] != null
            ? DateTime.parse(map['startDate'] as String)
            : null,
        endDate: map['endDate'] != null
            ? DateTime.parse(map['endDate'] as String)
            : null,
        type: StatisticType.values.firstWhere(
          (e) => e.name == map['type'] || e.toString() == map['type'],
          orElse: () => StatisticType.totalWins,
        ),
        scopes: (map['scopes'] as List<dynamic>? ?? [])
            .map(
              (scope) => StatisticScope.values.firstWhere(
                (e) => e.name == scope || e.toString() == scope,
                orElse: () => StatisticScope.allPlayers,
              ),
            )
            .toList(),
        timeframe: Timeframe.values.firstWhere(
          (e) => e.name == map['timeframe'] || e.toString() == map['timeframe'],
          orElse: () => Timeframe.allTime,
        ),
        color: AppColor.values.firstWhere(
          (e) => e.name == map['color'] || e.toString() == map['color'],
          orElse: () => AppColor.orange,
        ),
        selectedGroups: selectedGroups.isEmpty ? null : selectedGroups,
        selectedGames: selectedGames.isEmpty ? null : selectedGames,
        displayCount: map['displayCount'],
        isFavourite: map['isFavourite'],
        position: map['position'],
      );
    }).toList();
  }

  /// Helper method to read file content from either bytes or path
  @visibleForTesting
  static Future<String?> readFileContent(PlatformFile file) async {
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
