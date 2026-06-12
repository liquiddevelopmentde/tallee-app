import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';

class TeamTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get color =>
      textEnum<AppColor>().withDefault(Constant(AppColor.blue.name))();
  IntColumn get score => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
