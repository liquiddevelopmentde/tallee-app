import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/player_match_table.dart';
import 'package:tallee/data/db/tables/team_table.dart';
import 'package:tallee/data/models/player.dart';
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
          members: members,
        );
      }),
    );
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
    return players;
  }

  /* Update */

  /// Updates the name of the team with the given [teamId].
  Future<bool> updateTeamName({
    required String teamId,
    required String newName,
  }) async {
    final rowsAffected =
        await (update(teamTable)..where((t) => t.id.equals(teamId))).write(
          TeamTableCompanion(name: Value(newName)),
        );
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
}
