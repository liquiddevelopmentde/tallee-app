import 'package:drift/drift.dart';

class StatisticTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get timeframe => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
