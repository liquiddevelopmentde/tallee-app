import 'package:drift/drift.dart';

class TeamTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('blue'))();
  IntColumn get score => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
