// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_dao.dart';

// ignore_for_file: type=lint
mixin _$TeamDaoMixin on DatabaseAccessor<AppDatabase> {
  $TeamTableTable get teamTable => attachedDatabase.teamTable;
  TeamDaoManager get managers => TeamDaoManager(this);
}

class TeamDaoManager {
  final _$TeamDaoMixin _db;
  TeamDaoManager(this._db);
  $$TeamTableTableTableManager get teamTable =>
      $$TeamTableTableTableManager(_db.attachedDatabase, _db.teamTable);
}
