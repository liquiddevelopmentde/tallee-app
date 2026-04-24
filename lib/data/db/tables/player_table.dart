import 'package:drift/drift.dart';

class PlayerTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get name => text()();
  IntColumn get nameCount => integer().withDefault(const Constant(0))();
  TextColumn get description => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
