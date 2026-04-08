// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_group_dao.dart';

// ignore_for_file: type=lint
mixin _$PlayerGroupDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlayerTableTable get playerTable => attachedDatabase.playerTable;
  $GroupTableTable get groupTable => attachedDatabase.groupTable;
  $PlayerGroupTableTable get playerGroupTable =>
      attachedDatabase.playerGroupTable;
  PlayerGroupDaoManager get managers => PlayerGroupDaoManager(this);
}

class PlayerGroupDaoManager {
  final _$PlayerGroupDaoMixin _db;
  PlayerGroupDaoManager(this._db);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db.attachedDatabase, _db.playerTable);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db.attachedDatabase, _db.groupTable);
  $$PlayerGroupTableTableTableManager get playerGroupTable =>
      $$PlayerGroupTableTableTableManager(
        _db.attachedDatabase,
        _db.playerGroupTable,
      );
}
