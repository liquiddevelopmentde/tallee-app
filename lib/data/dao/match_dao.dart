import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/game_table.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/match_table.dart';
import 'package:tallee/data/db/tables/player_match_table.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';

part 'match_dao.g.dart';

@DriftAccessor(tables: [MatchTable, GameTable, GroupTable, PlayerMatchTable])
class MatchDao extends DatabaseAccessor<AppDatabase> with _$MatchDaoMixin {
  MatchDao(super.db);

  /// Retrieves all matches from the database.
  Future<List<Match>> getAllMatches() async {
    final query = select(matchTable);
    final result = await query.get();

    return Future.wait(
      result.map((row) async {
        final game = await db.gameDao.getGameById(gameId: row.gameId);
        Group? group;
        if (row.groupId != null) {
          group = await db.groupDao.getGroupById(groupId: row.groupId!);
        }
        final players =
            await db.playerMatchDao.getPlayersOfMatch(matchId: row.id) ?? [];
        final winner = await db.scoreDao.getWinner(matchId: row.id);
        return Match(
          id: row.id,
          name: row.name,
          game: game,
          group: group,
          players: players,
          notes: row.notes ?? '',
          createdAt: row.createdAt,
          endedAt: row.endedAt,
          winner: winner,
        );
      }),
    );
  }

  /// Retrieves a [Match] by its [matchId].
  Future<Match> getMatchById({required String matchId}) async {
    final query = select(matchTable)..where((g) => g.id.equals(matchId));
    final result = await query.getSingle();

    final game = await db.gameDao.getGameById(gameId: result.gameId);

    Group? group;
    if (result.groupId != null) {
      group = await db.groupDao.getGroupById(groupId: result.groupId!);
    }

    final players =
        await db.playerMatchDao.getPlayersOfMatch(matchId: matchId) ?? [];

    final winner = await db.scoreDao.getWinner(matchId: matchId);

    return Match(
      id: result.id,
      name: result.name,
      game: game,
      group: group,
      players: players,
      notes: result.notes ?? '',
      createdAt: result.createdAt,
      endedAt: result.endedAt,
      winner: winner,
    );
  }

  /// Adds a new [Match] to the database. Also adds players associations.
  /// This method assumes that the game and group (if any) are already present
  /// in the database.
  Future<void> addMatch({required Match match}) async {
    await db.transaction(() async {
      await into(matchTable).insert(
        MatchTableCompanion.insert(
          id: match.id,
          gameId: match.game.id,
          groupId: Value(match.group?.id),
          name: match.name,
          notes: Value(match.notes),
          createdAt: match.createdAt,
          endedAt: Value(match.endedAt),
        ),
        mode: InsertMode.insertOrReplace,
      );

      for (final p in match.players) {
        await db.playerMatchDao.addPlayerToMatch(
          matchId: match.id,
          playerId: p.id,
        );
      }

      if (match.winner != null) {
        await db.scoreDao.setWinner(
          matchId: match.id,
          playerId: match.winner!.id,
        );
      }
    });
  }

  /// Adds multiple [Match]es to the database in a batch operation.
  /// Also adds associated players and groups if they exist.
  /// If the [matches] list is empty, the method returns immediately.
  /// This method should only be used to import matches from a different device.
  Future<void> addMatchAsList({required List<Match> matches}) async {
    if (matches.isEmpty) return;
    await db.transaction(() async {
      // Add all games first (deduplicated)
      final uniqueGames = <String, Game>{};
      for (final match in matches) {
        uniqueGames[match.game.id] = match.game;
      }

      if (uniqueGames.isNotEmpty) {
        await db.batch(
          (b) => b.insertAll(
            db.gameTable,
            uniqueGames.values
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
      }

      // Add all groups of the matches in batch
      await db.batch(
        (b) => b.insertAll(
          db.groupTable,
          matches
              .where((match) => match.group != null)
              .map(
                (match) => GroupTableCompanion.insert(
                  id: match.group!.id,
                  name: match.group!.name,
                  description: match.group!.description,
                  createdAt: match.group!.createdAt,
                ),
              )
              .toList(),
          mode: InsertMode.insertOrIgnore,
        ),
      );

      // Add all matches in batch
      await db.batch(
        (b) => b.insertAll(
          matchTable,
          matches
              .map(
                (match) => MatchTableCompanion.insert(
                  id: match.id,
                  gameId: match.game.id,
                  groupId: Value(match.group?.id),
                  name: match.name,
                  notes: Value(match.notes),
                  createdAt: match.createdAt,
                  endedAt: Value(match.endedAt),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        ),
      );

      // Add all players of the matches in batch (unique)
      final uniquePlayers = <String, Player>{};
      for (final match in matches) {
        for (final p in match.players) {
          uniquePlayers[p.id] = p;
        }
        // Also include members of groups
        if (match.group != null) {
          for (final m in match.group!.members) {
            uniquePlayers[m.id] = m;
          }
        }
      }

      if (uniquePlayers.isNotEmpty) {
        await db.batch(
          (b) => b.insertAll(
            db.playerTable,
            uniquePlayers.values
                .map(
                  (p) => PlayerTableCompanion.insert(
                    id: p.id,
                    name: p.name,
                    description: p.description,
                    createdAt: p.createdAt,
                  ),
                )
                .toList(),
            mode: InsertMode.insertOrIgnore,
          ),
        );
      }

      // Add all player-match associations in batch
      await db.batch((b) {
        for (final match in matches) {
          for (final p in match.players) {
            b.insert(
              db.playerMatchTable,
              PlayerMatchTableCompanion.insert(
                matchId: match.id,
                playerId: p.id,
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }
        }
      });

      // Add all player-group associations in batch
      await db.batch((b) {
        for (final match in matches) {
          if (match.group != null) {
            for (final m in match.group!.members) {
              b.insert(
                db.playerGroupTable,
                PlayerGroupTableCompanion.insert(
                  playerId: m.id,
                  groupId: match.group!.id,
                ),
                mode: InsertMode.insertOrIgnore,
              );
            }
          }
        }
      });
    });
  }

  /// Deletes the match with the given [matchId] from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteMatch({required String matchId}) async {
    final query = delete(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Retrieves the number of matches in the database.
  Future<int> getMatchCount() async {
    final count =
        await (selectOnly(matchTable)..addColumns([matchTable.id.count()]))
            .map((row) => row.read(matchTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Retrieves all matches associated with the given [groupId].
  /// Queries the database directly, filtering by [groupId].
  Future<List<Match>> getGroupMatches({required String groupId}) async {
    final query = select(matchTable)..where((m) => m.groupId.equals(groupId));
    final rows = await query.get();

    return Future.wait(
      rows.map((row) async {
        final game = await db.gameDao.getGameById(gameId: row.gameId);
        final group = await db.groupDao.getGroupById(groupId: groupId);
        final players =
            await db.playerMatchDao.getPlayersOfMatch(matchId: row.id) ?? [];
        final winner = await db.scoreDao.getWinner(matchId: row.id);
        return Match(
          id: row.id,
          name: row.name,
          game: game,
          group: group,
          players: players,
          notes: row.notes ?? '',
          createdAt: row.createdAt,
          endedAt: row.endedAt,
          winner: winner,
        );
      }),
    );
  }

  /// Checks if a match with the given [matchId] exists in the database.
  /// Returns `true` if the match exists, otherwise `false`.
  Future<bool> matchExists({required String matchId}) async {
    final query = select(matchTable)..where((g) => g.id.equals(matchId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Deletes all matches from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllMatches() async {
    final query = delete(matchTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Updates the notes of the match with the given [matchId].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchNotes({
    required String matchId,
    required String? notes,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(notes: Value(notes)),
    );
    return rowsAffected > 0;
  }

  /// Changes the name of the match with the given [matchId] to [newName].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchName({
    required String matchId,
    required String newName,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(name: Value(newName)),
    );
    return rowsAffected > 0;
  }

  /// Updates the game of the match with the given [matchId].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchGame({
    required String matchId,
    required String gameId,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(gameId: Value(gameId)),
    );
    return rowsAffected > 0;
  }

  /// Updates the group of the match with the given [matchId].
  /// Replaces the existing group association with the new group specified by [newGroupId].
  /// Pass null to remove the group association.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchGroup({
    required String matchId,
    required String? newGroupId,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(groupId: Value(newGroupId)),
    );
    return rowsAffected > 0;
  }

  /// Removes the group association of the match with the given [matchId].
  /// Sets the groupId to null.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> removeMatchGroup({required String matchId}) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      const MatchTableCompanion(groupId: Value(null)),
    );
    return rowsAffected > 0;
  }

  /// Updates the createdAt timestamp of the match with the given [matchId].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchCreatedAt({
    required String matchId,
    required DateTime createdAt,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(createdAt: Value(createdAt)),
    );
    return rowsAffected > 0;
  }

  /// Updates the endedAt timestamp of the match with the given [matchId].
  /// Pass null to remove the ended time (mark match as ongoing).
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchEndedAt({
    required String matchId,
    required DateTime? endedAt,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(endedAt: Value(endedAt)),
    );
    return rowsAffected > 0;
  }

  /// Replaces all players in a match with the provided list of players.
  /// Removes all existing players from the match and adds the new players.
  /// Also adds any new players to the player table if they don't exist.
  Future<void> replaceMatchPlayers({
    required String matchId,
    required List<Player> newPlayers,
  }) async {
    await db.transaction(() async {
      // Remove all existing players from the match
      final deleteQuery = delete(db.playerMatchTable)
        ..where((p) => p.matchId.equals(matchId));
      await deleteQuery.go();

      // Add new players to the player table if they don't exist
      await Future.wait(
        newPlayers.map((player) async {
          if (!await db.playerDao.playerExists(playerId: player.id)) {
            await db.playerDao.addPlayer(player: player);
          }
        }),
      );

      // Add the new players to the match
      await Future.wait(
        newPlayers.map(
          (player) => db.playerMatchDao.addPlayerToMatch(
            matchId: matchId,
            playerId: player.id,
          ),
        ),
      );
    });
  }
}
