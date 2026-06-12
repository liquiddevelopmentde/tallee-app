import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';

class StatisticTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => textEnum<StatisticType>()();
  TextColumn get timeframe => textEnum<Timeframe>().nullable()();
  IntColumn get displayCount => integer().withDefault(const Constant(5))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
