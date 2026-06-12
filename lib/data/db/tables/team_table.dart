import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';

class TeamTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get name => text()();
  TextColumn get color =>
      textEnum<AppColor>().withDefault(Constant(AppColor.blue.name))();
  IntColumn get score => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
