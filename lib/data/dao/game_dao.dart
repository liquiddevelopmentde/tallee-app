import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/game_table.dart';
import 'package:tallee/data/models/game.dart';

part 'game_dao.g.dart';

@DriftAccessor(tables: [GameTable])
class GameDao extends DatabaseAccessor<AppDatabase> with _$GameDaoMixin {
  GameDao(super.db);

  /* Create */

  /// Adds a new [game] to the database.
  /// If a game with the same ID already exists, no action is taken.
  /// Returns `true` if the game was added, `false` otherwise.
  Future<bool> addGame({required Game game}) async {
    if (!await gameExists(gameId: game.id)) {
      await into(gameTable).insert(
        GameTableCompanion.insert(
          id: game.id,
          name: game.name,
          ruleset: game.ruleset,
          description: game.description,
          color: game.color,
          createdAt: game.createdAt,
        ),
        mode: InsertMode.insertOrReplace,
      );
      return true;
    }
    return false;
  }

  /// Adds multiple [games] to the database in a batch operation.
  /// Uses insertOrIgnore to avoid overwriting existing games.
  Future<bool> addGamesAsList({required List<Game> games}) async {
    if (games.isEmpty) return false;

    await db.batch(
      (b) => b.insertAll(
        gameTable,
        games
            .map(
              (game) => GameTableCompanion.insert(
                id: game.id,
                name: game.name,
                ruleset: game.ruleset,
                description: game.description,
                color: game.color,
                createdAt: game.createdAt,
              ),
            )
            .toList(),
        mode: InsertMode.insertOrIgnore,
      ),
    );

    return true;
  }

  /* Read */

  /// Retrieves the total count of games in the database.
  Future<int> getGameCount() async {
    final count =
        await (selectOnly(gameTable)..addColumns([gameTable.id.count()]))
            .map((row) => row.read(gameTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Retrieves all games and their game count
  /// Returns a list of tuples (Game, gameCount).
  Future<List<(Game, int)>> getAllGameCounts() async {
    final games = await getAllGames();

    final results = <(Game, int)>[];

    for (final game in games) {
      final gameCount =
          await (selectOnly(db.matchTable)
                ..where(db.matchTable.gameId.equals(game.id))
                ..addColumns([db.matchTable.id.count()]))
              .map((row) => row.read(db.matchTable.id.count()))
              .getSingle();

      results.add((game, gameCount ?? 0));
    }

    return results;
  }

  /// Checks if a game with the given [gameId] exists in the database.
  /// Returns `true` if the game exists, `false` otherwise.
  Future<bool> gameExists({required String gameId}) async {
    final query = select(gameTable)..where((g) => g.id.equals(gameId));
    final row = await query.getSingleOrNull();
    return row != null;
  }

  /// Retrieves all games from the database.
  Future<List<Game>> getAllGames() async {
    final query = select(gameTable);
    final result = await query.get();
    return result
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

  /// Retrieves a [Game] by its [gameId].
  Future<Game> getGameById({required String gameId}) async {
    final query = select(gameTable)..where((g) => g.id.equals(gameId));
    final row = await query.getSingle();
    return Game(
      id: row.id,
      name: row.name,
      ruleset: row.ruleset,
      description: row.description,
      color: row.color,
      createdAt: row.createdAt,
    );
  }

  /// Retrieves multiple [Game]s by their [gameIds].
  Future<List<Game>> getGamesByIds({required List<String> gameIds}) async {
    if (gameIds.isEmpty) return [];
    final query = select(gameTable)..where((g) => g.id.isIn(gameIds));
    final result = await query.get();
    return result
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

  /* Update */

  /// Updates the name of the game with the given [gameId] to [name].
  Future<bool> updateGameName({
    required String gameId,
    required String name,
  }) async {
    final rowsAffected =
        await (update(gameTable)..where((tbl) => tbl.id.equals(gameId))).write(
          GameTableCompanion(name: Value(name)),
        );
    return rowsAffected > 0;
  }

  /// Updates the ruleset of the game with the given [gameId].
  Future<bool> updateGameRuleset({
    required String gameId,
    required Ruleset ruleset,
  }) async {
    final rowsAffected =
        await (update(gameTable)..where((tbl) => tbl.id.equals(gameId))).write(
          GameTableCompanion(ruleset: Value(ruleset)),
        );
    return rowsAffected > 0;
  }

  /// Updates the description of the game with the given [gameId].
  Future<bool> updateGameDescription({
    required String gameId,
    required String description,
  }) async {
    final rowsAffected =
        await (update(gameTable)..where((tbl) => tbl.id.equals(gameId))).write(
          GameTableCompanion(description: Value(description)),
        );
    return rowsAffected > 0;
  }

  /// Updates the color of the game with the given [gameId].
  Future<bool> updateGameColor({
    required String gameId,
    required AppColor color,
  }) async {
    final rowsAffected =
        await (update(gameTable)..where((tbl) => tbl.id.equals(gameId))).write(
          GameTableCompanion(color: Value(color)),
        );
    return rowsAffected > 0;
  }

  /* Delete */

  /// Deletes the game with the given [gameId] from the database.
  /// Returns `true` if the game was deleted, `false` if the game did not exist.
  Future<bool> deleteGame({required String gameId}) async {
    final query = delete(gameTable)..where((tbl) => tbl.id.equals(gameId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Deletes all games from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllGames() async {
    final query = delete(gameTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }
}
