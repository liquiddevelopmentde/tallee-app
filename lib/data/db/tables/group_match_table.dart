import 'package:drift/drift.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/match_table.dart';

class GroupMatchTable extends Table {
  TextColumn get groupId =>
      text().references(GroupTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get matchId =>
      text().references(MatchTable, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {groupId, matchId};
}
