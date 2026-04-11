import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tallee/data/dao/game_dao.dart';
import 'package:tallee/data/dao/group_dao.dart';
import 'package:tallee/data/dao/match_dao.dart';
import 'package:tallee/data/dao/player_dao.dart';
import 'package:tallee/data/dao/player_group_dao.dart';
import 'package:tallee/data/dao/player_match_dao.dart';
import 'package:tallee/data/dao/score_dao.dart';
import 'package:tallee/data/dao/team_dao.dart';
import 'package:tallee/data/db/tables/game_table.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/match_table.dart';
import 'package:tallee/data/db/tables/player_group_table.dart';
import 'package:tallee/data/db/tables/player_match_table.dart';
import 'package:tallee/data/db/tables/player_table.dart';
import 'package:tallee/data/db/tables/score_entry_table.dart';
import 'package:tallee/data/db/tables/team_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    PlayerTable,
    GroupTable,
    MatchTable,
    PlayerGroupTable,
    PlayerMatchTable,
    GameTable,
    TeamTable,
    ScoreEntryTable,
  ],
  daos: [
    PlayerDao,
    GroupDao,
    MatchDao,
    PlayerGroupDao,
    PlayerMatchDao,
    GameDao,
    ScoreDao,
    TeamDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'gametracker_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
