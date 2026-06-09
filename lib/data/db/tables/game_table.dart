import 'package:drift/drift.dart';

class GameTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get name => text()();
  TextColumn get ruleset => text()();
  TextColumn get description => text()();
  TextColumn get color => text()();
  TextColumn get icon => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
