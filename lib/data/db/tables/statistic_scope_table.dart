import 'package:drift/drift.dart';
import 'package:tallee/data/db/tables/statistic_table.dart';

class StatisticScopeTable extends Table {
  TextColumn get statisticId =>
      text().references(StatisticTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get scope => text()();

  @override
  Set<Column<Object>> get primaryKey => {statisticId, scope};
}
