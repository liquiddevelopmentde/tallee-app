import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tallee/data/dao/group_dao.dart';
import 'package:tallee/data/dao/group_match_dao.dart';
import 'package:tallee/data/dao/match_dao.dart';
import 'package:tallee/data/dao/player_dao.dart';
import 'package:tallee/data/dao/player_group_dao.dart';
import 'package:tallee/data/dao/player_match_dao.dart';
import 'package:tallee/data/db/tables/group_match_table.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/match_table.dart';
import 'package:tallee/data/db/tables/player_group_table.dart';
import 'package:tallee/data/db/tables/player_match_table.dart';
import 'package:tallee/data/db/tables/player_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    PlayerTable,
    GroupTable,
    MatchTable,
    PlayerGroupTable,
    PlayerMatchTable,
    GroupMatchTable,
  ],
  daos: [
    PlayerDao,
    GroupDao,
    MatchDao,
    PlayerGroupDao,
    PlayerMatchDao,
    GroupMatchDao,
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
