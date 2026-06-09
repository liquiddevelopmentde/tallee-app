import 'package:drift/drift.dart';

class GroupTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get name => text()();
  TextColumn get description => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
