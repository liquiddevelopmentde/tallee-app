import 'package:drift/drift.dart';

class StatisticTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get timeframe => text()();
  TextColumn get color => text()();
  IntColumn get displayCount => integer().withDefault(const Constant(5))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
