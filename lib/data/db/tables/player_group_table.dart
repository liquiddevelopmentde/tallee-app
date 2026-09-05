import 'package:drift/drift.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/player_table.dart';

class PlayerGroupTable extends Table {
  TextColumn get playerId =>
      text().references(PlayerTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get groupId =>
      text().references(GroupTable, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {playerId, groupId};
}
