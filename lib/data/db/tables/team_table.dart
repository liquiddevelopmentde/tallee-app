import 'package:drift/drift.dart';

class TeamTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get color => text().withDefault(const Constant('blue'))();
  IntColumn get score => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
