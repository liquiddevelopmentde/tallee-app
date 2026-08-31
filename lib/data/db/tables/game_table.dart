import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';

class GameTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get name => text()();
  TextColumn get ruleset => textEnum<Ruleset>()();
  TextColumn get description => text()();
  TextColumn get color => textEnum<AppColor>()();
  IntColumn get lives => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
