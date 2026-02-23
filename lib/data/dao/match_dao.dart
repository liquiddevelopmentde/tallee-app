import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/match_table.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';

part 'match_dao.g.dart';

@DriftAccessor(tables: [MatchTable])
class MatchDao extends DatabaseAccessor<AppDatabase> with _$MatchDaoMixin {
  MatchDao(super.db);

  /// Retrieves all matches from the database.
  Future<List<Match>> getAllMatches() async {
    final query = select(matchTable);
    final result = await query.get();

    return Future.wait(
      result.map((row) async {
        final group = await db.groupMatchDao.getGroupOfMatch(matchId: row.id);
        final players = await db.playerMatchDao.getPlayersOfMatch(
          matchId: row.id,
        );
        final winner = row.winnerId != null
            ? await db.playerDao.getPlayerById(playerId: row.winnerId!)
            : null;
        return Match(
          id: row.id,
          name: row.name,
          group: group,
          players: players,
          createdAt: row.createdAt,
          winner: winner,
        );
      }),
    );
  }

  /// Retrieves a [Match] by its [matchId].
  Future<Match> getMatchById({required String matchId}) async {
    final query = select(matchTable)..where((g) => g.id.equals(matchId));
    final result = await query.getSingle();

    List<Player>? players;
    if (await db.playerMatchDao.matchHasPlayers(matchId: matchId)) {
      players = await db.playerMatchDao.getPlayersOfMatch(matchId: matchId);
    }
    Group? group;
    if (await db.groupMatchDao.matchHasGroup(matchId: matchId)) {
      group = await db.groupMatchDao.getGroupOfMatch(matchId: matchId);
    }
    Player? winner;
    if (result.winnerId != null) {
      winner = await db.playerDao.getPlayerById(playerId: result.winnerId!);
    }

    return Match(
      id: result.id,
      name: result.name,
      players: players,
      group: group,
      winner: winner,
      createdAt: result.createdAt,
    );
  }

  /// Adds a new [Match] to the database. Also adds players and group
  /// associations. This method assumes that the players and groups added to
  /// this match are already present in the database.
  Future<void> addMatch({required Match match}) async {
    await db.transaction(() async {
      await into(matchTable).insert(
        MatchTableCompanion.insert(
          id: match.id,
          name: match.name,
          winnerId: Value(match.winner?.id),
          createdAt: match.createdAt,
        ),
        mode: InsertMode.insertOrReplace,
      );

      if (match.players != null) {
        for (final p in match.players ?? []) {
          await db.playerMatchDao.addPlayerToMatch(
            matchId: match.id,
            playerId: p.id,
          );
        }
      }

      if (match.group != null) {
        await db.groupMatchDao.addGroupToMatch(
          matchId: match.id,
          groupId: match.group!.id,
        );
      }
    });
  }

  /// Adds multiple [Match]s to the database in a batch operation.
  /// Also adds associated players and groups if they exist.
  /// If the [matches] list is empty, the method returns immediately.
  /// This Method should only be used to import matches from a different device.
  Future<void> addMatchAsList({required List<Match> matches}) async {
    if (matches.isEmpty) return;
    await db.transaction(() async {
      // Add all matches in batch
      await db.batch(
        (b) => b.insertAll(
          matchTable,
          matches
              .map(
                (match) => MatchTableCompanion.insert(
                  id: match.id,
                  name: match.name,
                  createdAt: match.createdAt,
                  winnerId: Value(match.winner?.id),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        ),
      );

      // Add all groups of the matches in batch
      // Using insertOrIgnore to avoid overwriting existing groups (which would
      // trigger cascade deletes on player_group associations)
      await db.batch(
        (b) => b.insertAll(
          db.groupTable,
          matches
              .where((match) => match.group != null)
              .map(
                (matches) => GroupTableCompanion.insert(
                  id: matches.group!.id,
                  name: matches.group!.name,
                  createdAt: matches.group!.createdAt,
                ),
              )
              .toList(),
          mode: InsertMode.insertOrIgnore,
        ),
      );

      // Add all players of the matches in batch (unique)
      final uniquePlayers = <String, Player>{};
      for (final match in matches) {
        if (match.players != null) {
          for (final p in match.players!) {
            uniquePlayers[p.id] = p;
          }
        }
        // Also include members of groups
        if (match.group != null) {
          for (final m in match.group!.members) {
            uniquePlayers[m.id] = m;
          }
        }
      }

      if (uniquePlayers.isNotEmpty) {
        // Using insertOrIgnore to avoid triggering cascade deletes on
        // player_group/player_match associations when players already exist
        await db.batch(
          (b) => b.insertAll(
            db.playerTable,
            uniquePlayers.values
                .map(
                  (p) => PlayerTableCompanion.insert(
                    id: p.id,
                    name: p.name,
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
          if (match.players != null) {
            for (final p in match.players ?? []) {
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

      // Add all group-match associations in batch
      await db.batch((b) {
        for (final match in matches) {
          if (match.group != null) {
            b.insert(
              db.groupMatchTable,
              GroupMatchTableCompanion.insert(
                matchId: match.id,
                groupId: match.group!.id,
              ),
              mode: InsertMode.insertOrIgnore,
            );
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

  /// Sets the winner of the match with the given [matchId] to the player with
  /// the given [winnerId].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> setWinner({
    required String matchId,
    required String winnerId,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(winnerId: Value(winnerId)),
    );
    return rowsAffected > 0;
  }

  /// Retrieves the winner of the match with the given [matchId].
  /// Returns the [Player] who won the match, or `null` if no winner is set.
  Future<Player?> getWinner({required String matchId}) async {
    final query = select(matchTable)..where((g) => g.id.equals(matchId));
    final result = await query.getSingleOrNull();
    if (result == null || result.winnerId == null) {
      return null;
    }
    final winner = await db.playerDao.getPlayerById(playerId: result.winnerId!);
    return winner;
  }

  /// Removes the winner of the match with the given [matchId].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> removeWinner({required String matchId}) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      const MatchTableCompanion(winnerId: Value(null)),
    );
    return rowsAffected > 0;
  }

  /// Checks if the match with the given [matchId] has a winner set.
  /// Returns `true` if a winner is set, otherwise `false`.
  Future<bool> hasWinner({required String matchId}) async {
    final query = select(matchTable)
      ..where((g) => g.id.equals(matchId) & g.winnerId.isNotNull());
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Changes the title of the match with the given [matchId] to [newName].
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
}
