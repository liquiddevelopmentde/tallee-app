// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_dao.dart';

// ignore_for_file: type=lint
mixin _$GroupDaoMixin on DatabaseAccessor<AppDatabase> {
  $GroupTableTable get groupTable => attachedDatabase.groupTable;
  $PlayerTableTable get playerTable => attachedDatabase.playerTable;
  $PlayerGroupTableTable get playerGroupTable =>
      attachedDatabase.playerGroupTable;
  $GameTableTable get gameTable => attachedDatabase.gameTable;
  $MatchTableTable get matchTable => attachedDatabase.matchTable;
  GroupDaoManager get managers => GroupDaoManager(this);
}

class GroupDaoManager {
  final _$GroupDaoMixin _db;
  GroupDaoManager(this._db);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db.attachedDatabase, _db.groupTable);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db.attachedDatabase, _db.playerTable);
  $$PlayerGroupTableTableTableManager get playerGroupTable =>
      $$PlayerGroupTableTableTableManager(
        _db.attachedDatabase,
        _db.playerGroupTable,
      );
  $$GameTableTableTableManager get gameTable =>
      $$GameTableTableTableManager(_db.attachedDatabase, _db.gameTable);
  $$MatchTableTableTableManager get matchTable =>
      $$MatchTableTableTableManager(_db.attachedDatabase, _db.matchTable);
}
