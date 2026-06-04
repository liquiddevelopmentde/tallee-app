// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistic_group_dao.dart';

// ignore_for_file: type=lint
mixin _$StatisticGroupDaoMixin on DatabaseAccessor<AppDatabase> {
  $StatisticTableTable get statisticTable => attachedDatabase.statisticTable;
  $GroupTableTable get groupTable => attachedDatabase.groupTable;
  $StatisticGroupTableTable get statisticGroupTable =>
      attachedDatabase.statisticGroupTable;
  StatisticGroupDaoManager get managers => StatisticGroupDaoManager(this);
}

class StatisticGroupDaoManager {
  final _$StatisticGroupDaoMixin _db;
  StatisticGroupDaoManager(this._db);
  $$StatisticTableTableTableManager get statisticTable =>
      $$StatisticTableTableTableManager(
        _db.attachedDatabase,
        _db.statisticTable,
      );
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db.attachedDatabase, _db.groupTable);
  $$StatisticGroupTableTableTableManager get statisticGroupTable =>
      $$StatisticGroupTableTableTableManager(
        _db.attachedDatabase,
        _db.statisticGroupTable,
      );
}
