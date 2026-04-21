// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_dao.dart';

// ignore_for_file: type=lint
mixin _$GameDaoMixin on DatabaseAccessor<AppDatabase> {
  $GameTableTable get gameTable => attachedDatabase.gameTable;
  $GroupTableTable get groupTable => attachedDatabase.groupTable;
  $MatchTableTable get matchTable => attachedDatabase.matchTable;
  GameDaoManager get managers => GameDaoManager(this);
}

class GameDaoManager {
  final _$GameDaoMixin _db;
  GameDaoManager(this._db);
  $$GameTableTableTableManager get gameTable =>
      $$GameTableTableTableManager(_db.attachedDatabase, _db.gameTable);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db.attachedDatabase, _db.groupTable);
  $$MatchTableTableTableManager get matchTable =>
      $$MatchTableTableTableManager(_db.attachedDatabase, _db.matchTable);
}
