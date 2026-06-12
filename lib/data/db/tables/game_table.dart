import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';

class GameTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get ruleset => textEnum<Ruleset>()();
  TextColumn get description => text()();
  TextColumn get color => textEnum<AppColor>()();
  TextColumn get icon => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
