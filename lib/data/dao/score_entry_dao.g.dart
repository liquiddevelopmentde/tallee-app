// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_entry_dao.dart';

// ignore_for_file: type=lint
mixin _$ScoreEntryDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlayerTableTable get playerTable => attachedDatabase.playerTable;
  $GameTableTable get gameTable => attachedDatabase.gameTable;
  $GroupTableTable get groupTable => attachedDatabase.groupTable;
  $MatchTableTable get matchTable => attachedDatabase.matchTable;
  $ScoreEntryTableTable get scoreEntryTable => attachedDatabase.scoreEntryTable;
  ScoreEntryDaoManager get managers => ScoreEntryDaoManager(this);
}

class ScoreEntryDaoManager {
  final _$ScoreEntryDaoMixin _db;
  ScoreEntryDaoManager(this._db);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db.attachedDatabase, _db.playerTable);
  $$GameTableTableTableManager get gameTable =>
      $$GameTableTableTableManager(_db.attachedDatabase, _db.gameTable);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db.attachedDatabase, _db.groupTable);
  $$MatchTableTableTableManager get matchTable =>
      $$MatchTableTableTableManager(_db.attachedDatabase, _db.matchTable);
  $$ScoreEntryTableTableTableManager get scoreEntryTable =>
      $$ScoreEntryTableTableTableManager(
        _db.attachedDatabase,
        _db.scoreEntryTable,
      );
}
