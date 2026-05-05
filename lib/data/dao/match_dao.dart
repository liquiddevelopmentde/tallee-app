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
import 'package:tallee/data/models/team.dart';

part 'match_dao.g.dart';

@DriftAccessor(tables: [MatchTable, GameTable, GroupTable, PlayerMatchTable])
class MatchDao extends DatabaseAccessor<AppDatabase> with _$MatchDaoMixin {
  MatchDao(super.db);

  /* Create */

  /// Adds a new [Match] to the database. Also adds players associations and teams.
  /// This method assumes that the game and group (if any) are already present
  /// in the database.
  Future<bool> addMatch({required Match match}) async {
    if (await matchExists(matchId: match.id)) return false;
    await db.transaction(() async {
      await into(matchTable).insert(
        MatchTableCompanion.insert(
          id: match.id,
          gameId: match.game.id,
          groupId: Value(match.group?.id),
          name: match.name,
          notes: match.notes,
          createdAt: match.createdAt,
          endedAt: Value(match.endedAt),
        ),
        mode: InsertMode.insertOrReplace,
      );

      // Add teams
      if (match.teams != null && match.teams!.isNotEmpty) {
        await db.teamDao.addTeamsAsList(teams: match.teams!, matchId: match.id);
      }

      // Collect all player IDs that are already in teams
      final playersInTeams = <String>{};
      if (match.teams != null) {
        for (final team in match.teams!) {
          for (final member in team.members) {
            playersInTeams.add(member.id);
          }
        }
      }

      // Add players that are not in teams
      for (final p in match.players) {
        if (!playersInTeams.contains(p.id)) {
          await db.playerMatchDao.addPlayerToMatch(
            matchId: match.id,
            playerId: p.id,
          );
        }
      }

      for (final pid in match.scores.keys) {
        final playerScores = match.scores[pid];
        if (playerScores != null) {
          await db.scoreEntryDao.addScore(
            entry: playerScores,
            playerId: pid,
            matchId: match.id,
          );
        }
      }
    });
    return true;
  }

  /// Adds multiple [Match]es to the database in a batch operation.
  /// Also adds associated players and groups if they exist.
  /// If the [matches] list is empty, the method returns immediately.
  /// This method should only be used to import matches from a different device.
  Future<bool> addMatchesAsList({required List<Match> matches}) async {
    if (matches.isEmpty) return false;
    await db.transaction(() async {
      // Add all games first (deduplicated)
      final uniqueGames = <String, Game>{};
      for (final match in matches) {
        uniqueGames[match.game.id] = match.game;
      }

      // Add games
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

      // Add groups
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

      // Add matches
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
                  notes: match.notes,
                  createdAt: match.createdAt,
                  endedAt: Value(match.endedAt),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        ),
      );

      // Add players
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

      await db.batch((b) {
        for (final match in matches) {
          for (final entry in match.scores.entries) {
            if (entry.value != null) {
              b.insert(
                db.scoreEntryTable,
                ScoreEntryTableCompanion.insert(
                  matchId: match.id,
                  playerId: entry.key,
                  score: entry.value!.score,
                  roundNumber: entry.value!.roundNumber,
                  change: entry.value!.change,
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        }
      });

      // Add player-match associations
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

      // Add player-group associations
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

      // Add teams for matches
      for (final match in matches) {
        if (match.teams != null && match.teams!.isNotEmpty) {
          await db.teamDao.addTeamsAsList(
            teams: match.teams!,
            matchId: match.id,
          );
        }
      }
    });
    return true;
  }

  /* Read */

  /// Checks if a match with the given [matchId] exists in the database.
  /// Returns `true` if the match exists, otherwise `false`.
  Future<bool> matchExists({required String matchId}) async {
    final query = select(matchTable)..where((g) => g.id.equals(matchId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Retrieves the number of matches in the database.
  Future<int> getMatchCount() async {
    final count =
        await (selectOnly(matchTable)..addColumns([matchTable.id.count()]))
            .map((row) => row.read(matchTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

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
        final players = await db.playerMatchDao.getPlayersOfMatch(
          matchId: row.id,
        );

        final scores = await db.scoreEntryDao.getAllMatchScores(
          matchId: row.id,
        );

        final teams = await _getMatchTeams(matchId: row.id);

        return Match(
          id: row.id,
          name: row.name,
          game: game,
          group: group,
          players: players,
          teams: teams.isEmpty ? null : teams,
          notes: row.notes,
          createdAt: row.createdAt,
          endedAt: row.endedAt,
          scores: scores,
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

    final players = await db.playerMatchDao.getPlayersOfMatch(matchId: matchId);

    final scores = await db.scoreEntryDao.getAllMatchScores(matchId: matchId);

    final teams = await _getMatchTeams(matchId: matchId);

    return Match(
      id: result.id,
      name: result.name,
      game: game,
      group: group,
      players: players,
      teams: teams.isEmpty ? null : teams,
      notes: result.notes,
      createdAt: result.createdAt,
      endedAt: result.endedAt,
      scores: scores,
    );
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
        final players = await db.playerMatchDao.getPlayersOfMatch(
          matchId: row.id,
        );
        final teams = await _getMatchTeams(matchId: row.id);
        return Match(
          id: row.id,
          name: row.name,
          game: game,
          group: group,
          players: players,
          teams: teams.isEmpty ? null : teams,
          notes: row.notes,
          createdAt: row.createdAt,
          endedAt: row.endedAt,
        );
      }),
    );
  }

  /// Helper method to retrieve teams for a specific match
  Future<List<Team>> _getMatchTeams({required String matchId}) async {
    // Get all unique team IDs from PlayerMatchTable for this match
    final playerMatchQuery = select(db.playerMatchTable)
      ..where((pm) => pm.matchId.equals(matchId) & pm.teamId.isNotNull());
    final playerMatches = await playerMatchQuery.get();

    if (playerMatches.isEmpty) return [];

    final teamIds = playerMatches
        .map((pm) => pm.teamId)
        .whereType<String>()
        .toSet()
        .toList();

    // Fetch all teams
    final teams = await Future.wait(
      teamIds.map((teamId) => db.teamDao.getTeamById(teamId: teamId)),
    );

    return teams;
  }

  /* Update */

  /// Changes the name of the match with the given [matchId] to [name].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchName({
    required String matchId,
    required String name,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(name: Value(name)),
    );
    return rowsAffected > 0;
  }

  /// Updates the group of the match with the given [matchId].
  /// Replaces the existing group association with the new group specified by [groupId].
  /// Pass null to remove the group association.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchGroup({
    required String matchId,
    required String? groupId,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(groupId: Value(groupId)),
    );
    return rowsAffected > 0;
  }

  /// Updates the notes of the match with the given [matchId].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchNotes({
    required String matchId,
    required String notes,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(notes: Value(notes)),
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

  /// Updates the endedAt timestamp of the match with the given [matchId].
  /// Pass null to remove the ended time (mark match as ongoing).
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchEndedAt({
    required String matchId,
    required DateTime endedAt,
  }) async {
    final query = update(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(endedAt: Value(endedAt)),
    );
    return rowsAffected > 0;
  }

  /* Delete */

  /// Deletes the match with the given [matchId] from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteMatch({required String matchId}) async {
    final query = delete(matchTable)..where((g) => g.id.equals(matchId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Deletes all matches from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllMatches() async {
    final query = delete(matchTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }
}
