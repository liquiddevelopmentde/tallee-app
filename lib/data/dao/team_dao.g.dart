// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_dao.dart';

// ignore_for_file: type=lint
mixin _$TeamDaoMixin on DatabaseAccessor<AppDatabase> {
  $TeamTableTable get teamTable => attachedDatabase.teamTable;
  $PlayerTableTable get playerTable => attachedDatabase.playerTable;
  $GameTableTable get gameTable => attachedDatabase.gameTable;
  $GroupTableTable get groupTable => attachedDatabase.groupTable;
  $MatchTableTable get matchTable => attachedDatabase.matchTable;
  $PlayerMatchTableTable get playerMatchTable =>
      attachedDatabase.playerMatchTable;
  TeamDaoManager get managers => TeamDaoManager(this);
}

class TeamDaoManager {
  final _$TeamDaoMixin _db;
  TeamDaoManager(this._db);
  $$TeamTableTableTableManager get teamTable =>
      $$TeamTableTableTableManager(_db.attachedDatabase, _db.teamTable);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db.attachedDatabase, _db.playerTable);
  $$GameTableTableTableManager get gameTable =>
      $$GameTableTableTableManager(_db.attachedDatabase, _db.gameTable);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db.attachedDatabase, _db.groupTable);
  $$MatchTableTableTableManager get matchTable =>
      $$MatchTableTableTableManager(_db.attachedDatabase, _db.matchTable);
  $$PlayerMatchTableTableTableManager get playerMatchTable =>
      $$PlayerMatchTableTableTableManager(
        _db.attachedDatabase,
        _db.playerMatchTable,
      );
}
