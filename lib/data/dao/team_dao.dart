import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/player_match_table.dart';
import 'package:tallee/data/db/tables/team_table.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';
import 'package:tallee/data/models/team.dart';

part 'team_dao.g.dart';

@DriftAccessor(tables: [TeamTable, PlayerMatchTable])
class TeamDao extends DatabaseAccessor<AppDatabase> with _$TeamDaoMixin {
  TeamDao(super.db);

  /* Create */

  /// Adds a new [team] to the database.
  /// Returns `true` if the team was added, `false` otherwise.
  Future<bool> addTeam({required Team team, required String matchId}) async {
    if (await teamExists(teamId: team.id)) return false;
    await into(teamTable).insert(
      TeamTableCompanion.insert(
        id: team.id,
        name: team.name,
        createdAt: team.createdAt,
        color: Value(team.color.name),
        score: Value(team.score),
      ),
      mode: InsertMode.insertOrReplace,
    );
    await db.batch((batch) async {
      for (final player in team.members) {
        await into(playerMatchTable).insert(
          PlayerMatchTableCompanion.insert(
            playerId: player.id,
            matchId: matchId,
            teamId: Value(team.id),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    return true;
  }

  /// Adds multiple [teams] to the database in a batch operation.
  Future<bool> addTeamsAsList({
    required List<Team> teams,
    required String matchId,
  }) async {
    if (teams.isEmpty) return false;

    await db.batch(
      (b) => b.insertAll(
        teamTable,
        teams
            .map(
              (team) => TeamTableCompanion.insert(
                id: team.id,
                name: team.name,
                createdAt: team.createdAt,
                color: Value(team.color.name),
                score: Value(team.score),
              ),
            )
            .toList(),
        mode: InsertMode.insertOrIgnore,
      ),
    );

    for (final team in teams) {
      await db.batch((batch) async {
        for (final player in team.members) {
          await into(db.playerMatchTable).insert(
            PlayerMatchTableCompanion.insert(
              playerId: player.id,
              matchId: matchId,
              teamId: Value(team.id),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    }
    return true;
  }

  /* Read */

  /// Retrieves the total count of teams in the database.
  Future<int> getTeamCount() async {
    final count =
        await (selectOnly(teamTable)..addColumns([teamTable.id.count()]))
            .map((row) => row.read(teamTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Checks if a team with the given [teamId] exists in the database.
  /// Returns `true` if the team exists, `false` otherwise.
  Future<bool> teamExists({required String teamId}) async {
    final query = select(teamTable)..where((t) => t.id.equals(teamId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Retrieves all teams from the database.
  Future<List<Team>> getAllTeams() async {
    final query = select(teamTable);
    final result = await query.get();
    return Future.wait(
      result.map((row) async {
        final members = await _getTeamMembers(teamId: row.id);
        return Team(
          id: row.id,
          name: row.name,
          createdAt: row.createdAt,
          color: AppColor.values.byName(row.color),
          score: row.score,
          members: members,
        );
      }),
    );
  }

  Future<List<Team>> getTeamsByMatchId({required String matchId}) async {
    final playerMatchQuery = select(db.playerMatchTable)
      ..where((pm) => pm.matchId.equals(matchId));
    final playerMatches = await playerMatchQuery.get();

    if (playerMatches.isEmpty) return [];

    final teamIds = playerMatches
        .map((pm) => pm.teamId)
        .whereType<String>()
        .toSet();

    final teams = await Future.wait(
      teamIds.map((id) => getTeamById(teamId: id)),
    );
    return teams;
  }

  /// Retrieves a [Team] by its [teamId], including its members.
  Future<Team> getTeamById({required String teamId}) async {
    final query = select(teamTable)..where((t) => t.id.equals(teamId));
    final result = await query.getSingle();
    final members = await _getTeamMembers(teamId: teamId);
    return Team(
      id: result.id,
      name: result.name,
      createdAt: result.createdAt,
      color: AppColor.values.byName(result.color),
      score: result.score,
      members: members,
    );
  }

  /// Helper method to get team members from PlayerMatchTable.
  Future<List<Player>> _getTeamMembers({required String teamId}) async {
    // Get all player_match entries with this teamId
    final playerMatchQuery = select(db.playerMatchTable)
      ..where((pm) => pm.teamId.equals(teamId));
    final playerMatches = await playerMatchQuery.get();

    if (playerMatches.isEmpty) return [];

    // Get unique player IDs
    final playerIds = playerMatches.map((pm) => pm.playerId).toSet();

    // Fetch all players
    final players = await Future.wait(
      playerIds.map((id) => db.playerDao.getPlayerById(playerId: id)),
    );
    return players
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /* Update */

  /// Updates the name of the team with the given [teamId].
  Future<bool> updateTeamName({
    required String teamId,
    required String name,
  }) async {
    final rowsAffected =
        await (update(teamTable)..where((t) => t.id.equals(teamId))).write(
          TeamTableCompanion(name: Value(name)),
        );
    return rowsAffected > 0;
  }

  /// Updates the color of the team with the given [teamId].
  Future<bool> updateTeamColor({
    required String teamId,
    required AppColor color,
  }) async {
    final rowsAffected =
        await (update(teamTable)..where((t) => t.id.equals(teamId))).write(
          TeamTableCompanion(color: Value(color.name)),
        );
    return rowsAffected > 0;
  }

  /// Updates the score of the team with the given [teamId].
  /// Updates the member scores correspondingly
  Future<bool> updateTeamScore({
    required String teamId,
    required String matchId,
    required int score,
  }) async {
    await (update(teamTable)..where((t) => t.id.equals(teamId))).write(
      const TeamTableCompanion(score: Value(null)),
    );
    await _deleteAllScoresForMembersOfTeam(teamId: teamId, matchId: matchId);

    final rowsAffected =
        await (update(teamTable)..where((t) => t.id.equals(teamId))).write(
          TeamTableCompanion(score: Value(score)),
        );

    final members = await _getTeamMembers(teamId: teamId);
    for (final member in members) {
      await db.scoreEntryDao.addScore(
        playerId: member.id,
        matchId: matchId,
        entry: ScoreEntry(score: score),
      );
    }

    return rowsAffected > 0;
  }

  Future<bool> removeScoreForTeam({
    required String teamId,
    required String matchId,
  }) async {
    await (update(teamTable)..where((t) => t.id.equals(teamId))).write(
      const TeamTableCompanion(score: Value(null)),
    );
    await _deleteAllScoresForMembersOfTeam(teamId: teamId, matchId: matchId);
    return true;
  }

  /// Removes the scores for all teams in the match with the given [matchId] by setting their scores to null.
  Future<bool> removeAllTeamScores({required String matchId}) async {
    // collect all teamIds for the given matchId from playerMatchTable
    final teamIds =
        await (selectOnly(playerMatchTable)
              ..addColumns([playerMatchTable.teamId])
              ..where(playerMatchTable.matchId.equals(matchId)))
            .map((row) => row.read(playerMatchTable.teamId))
            .get();

    // filter null or duplicates
    final filteredTeamIds = teamIds.whereType<String>().toSet().toList();

    var rowsAffected = 0;
    if (filteredTeamIds.isNotEmpty) {
      rowsAffected =
          await (update(teamTable)..where((t) => t.id.isIn(filteredTeamIds)))
              .write(const TeamTableCompanion(score: Value(null)));
    }
    await db.scoreEntryDao.deleteAllScoresForMatch(matchId: matchId);
    return rowsAffected > 0;
  }

  /* Delete */

  /// Deletes all teams from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllTeams() async {
    final query = delete(teamTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Deletes the team with the given [teamId] from the database.
  /// Returns `true` if the team was deleted, `false` otherwise.
  Future<bool> deleteTeam({required String teamId}) async {
    final query = delete(teamTable)..where((t) => t.id.equals(teamId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /* Score handling */

  /// Sets the team with the given [teamId] as the winner of the match with the given [matchId] by assigning a score of 1.
  /// Returns `true` if the score was updated successfully, `false` otherwise.
  Future<bool> setWinnerTeam({
    required String teamId,
    required String matchId,
  }) async {
    return await updateTeamScore(teamId: teamId, matchId: matchId, score: 1);
  }

  /// Sets multiple teams as winners of the match with the given [matchId] by assigning a score of 1 to each team.
  /// Returns `true` if all scores were updated successfully, `false` otherwise.
  Future<bool> setWinnerTeams({
    required List<Team> winners,
    required String matchId,
  }) async {
    // Reset all team scores .
    await removeAllTeamScores(matchId: matchId);
    // Reset all score entries
    for (final team in winners) {
      await _deleteAllScoresForMembersOfTeam(teamId: team.id, matchId: matchId);
    }

    for (final team in winners) {
      await updateTeamScore(teamId: team.id, matchId: matchId, score: 1);
    }
    return true;
  }

  /// Removes the winner status from all Teams with the given [matchId] by setting its score to null.
  /// Returns `true` if the score was updated successfully, `false` otherwise.
  Future<bool> removeWinnerTeam({required String matchId}) async {
    return await removeAllTeamScores(matchId: matchId);
  }

  /// Sets the team with the given [teamId] as the loser of the match with the given [matchId] by assigning a score of 0.
  /// Returns `true` if the score was updated successfully, `false` otherwise.
  Future<bool> setLoserTeam({
    required String teamId,
    required String matchId,
  }) async {
    return await updateTeamScore(teamId: teamId, matchId: matchId, score: 0);
  }

  /// Removes the loser from the match with the given [matchId] by setting its score to null.
  /// Returns `true` if the score was updated successfully, `false` otherwise.
  Future<bool> removeLoserTeam({required String matchId}) async {
    return await removeAllTeamScores(matchId: matchId);
  }

  /// Sets the placements for the teams in the match with the given [matchId] by assigning scores based on their order in the [teams] list.
  /// Returns `true` if all scores were updated successfully, `false` otherwise.
  Future<bool> setTeamPlacements({
    required String matchId,
    required List<Team> teams,
  }) async {
    List<bool?> success = List.generate(teams.length, (index) => null);
    for (int i = 0; i < teams.length; i++) {
      success[i] = await updateTeamScore(
        matchId: matchId,
        teamId: teams[i].id,
        score: teams.length - i,
      );
    }
    return success.every((result) => result == true);
  }

  /// Helper method to delete all scores for members of a team in a specific match.
  Future<bool> _deleteAllScoresForMembersOfTeam({
    required String teamId,
    required String matchId,
  }) async {
    final playerMatchQuery = select(db.playerMatchTable)
      ..where((pm) => pm.teamId.equals(teamId) & pm.matchId.equals(matchId));
    final playerMatches = await playerMatchQuery.get();

    if (playerMatches.isEmpty) return false;

    for (final pm in playerMatches) {
      await db.scoreEntryDao.deleteAllScoresForPlayerInMatch(
        playerId: pm.playerId,
        matchId: matchId,
      );
    }
    return true;
  }
}
