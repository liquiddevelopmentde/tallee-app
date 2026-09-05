// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_dao.dart';

// ignore_for_file: type=lint
mixin _$MatchDaoMixin on DatabaseAccessor<AppDatabase> {
  $GameTableTable get gameTable => attachedDatabase.gameTable;
  $GroupTableTable get groupTable => attachedDatabase.groupTable;
  $MatchTableTable get matchTable => attachedDatabase.matchTable;
  $PlayerTableTable get playerTable => attachedDatabase.playerTable;
  $TeamTableTable get teamTable => attachedDatabase.teamTable;
  $PlayerMatchTableTable get playerMatchTable =>
      attachedDatabase.playerMatchTable;
  MatchDaoManager get managers => MatchDaoManager(this);
}

class MatchDaoManager {
  final _$MatchDaoMixin _db;
  MatchDaoManager(this._db);
  $$GameTableTableTableManager get gameTable =>
      $$GameTableTableTableManager(_db.attachedDatabase, _db.gameTable);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db.attachedDatabase, _db.groupTable);
  $$MatchTableTableTableManager get matchTable =>
      $$MatchTableTableTableManager(_db.attachedDatabase, _db.matchTable);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db.attachedDatabase, _db.playerTable);
  $$TeamTableTableTableManager get teamTable =>
      $$TeamTableTableTableManager(_db.attachedDatabase, _db.teamTable);
  $$PlayerMatchTableTableTableManager get playerMatchTable =>
      $$PlayerMatchTableTableTableManager(
        _db.attachedDatabase,
        _db.playerMatchTable,
      );
}
