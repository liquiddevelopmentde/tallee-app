import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_schema/json_schema.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';

class DataTransferService {
  /// Deletes all data from the database.
  static Future<void> deleteAllData(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.matchDao.deleteAllMatches();
    await db.groupDao.deleteAllGroups();
    await db.playerDao.deleteAllPlayers();
  }

  /// Retrieves all application data and converts it to a JSON string.
  /// Returns the JSON string representation of the data.
  static Future<String> getAppDataAsJson(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final matches = await db.matchDao.getAllMatches();
    final groups = await db.groupDao.getAllGroups();
    final players = await db.playerDao.getAllPlayers();

    // Construct a JSON representation of the data
    final Map<String, dynamic> jsonMap = {
      'players': players.map((p) => p.toJson()).toList(),

      'groups': groups
          .map(
            (g) => {
              'id': g.id,
              'name': g.name,
              'createdAt': g.createdAt.toIso8601String(),
              'memberIds': (g.members).map((m) => m.id).toList(),
            },
          )
          .toList(),

      'matches': matches
          .map(
            (m) => {
              'id': m.id,
              'name': m.name,
              'createdAt': m.createdAt.toIso8601String(),
              'groupId': m.group?.id,
              'playerIds': (m.players ?? []).map((p) => p.id).toList(),
              'winnerId': m.winner?.id,
            },
          )
          .toList(),
    };

    return json.encode(jsonMap);
  }

  /// Exports the given JSON string to a file with the specified name.
  /// Returns an [ExportResult] indicating the outcome.
  ///
  /// [jsonString] The JSON string to be exported.
  /// [fileName] The desired name for the exported file (without extension).
  static Future<ExportResult> exportData(
    String jsonString,
    String fileName,
  ) async {
    try {
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      final path = await FilePicker.platform.saveFile(
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

    final path = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (path == null) {
      return ImportResult.canceled;
    }

    try {
      final jsonString = await _readFileContent(path.files.single);
      if (jsonString == null) return ImportResult.fileReadError;

      final isValid = await _validateJsonSchema(jsonString);
      if (!isValid) return ImportResult.invalidSchema;

      final Map<String, dynamic> decoded =
          json.decode(jsonString) as Map<String, dynamic>;

      final List<dynamic> playersJson =
          (decoded['players'] as List<dynamic>?) ?? [];
      final List<dynamic> groupsJson =
          (decoded['groups'] as List<dynamic>?) ?? [];
      final List<dynamic> matchesJson =
          (decoded['matches'] as List<dynamic>?) ?? [];

      // Players
      final List<Player> importedPlayers = playersJson
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList();

      final Map<String, Player> playerById = {
        for (final p in importedPlayers) p.id: p,
      };

      // Groups
      final List<Group> importedGroups = groupsJson.map((g) {
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
          members: members,
          createdAt: DateTime.parse(map['createdAt'] as String),
        );
      }).toList();

      final Map<String, Group> groupById = {
        for (final g in importedGroups) g.id: g,
      };

      // Matches
      final List<Match> importedMatches = matchesJson.map((m) {
        final map = m as Map<String, dynamic>;

        final String? groupId = map['groupId'] as String?;
        final List<String> playerIds =
            (map['playerIds'] as List<dynamic>? ?? []).cast<String>();
        final String? winnerId = map['winnerId'] as String?;

        final group = (groupId == null) ? null : groupById[groupId];
        final players = playerIds
            .map((id) => playerById[id])
            .whereType<Player>()
            .toList();
        final winner = (winnerId == null) ? null : playerById[winnerId];

        return Match(
          id: map['id'] as String,
          name: map['name'] as String,
          group: group,
          players: players,
          createdAt: DateTime.parse(map['createdAt'] as String),
          winner: winner,
        );
      }).toList();

      await db.playerDao.addPlayersAsList(players: importedPlayers);
      await db.groupDao.addGroupsAsList(groups: importedGroups);
      await db.matchDao.addMatchAsList(matches: importedMatches);

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

  /// Helper method to read file content from either bytes or path
  static Future<String?> _readFileContent(PlatformFile file) async {
    if (file.bytes != null) return utf8.decode(file.bytes!);
    if (file.path != null) return await File(file.path!).readAsString();
    return null;
  }

  /// Validates the given JSON string against the predefined schema.
  static Future<bool> _validateJsonSchema(String jsonString) async {
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
