import 'package:drift/drift.dart';
import 'package:tallee/data/db/tables/match_table.dart';
import 'package:tallee/data/db/tables/player_table.dart';

class PlayerMatchTable extends Table {
  TextColumn get playerId =>
      text().references(PlayerTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get matchId =>
      text().references(MatchTable, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {playerId, matchId};
}
