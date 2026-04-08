// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_dao.dart';

// ignore_for_file: type=lint
mixin _$ScoreDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlayerTableTable get playerTable => attachedDatabase.playerTable;
  $GameTableTable get gameTable => attachedDatabase.gameTable;
  $GroupTableTable get groupTable => attachedDatabase.groupTable;
  $MatchTableTable get matchTable => attachedDatabase.matchTable;
  $ScoreTableTable get scoreTable => attachedDatabase.scoreTable;
  ScoreDaoManager get managers => ScoreDaoManager(this);
}

class ScoreDaoManager {
  final _$ScoreDaoMixin _db;
  ScoreDaoManager(this._db);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db.attachedDatabase, _db.playerTable);
  $$GameTableTableTableManager get gameTable =>
      $$GameTableTableTableManager(_db.attachedDatabase, _db.gameTable);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db.attachedDatabase, _db.groupTable);
  $$MatchTableTableTableManager get matchTable =>
      $$MatchTableTableTableManager(_db.attachedDatabase, _db.matchTable);
  $$ScoreTableTableTableManager get scoreTable =>
      $$ScoreTableTableTableManager(_db.attachedDatabase, _db.scoreTable);
}
