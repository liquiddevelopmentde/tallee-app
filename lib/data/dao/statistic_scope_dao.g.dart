// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistic_scope_dao.dart';

// ignore_for_file: type=lint
mixin _$StatisticScopeDaoMixin on DatabaseAccessor<AppDatabase> {
  $StatisticTableTable get statisticTable => attachedDatabase.statisticTable;
  $StatisticScopeTableTable get statisticScopeTable =>
      attachedDatabase.statisticScopeTable;
  StatisticScopeDaoManager get managers => StatisticScopeDaoManager(this);
}

class StatisticScopeDaoManager {
  final _$StatisticScopeDaoMixin _db;
  StatisticScopeDaoManager(this._db);
  $$StatisticTableTableTableManager get statisticTable =>
      $$StatisticTableTableTableManager(
        _db.attachedDatabase,
        _db.statisticTable,
      );
  $$StatisticScopeTableTableTableManager get statisticScopeTable =>
      $$StatisticScopeTableTableTableManager(
        _db.attachedDatabase,
        _db.statisticScopeTable,
      );
}
