import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/statistic_game_table.dart';
import 'package:tallee/data/models/game.dart';

part 'statistic_game_dao.g.dart';

@DriftAccessor(tables: [StatisticGameTable])
class StatisticGameDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticGameDaoMixin {
  StatisticGameDao(super.db);

  /// Retrieves a list of games associated with a specific statistic.
  Future<List<Game>> getGamesForStatistic(String statisticId) async {
    final query = select(statisticGameTable).join([
      innerJoin(gameTable, gameTable.id.equalsExp(statisticGameTable.gameId)),
    ])..where(statisticGameTable.statisticId.equals(statisticId));

    final results = await query.map((row) => row.readTable(gameTable)).get();
    return results
        .map(
          (result) => Game(
            id: result.id,
            name: result.name,
            ruleset: Ruleset.values.firstWhere((e) => e.name == result.ruleset),
            description: result.description,
            color: GameColor.values.firstWhere((e) => e.name == result.color),
            icon: result.icon,
            createdAt: result.createdAt,
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
      batch.insertAll(
        statisticGameTable,
        entries,
        mode: InsertMode.insertOrReplace,
      );
    }).then((_) => true).catchError((error) {
      print('Error adding statistic games: $error');
      return false;
    });
  }
}
