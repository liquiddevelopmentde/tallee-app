import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';

class GroupTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get name => text()();
  TextColumn get color =>
      textEnum<AppColor>().withDefault(const Constant('orange'))();
  TextColumn get description => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
