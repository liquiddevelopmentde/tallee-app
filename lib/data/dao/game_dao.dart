import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/game_table.dart';
import 'package:tallee/data/models/game.dart';

part 'game_dao.g.dart';

@DriftAccessor(tables: [GameTable])
class GameDao extends DatabaseAccessor<AppDatabase> with _$GameDaoMixin {
  GameDao(super.db);

  /// Retrieves all games from the database.
  Future<List<Game>> getAllGames() async {
    final query = select(gameTable);
    final result = await query.get();
    return result
        .map(
          (row) => Game(
            id: row.id,
            name: row.name,
            ruleset: Ruleset.values.firstWhere((e) => e.name == row.ruleset),
            description: row.description,
            color: GameColor.values.firstWhere((e) => e.name == row.color),
            icon: row.icon,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  /// Retrieves a [Game] by its [gameId].
  Future<Game> getGameById({required String gameId}) async {
    final query = select(gameTable)..where((g) => g.id.equals(gameId));
    final result = await query.getSingle();
    return Game(
      id: result.id,
      name: result.name,
      ruleset: Ruleset.values.firstWhere((e) => e.name == result.ruleset),
      description: result.description,
      color: GameColor.values.firstWhere((e) => e.name == result.color),
      icon: result.icon,
      createdAt: result.createdAt,
    );
  }

  /// Adds a new [game] to the database.
  /// If a game with the same ID already exists, no action is taken.
  /// Returns `true` if the game was added, `false` otherwise.
  Future<bool> addGame({required Game game}) async {
    if (!await gameExists(gameId: game.id)) {
      await into(gameTable).insert(
        GameTableCompanion.insert(
          id: game.id,
          name: game.name,
          ruleset: game.ruleset.name,
          description: game.description,
          color: game.color.name,
          icon: game.icon,
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
                ruleset: game.ruleset.name,
                description: game.description,
                color: game.color.name,
                icon: game.icon,
                createdAt: game.createdAt,
              ),
            )
            .toList(),
        mode: InsertMode.insertOrIgnore,
      ),
    );

    return true;
  }

  /// Deletes the game with the given [gameId] from the database.
  /// Returns `true` if the game was deleted, `false` if the game did not exist.
  Future<bool> deleteGame({required String gameId}) async {
    final query = delete(gameTable)..where((g) => g.id.equals(gameId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Checks if a game with the given [gameId] exists in the database.
  /// Returns `true` if the game exists, `false` otherwise.
  Future<bool> gameExists({required String gameId}) async {
    final query = select(gameTable)..where((g) => g.id.equals(gameId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Updates the name of the game with the given [gameId] to [newName].
  Future<void> updateGameName({
    required String gameId,
    required String newName,
  }) async {
    await (update(gameTable)..where((g) => g.id.equals(gameId))).write(
      GameTableCompanion(name: Value(newName)),
    );
  }

  /// Updates the ruleset of the game with the given [gameId].
  Future<void> updateGameRuleset({
    required String gameId,
    required Ruleset newRuleset,
  }) async {
    await (update(gameTable)..where((g) => g.id.equals(gameId))).write(
      GameTableCompanion(ruleset: Value(newRuleset.name)),
    );
  }

  /// Updates the description of the game with the given [gameId].
  Future<void> updateGameDescription({
    required String gameId,
    required String newDescription,
  }) async {
    await (update(gameTable)..where((g) => g.id.equals(gameId))).write(
      GameTableCompanion(description: Value(newDescription)),
    );
  }

  /// Updates the color of the game with the given [gameId].
  Future<void> updateGameColor({
    required String gameId,
    required GameColor newColor,
  }) async {
    await (update(gameTable)..where((g) => g.id.equals(gameId))).write(
      GameTableCompanion(color: Value(newColor.name)),
    );
  }

  /// Updates the icon of the game with the given [gameId].
  Future<void> updateGameIcon({
    required String gameId,
    required String newIcon,
  }) async {
    await (update(gameTable)..where((g) => g.id.equals(gameId))).write(
      GameTableCompanion(icon: Value(newIcon)),
    );
  }

  /// Retrieves the total count of games in the database.
  Future<int> getGameCount() async {
    final count =
        await (selectOnly(gameTable)..addColumns([gameTable.id.count()]))
            .map((row) => row.read(gameTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Deletes all games from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllGames() async {
    final query = delete(gameTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }
}
