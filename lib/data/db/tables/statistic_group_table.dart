import 'package:drift/drift.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/statistic_table.dart';

class StatisticGroupTable extends Table {
  TextColumn get statisticId =>
      text().references(StatisticTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get groupId =>
      text().references(GroupTable, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {statisticId, groupId};
}
