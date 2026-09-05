// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_match_dao.dart';

// ignore_for_file: type=lint
mixin _$PlayerMatchDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlayerTableTable get playerTable => attachedDatabase.playerTable;
  $GameTableTable get gameTable => attachedDatabase.gameTable;
  $GroupTableTable get groupTable => attachedDatabase.groupTable;
  $MatchTableTable get matchTable => attachedDatabase.matchTable;
  $TeamTableTable get teamTable => attachedDatabase.teamTable;
  $PlayerMatchTableTable get playerMatchTable =>
      attachedDatabase.playerMatchTable;
  PlayerMatchDaoManager get managers => PlayerMatchDaoManager(this);
}

class PlayerMatchDaoManager {
  final _$PlayerMatchDaoMixin _db;
  PlayerMatchDaoManager(this._db);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db.attachedDatabase, _db.playerTable);
  $$GameTableTableTableManager get gameTable =>
      $$GameTableTableTableManager(_db.attachedDatabase, _db.gameTable);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db.attachedDatabase, _db.groupTable);
  $$MatchTableTableTableManager get matchTable =>
      $$MatchTableTableTableManager(_db.attachedDatabase, _db.matchTable);
  $$TeamTableTableTableManager get teamTable =>
      $$TeamTableTableTableManager(_db.attachedDatabase, _db.teamTable);
  $$PlayerMatchTableTableTableManager get playerMatchTable =>
      $$PlayerMatchTableTableTableManager(
        _db.attachedDatabase,
        _db.playerMatchTable,
      );
}
