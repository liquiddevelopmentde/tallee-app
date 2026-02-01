import 'package:drift/drift.dart';
import 'package:tallee/data/db/tables/game_table.dart';
import 'package:tallee/data/db/tables/group_table.dart';

class MatchTable extends Table {
  TextColumn get id => text()();
  TextColumn get gameId =>
      text().references(GameTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get groupId =>
      text().references(GroupTable, #id, onDelete: KeyAction.cascade).nullable()(); // Nullable if not part of a group
  TextColumn get name => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}