import 'package:drift/drift.dart';

class TeamTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get color => text().withDefault(const Constant('blue'))();
  IntColumn get score => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
