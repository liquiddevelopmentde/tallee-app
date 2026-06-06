// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistic_game_dao.dart';

// ignore_for_file: type=lint
mixin _$StatisticGameDaoMixin on DatabaseAccessor<AppDatabase> {
  $StatisticTableTable get statisticTable => attachedDatabase.statisticTable;
  $GameTableTable get gameTable => attachedDatabase.gameTable;
  $StatisticGameTableTable get statisticGameTable =>
      attachedDatabase.statisticGameTable;
  StatisticGameDaoManager get managers => StatisticGameDaoManager(this);
}

class StatisticGameDaoManager {
  final _$StatisticGameDaoMixin _db;
  StatisticGameDaoManager(this._db);
  $$StatisticTableTableTableManager get statisticTable =>
      $$StatisticTableTableTableManager(
        _db.attachedDatabase,
        _db.statisticTable,
      );
  $$GameTableTableTableManager get gameTable =>
      $$GameTableTableTableManager(_db.attachedDatabase, _db.gameTable);
  $$StatisticGameTableTableTableManager get statisticGameTable =>
      $$StatisticGameTableTableTableManager(
        _db.attachedDatabase,
        _db.statisticGameTable,
      );
}
