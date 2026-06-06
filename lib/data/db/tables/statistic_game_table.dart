import 'package:drift/drift.dart';
import 'package:tallee/data/db/tables/game_table.dart';
import 'package:tallee/data/db/tables/statistic_table.dart';

class StatisticGameTable extends Table {
  TextColumn get statisticId =>
      text().references(StatisticTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get gameId =>
      text().references(GameTable, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {statisticId, gameId};
}
