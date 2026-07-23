import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';

class StatisticTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get type => textEnum<StatisticType>()();
  TextColumn get timeframe => textEnum<Timeframe>()();
  TextColumn get color => textEnum<AppColor>()();
  IntColumn get displayCount => integer().withDefault(const Constant(5))();

  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
