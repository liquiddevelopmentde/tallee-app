import 'package:drift/drift.dart';
import 'package:tallee/data/db/tables/game_table.dart';
import 'package:tallee/data/db/tables/group_table.dart';

class MatchTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get name => text()();
  TextColumn get gameId =>
      text().references(GameTable, #id, onDelete: KeyAction.cascade)();
  // If a group gets deleted, groupId in the match gets set to null
  TextColumn get groupId => text()
      .references(GroupTable, #id, onDelete: KeyAction.setNull)
      .nullable()();
  BoolColumn get isTeamMatch => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
