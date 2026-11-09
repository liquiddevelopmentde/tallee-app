// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:tallee/data/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldPlayerTableData = <v1.PlayerTableData>[];
    final expectedNewPlayerTableData = <v2.PlayerTableData>[];

    final oldGroupTableData = <v1.GroupTableData>[];
    final expectedNewGroupTableData = <v2.GroupTableData>[];

    final oldGameTableData = <v1.GameTableData>[];
    final expectedNewGameTableData = <v2.GameTableData>[];

    final oldMatchTableData = <v1.MatchTableData>[];
    final expectedNewMatchTableData = <v2.MatchTableData>[];

    final oldPlayerGroupTableData = <v1.PlayerGroupTableData>[];
    final expectedNewPlayerGroupTableData = <v2.PlayerGroupTableData>[];

    final oldTeamTableData = <v1.TeamTableData>[];
    final expectedNewTeamTableData = <v2.TeamTableData>[];

    final oldPlayerMatchTableData = <v1.PlayerMatchTableData>[];
    final expectedNewPlayerMatchTableData = <v2.PlayerMatchTableData>[];

    final oldScoreEntryTableData = <v1.ScoreEntryTableData>[];
    final expectedNewScoreEntryTableData = <v2.ScoreEntryTableData>[];

    final oldStatisticTableData = <v1.StatisticTableData>[];
    final expectedNewStatisticTableData = <v2.StatisticTableData>[];

    final oldStatisticScopeTableData = <v1.StatisticScopeTableData>[];
    final expectedNewStatisticScopeTableData = <v2.StatisticScopeTableData>[];

    final oldStatisticGameTableData = <v1.StatisticGameTableData>[];
    final expectedNewStatisticGameTableData = <v2.StatisticGameTableData>[];

    final oldStatisticGroupTableData = <v1.StatisticGroupTableData>[];
    final expectedNewStatisticGroupTableData = <v2.StatisticGroupTableData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.playerTable, oldPlayerTableData);
        batch.insertAll(oldDb.groupTable, oldGroupTableData);
        batch.insertAll(oldDb.gameTable, oldGameTableData);
        batch.insertAll(oldDb.matchTable, oldMatchTableData);
        batch.insertAll(oldDb.playerGroupTable, oldPlayerGroupTableData);
        batch.insertAll(oldDb.teamTable, oldTeamTableData);
        batch.insertAll(oldDb.playerMatchTable, oldPlayerMatchTableData);
        batch.insertAll(oldDb.scoreEntryTable, oldScoreEntryTableData);
        batch.insertAll(oldDb.statisticTable, oldStatisticTableData);
        batch.insertAll(oldDb.statisticScopeTable, oldStatisticScopeTableData);
        batch.insertAll(oldDb.statisticGameTable, oldStatisticGameTableData);
        batch.insertAll(oldDb.statisticGroupTable, oldStatisticGroupTableData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewPlayerTableData,
          await newDb.select(newDb.playerTable).get(),
        );
        expect(
          expectedNewGroupTableData,
          await newDb.select(newDb.groupTable).get(),
        );
        expect(
          expectedNewGameTableData,
          await newDb.select(newDb.gameTable).get(),
        );
        expect(
          expectedNewMatchTableData,
          await newDb.select(newDb.matchTable).get(),
        );
        expect(
          expectedNewPlayerGroupTableData,
          await newDb.select(newDb.playerGroupTable).get(),
        );
        expect(
          expectedNewTeamTableData,
          await newDb.select(newDb.teamTable).get(),
        );
        expect(
          expectedNewPlayerMatchTableData,
          await newDb.select(newDb.playerMatchTable).get(),
        );
        expect(
          expectedNewScoreEntryTableData,
          await newDb.select(newDb.scoreEntryTable).get(),
        );
        expect(
          expectedNewStatisticTableData,
          await newDb.select(newDb.statisticTable).get(),
        );
        expect(
          expectedNewStatisticScopeTableData,
          await newDb.select(newDb.statisticScopeTable).get(),
        );
        expect(
          expectedNewStatisticGameTableData,
          await newDb.select(newDb.statisticGameTable).get(),
        );
        expect(
          expectedNewStatisticGroupTableData,
          await newDb.select(newDb.statisticGroupTable).get(),
        );
      },
    );
  });
}
