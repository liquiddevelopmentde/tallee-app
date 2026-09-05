// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistic_dao.dart';

// ignore_for_file: type=lint
mixin _$StatisticDaoMixin on DatabaseAccessor<AppDatabase> {
  $StatisticTableTable get statisticTable => attachedDatabase.statisticTable;
  StatisticDaoManager get managers => StatisticDaoManager(this);
}

class StatisticDaoManager {
  final _$StatisticDaoMixin _db;
  StatisticDaoManager(this._db);
  $$StatisticTableTableTableManager get statisticTable =>
      $$StatisticTableTableTableManager(
        _db.attachedDatabase,
        _db.statisticTable,
      );
}
