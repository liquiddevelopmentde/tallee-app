import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/game_table.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/match_table.dart';
import 'package:tallee/data/db/tables/player_match_table.dart';
import 'package:tallee/data/models/models.dart';

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
          isTeamMatch: Value(match.isTeamMatch),
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
                    ruleset: game.ruleset,
                    description: game.description,
                    color: game.color,
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
                  isTeamMatch: Value(match.isTeamMatch),
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
    final row = await query.getSingleOrNull();
    return row != null;
  }

  /// Retrieves the number of matches in the database.
  Future<int> getMatchCount() async {
    final count =
        await (selectOnly(matchTable)..addColumns([matchTable.id.count()]))
            .map((tbl) => tbl.read(matchTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Retrieves all matches from the database.
  /// If [includeDeletedPlayer] is `true`, players that have been marked as
  /// deleted will be included in the match's player list.
  Future<List<Match>> getAllMatches({bool includeDeletedPlayer = false}) async {
    final query = select(matchTable);
    final result = await query.get();

    return _fetchRelationsForMatches(
      result,
      includeDeletedPlayer: includeDeletedPlayer,
    );
  }

  /// Retrieves a [Match] by its [matchId].
  /// If [includeDeletedPlayer] is `true`, players that have been marked as deleted
  /// will be included in the match's player list. Returns `null` if no match
  /// with the given [matchId] is found.
  Future<Match> getMatchById({
    required String matchId,
    bool includeDeletedPlayer = false,
  }) async {
    final query = select(matchTable)..where((g) => g.id.equals(matchId));
    final row = await query.getSingle();

    final matches = await _fetchRelationsForMatches([
      row,
    ], includeDeletedPlayer: includeDeletedPlayer);

    return matches.first;
  }

  /// Retrieves the number of matches associated with a specific game.
  Future<int> getMatchCountByGame({required String gameId}) async {
    final count =
        await (selectOnly(matchTable)
              ..where(matchTable.gameId.equals(gameId))
              ..addColumns([matchTable.id.count()]))
            .map((tbl) => tbl.read(matchTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  Future<List<Match>> getMatchesByPlayer({required String playerId}) async {
    final playerMatches = await (select(
      playerMatchTable,
    )..where((tbl) => tbl.playerId.equals(playerId))).get();

    if (playerMatches.isEmpty) return [];

    final matchIds = playerMatches.map((tbl) => tbl.matchId).toSet().toList();
    final result =
        await (select(matchTable)
              ..where((tbl) => tbl.id.isIn(matchIds))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
            .get();

    return _fetchRelationsForMatches(result, includeDeletedPlayer: true);
  }

  /// Retrieves all matches associated with the given [groupId].
  /// Queries the database directly, filtering by [groupId].
  Future<List<Match>> getMatchesByGroup({required String groupId}) async {
    final query = select(matchTable)..where((m) => m.groupId.equals(groupId));
    final result = await query.get();

    return _fetchRelationsForMatches(result);
  }

  /// Batch fetches all related entities for a list of match rows.
  Future<List<Match>> _fetchRelationsForMatches(
    List<MatchTableData> rows, {
    bool includeDeletedPlayer = false,
  }) async {
    if (rows.isEmpty) return [];

    final matchIds = rows.map((r) => r.id).toList();
    final gameIds = rows.map((r) => r.gameId).toSet().toList();
    final groupIds = rows
        .map((r) => r.groupId)
        .whereType<String>()
        .toSet()
        .toList();

    // Bulk Fetch all relations
    final gamesList = await db.gameDao.getGamesByIds(gameIds: gameIds);
    final gamesMap = {for (final g in gamesList) g.id: g};

    final groupsList = await db.groupDao.getGroupsByIds(groupIds: groupIds);
    final groupsMap = {for (final g in groupsList) g.id: g};

    final playersMap = await db.playerMatchDao.getPlayersForMatches(
      matchIds: matchIds,
      includeDeletedPlayer: includeDeletedPlayer,
    );

    final scoresMap = await db.scoreEntryDao.getScoresForMatches(
      matchIds: matchIds,
    );

    final teamsMap = await db.teamDao.getTeamsForMatches(matchIds: matchIds);

    return rows.map((row) {
      final game = gamesMap[row.gameId];

      return _buildMatchFromRow(
        row: row,
        game: game!,
        players: playersMap[row.id] ?? [],
        group: row.groupId != null ? groupsMap[row.groupId] : null,
        scores: scoresMap[row.id] ?? {},
        teams: teamsMap[row.id],
      );
    }).toList();
  }

  /* Update */

  /// Changes the name of the match with the given [matchId] to [name].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateMatchName({
    required String matchId,
    required String name,
  }) async {
    final query = update(matchTable)..where((tbl) => tbl.id.equals(matchId));
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
    final query = update(matchTable)..where((tbl) => tbl.id.equals(matchId));
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
    final query = update(matchTable)..where((tbl) => tbl.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(notes: Value(notes)),
    );
    return rowsAffected > 0;
  }

  /// Removes the group association of the match with the given [matchId].
  /// Sets the groupId to null.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> removeMatchGroup({required String matchId}) async {
    final query = update(matchTable)..where((tbl) => tbl.id.equals(matchId));
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
    final query = update(matchTable)..where((tbl) => tbl.id.equals(matchId));
    final rowsAffected = await query.write(
      MatchTableCompanion(endedAt: Value(endedAt)),
    );
    return rowsAffected > 0;
  }

  /// Removes the endedAt timestamp of the match with the given [matchId],
  /// marking it as ongoing.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> removeMatchEndedAt({required String matchId}) async {
    final query = update(matchTable)..where((tbl) => tbl.id.equals(matchId));
    final rowsAffected = await query.write(
      const MatchTableCompanion(endedAt: Value(null)),
    );
    return rowsAffected > 0;
  }

  /* Delete */

  /// Deletes the match with the given [matchId] from the database and purges
  /// lone players.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteMatch({required String matchId}) async {
    return db.transaction(() async {
      final query = delete(matchTable)..where((tbl) => tbl.id.equals(matchId));
      final rowsAffected = await query.go();

      if (rowsAffected > 0) {
        await db.playerDao.purgeSoftDeletedPlayer();
      }

      return rowsAffected > 0;
    });
  }

  /// Deletes all matches from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllMatches() async {
    final query = delete(matchTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Deletes all matches associated with a specific game.
  /// Returns the number of matches deleted.
  Future<int> deleteMatchesByGame({required String gameId}) async {
    final query = delete(matchTable)..where((tbl) => tbl.gameId.equals(gameId));
    final rowsAffected = await query.go();
    return rowsAffected;
  }

  /* Helper */

  Match _buildMatchFromRow({
    required MatchTableData row,
    required Game game,
    required List<Player> players,
    Group? group,
    Map<String, ScoreEntry?>? scores,
    List<Team>? teams,
  }) {
    return Match(
      id: row.id,
      name: row.name,
      game: game,
      group: group,
      players: players,
      scores: scores,
      teams: teams,
      isTeamMatch: row.isTeamMatch,
      notes: row.notes,
      createdAt: row.createdAt,
      endedAt: row.endedAt,
    );
  }
}
