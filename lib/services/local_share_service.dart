import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/services/remote_share_service.dart';
import 'package:tallee/services/shared_preferences_service.dart';

class LocalShareService {
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
      'players': players.map((player) => player.toNormalizedJson()).toList(),
      'groups': groups.map((group) => group.toNormalizedJson()).toList(),
      'games': games.map((game) => game.toJson()).toList(),
      'matches': matches.map((match) => match.toNormalizedJson()).toList(),
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
    if (status != ImportResult.success &&
        status != ImportResult.singleMatchDetected) {
      return (status, null);
    }

    return (status, jsonString);
  }

  /// Validates [jsonString] against the schema and the content length rules.
  ///
  /// Returns the decoded map on success, or an error status with a `null` map
  /// when validation fails or the JSON is malformed.
  static Future<(ImportResult, Map<String, dynamic>?)> _validateJson(
    String jsonString,
  ) async {
    try {
      final isValidAppSchema = await validateJsonSchema(
        jsonString,
        'assets/app_schema.json',
      );

      if (isValidAppSchema) {
        final decoded = json.decode(jsonString) as Map<String, dynamic>;

        if (!validateContent(decoded)) {
          return (ImportResult.invalidData, null);
        }

        return (ImportResult.success, decoded);
      }

      // Check if it's a single match
      final isValidMatchSchema = await validateJsonSchema(
        jsonString,
        'assets/match_schema.json',
      );

      if (isValidMatchSchema) {
        final decoded = json.decode(jsonString) as Map<String, dynamic>;

        if (!RemoteShareService.validateContent(decoded)) {
          return (ImportResult.invalidData, null);
        }

        return (ImportResult.singleMatchDetected, null);
      }

      return (ImportResult.invalidSchema, null);
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

  /// Validates field lengths against the defined constants.
  @visibleForTesting
  static bool validateContent(Map<String, dynamic> decoded) {
    // Validate players
    final players = decoded['players'] as List<dynamic>? ?? [];
    for (final p in players) {
      final name = p['name'] as String?;
      if (name != null && name.length > Constants.MAX_PLAYER_NAME_LENGTH) {
        return false;
      }
    }

    // Validate games
    final games = decoded['games'] as List<dynamic>? ?? [];
    for (final g in games) {
      final name = g['name'] as String?;
      if (name != null && name.length > Constants.MAX_GAME_NAME_LENGTH) {
        return false;
      }
      final desc = g['description'] as String?;
      if (desc != null && desc.length > Constants.MAX_GAME_DESCRIPTION_LENGTH) {
        return false;
      }
    }

    // Validate groups
    final groups = decoded['groups'] as List<dynamic>? ?? [];
    for (final g in groups) {
      final name = g['name'] as String?;
      if (name != null && name.length > Constants.MAX_GROUP_NAME_LENGTH) {
        return false;
      }
    }

    // Validate matches and teams
    final matches = decoded['matches'] as List<dynamic>? ?? [];
    for (final m in matches) {
      final name = m['name'] as String?;
      if (name != null && name.length > Constants.MAX_MATCH_NAME_LENGTH) {
        return false;
      }

      final teams = m['teams'] as List<dynamic>? ?? [];
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

    // Wrap the entire import in a single transaction to ensure atomicity
    // and prevent foreign key constraint violations due to intermediate states.
    print('[importDataToDatabase] START');
    await db.transaction(() async {
      // Order is important for foreign key constraints:
      // 1. Games & Players (no dependencies)
      print('[importDataToDatabase] adding games');
      await db.gameDao.addGamesAsList(games: importedGames);
      print('[importDataToDatabase] added games');

      print('[importDataToDatabase] adding players');
      await db.playerDao.addPlayersAsList(players: importedPlayers);
      print('[importDataToDatabase] added players');

      // 2. Groups (depend on players)
      print('[importDataToDatabase] adding groups');
      await db.groupDao.addGroupsAsList(groups: importedGroups);
      print('[importDataToDatabase] added groups');

      // 3. Matches (now handles its own games/players/groups internally but safely)
      print('[importDataToDatabase] adding matches');
      await db.matchDao.addMatchesAsList(matches: importedMatches);
      print('[importDataToDatabase] added matches');

      // 4. Statistics (depend on games and groups)
      print('[importDataToDatabase] adding statistics');
      await db.statisticDao.addStatisticsAsList(statistics: importedStats);
      print('[importDataToDatabase] added statistics');
    });
    print('[importDataToDatabase] END');
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

      // Ignore invalid member IDs (missing players) instead of throwing
      final members = memberIds
          .map((id) => playerById[id])
          .where((p) => p != null)
          .cast<Player>()
          .toList();

      return Group.fromNormalizedJson(map, members);
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

      // Ignore invalid member IDs (missing players) instead of throwing
      final members = memberIds
          .map((id) => playerById[id])
          .where((p) => p != null)
          .cast<Player>()
          .toList();

      return Team.fromNormalizedJson(map, members);
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

      final gameId = map['gameId'] as String;
      final groupId = map['groupId'] as String?;
      final playerIds = (map['playerIds'] as List<dynamic>? ?? [])
          .cast<String>();
      final teamsJson = (map['teams'] as List<dynamic>?) ?? [];

      final game = gamesMap[gameId];
      if (game == null) {
        throw ArgumentError('Game with ID $gameId not found in import data');
      }

      final group = groupId != null ? groupsMap[groupId] : null;
      if (groupId != null && group == null) {
        throw ArgumentError('Group with ID $groupId not found in import data');
      }

      final players = playerIds.map((id) {
        final player = playersMap[id];
        if (player == null) {
          throw ArgumentError('Player with ID $id not found in import data');
        }
        return player;
      }).toList();
      final teams = parseTeamsFromJson(teamsJson, playersMap);

      return Match.fromNormalizedJson(
        map,
        game: game,
        group: group,
        players: players,
        teams: teams.isEmpty ? null : teams,
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

      // Ignore invalid selected game/group IDs instead of throwing
      final selectedGames = selectedGameIds
          .map((id) => gamesMap[id])
          .where((g) => g != null)
          .cast<Game>()
          .toList();

      final selectedGroups = selectedGroupIds
          .map((id) => groupsMap[id])
          .where((g) => g != null)
          .cast<Group>()
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
}
