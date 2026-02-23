import 'package:drift/drift.dart';
import 'package:tallee/data/db/tables/game_table.dart';
import 'package:tallee/data/db/tables/group_table.dart';

class MatchTable extends Table {
  TextColumn get id => text()();
  TextColumn get gameId =>
      text().references(GameTable, #id, onDelete: KeyAction.cascade)();
  // Nullable if there is no group associated with the match
  TextColumn get groupId =>
      text().references(GroupTable, #id, onDelete: KeyAction.cascade).nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}