import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/statistic_game_table.dart';
import 'package:tallee/data/models/game.dart';

part 'statistic_game_dao.g.dart';

@DriftAccessor(tables: [StatisticGameTable])
class StatisticGameDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticGameDaoMixin {
  StatisticGameDao(super.db);

  /// Retrieves a list of games associated with a specific statistic.
  Future<List<Game>?> getGamesForStatistic(String statisticId) async {
    final query = select(statisticGameTable).join([
      innerJoin(gameTable, gameTable.id.equalsExp(statisticGameTable.gameId)),
    ])..where(statisticGameTable.statisticId.equals(statisticId));

    final results = await query.map((row) => row.readTable(gameTable)).get();
    if (results.isEmpty) return null;
    return results
        .map(
          (row) => Game(
            id: row.id,
            name: row.name,
            ruleset: row.ruleset,
            description: row.description,
            color: row.color,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  Future<bool> addStatisticGames({
    required String statisticId,
    required List<Game> games,
  }) {
    final entries = games
        .map(
          (game) => StatisticGameTableCompanion.insert(
            statisticId: statisticId,
            gameId: game.id,
          ),
        )
        .toList();

    return batch((batch) {
      batch.insertAll(statisticGameTable, entries, mode: .insertOrReplace);
    }).then((_) => true).catchError((error) {
      print('Error adding statistic games: $error');
      return false;
    });
  }
}
