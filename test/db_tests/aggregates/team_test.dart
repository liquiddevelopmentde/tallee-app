import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Team testTeam1;
  late Team testTeam2;
  late Team testTeam3;
  late Game testGame1;
  late Game testGame2;
  final fixedDate = DateTime(2025, 11, 19, 00, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() async {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        // Recommended for widget tests to avoid test errors.
        closeStreamsSynchronously: true,
      ),
    );

    withClock(fakeClock, () {
      testPlayer1 = Player(name: 'Alice', description: '');
      testPlayer2 = Player(name: 'Bob', description: '');
      testPlayer3 = Player(name: 'Charlie', description: '');
      testPlayer4 = Player(name: 'Diana', description: '');
      testTeam1 = Team(name: 'Team Alpha', members: [testPlayer1, testPlayer2]);
      testTeam2 = Team(name: 'Team Beta', members: [testPlayer3, testPlayer4]);
      testTeam3 = Team(name: 'Team Gamma', members: [testPlayer1, testPlayer3]);
      testGame1 = Game(
        name: 'Game 1',
        ruleset: Ruleset.singleWinner,
        description: 'Test game 1',
        color: GameColor.blue,
        icon: '',
      );
      testGame2 = Game(
        name: 'Game 2',
        ruleset: Ruleset.highestScore,
        description: 'Test game 2',
        color: GameColor.red,
        icon: '',
      );
    });

    await database.playerDao.addPlayersAsList(
      players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
    );
    await database.gameDao.addGame(game: testGame1);
    await database.gameDao.addGame(game: testGame2);
  });

  tearDown(() async {
    await database.close();
  });

  group('Team Tests', () {
    // Verifies that a single team can be added and retrieved with all fields intact.
    test('Adding and fetching a single team works correctly', () async {
      final added = await database.teamDao.addTeam(team: testTeam1);
      expect(added, true);

      final fetchedTeam = await database.teamDao.getTeamById(
        teamId: testTeam1.id,
      );

      expect(fetchedTeam.id, testTeam1.id);
      expect(fetchedTeam.name, testTeam1.name);
      expect(fetchedTeam.createdAt, testTeam1.createdAt);
    });

    // Verifies that multiple teams can be added at once and retrieved correctly.
    test('Adding and fetching multiple teams works correctly', () async {
      await database.teamDao.addTeamsAsList(
        teams: [testTeam1, testTeam2, testTeam3],
      );

      final allTeams = await database.teamDao.getAllTeams();
      expect(allTeams.length, 3);

      final testTeams = {
        testTeam1.id: testTeam1,
        testTeam2.id: testTeam2,
        testTeam3.id: testTeam3,
      };

      for (final team in allTeams) {
        final testTeam = testTeams[team.id]!;

        expect(team.id, testTeam.id);
        expect(team.name, testTeam.name);
        expect(team.createdAt, testTeam.createdAt);
      }
    });

    // Verifies that adding the same team twice does not create duplicates and returns false.
    test('Adding the same team twice does not create duplicates', () async {
      await database.teamDao.addTeam(team: testTeam1);
      final addedAgain = await database.teamDao.addTeam(team: testTeam1);

      expect(addedAgain, false);

      final teamCount = await database.teamDao.getTeamCount();
      expect(teamCount, 1);
    });

    // Verifies that teamExists returns correct boolean based on team presence.
    test('Team existence check works correctly', () async {
      var teamExists = await database.teamDao.teamExists(teamId: testTeam1.id);
      expect(teamExists, false);

      await database.teamDao.addTeam(team: testTeam1);

      teamExists = await database.teamDao.teamExists(teamId: testTeam1.id);
      expect(teamExists, true);
    });

    // Verifies that deleteTeam removes the team and returns true.
    test('Deleting a team works correctly', () async {
      await database.teamDao.addTeam(team: testTeam1);

      final teamDeleted = await database.teamDao.deleteTeam(
        teamId: testTeam1.id,
      );
      expect(teamDeleted, true);

      final teamExists = await database.teamDao.teamExists(
        teamId: testTeam1.id,
      );
      expect(teamExists, false);
    });

    // Verifies that deleteTeam returns false for a non-existent team ID.
    test('Deleting a non-existent team returns false', () async {
      final teamDeleted = await database.teamDao.deleteTeam(
        teamId: 'non-existent-id',
      );
      expect(teamDeleted, false);
    });

    // Verifies that getTeamCount returns correct count through add/delete operations.
    test('Getting the team count works correctly', () async {
      var teamCount = await database.teamDao.getTeamCount();
      expect(teamCount, 0);

      await database.teamDao.addTeam(team: testTeam1);

      teamCount = await database.teamDao.getTeamCount();
      expect(teamCount, 1);

      await database.teamDao.addTeam(team: testTeam2);

      teamCount = await database.teamDao.getTeamCount();
      expect(teamCount, 2);

      await database.teamDao.deleteTeam(teamId: testTeam1.id);

      teamCount = await database.teamDao.getTeamCount();
      expect(teamCount, 1);

      await database.teamDao.deleteTeam(teamId: testTeam2.id);

      teamCount = await database.teamDao.getTeamCount();
      expect(teamCount, 0);
    });

    // Verifies that updateTeamName correctly updates only the name field.
    test('Updating team name works correctly', () async {
      await database.teamDao.addTeam(team: testTeam1);

      var fetchedTeam = await database.teamDao.getTeamById(
        teamId: testTeam1.id,
      );
      expect(fetchedTeam.name, testTeam1.name);

      const newName = 'Updated Team Name';
      await database.teamDao.updateTeamName(
        teamId: testTeam1.id,
        newName: newName,
      );

      fetchedTeam = await database.teamDao.getTeamById(teamId: testTeam1.id);
      expect(fetchedTeam.name, newName);
    });

    // Verifies that deleteAllTeams removes all teams from the database.
    test('Deleting all teams works correctly', () async {
      await database.teamDao.addTeamsAsList(
        teams: [testTeam1, testTeam2, testTeam3],
      );

      var teamCount = await database.teamDao.getTeamCount();
      expect(teamCount, 3);

      final deleted = await database.teamDao.deleteAllTeams();
      expect(deleted, true);

      teamCount = await database.teamDao.getTeamCount();
      expect(teamCount, 0);
    });

    // Verifies that deleteAllTeams returns false when no teams exist.
    test('Deleting all teams when empty returns false', () async {
      final deleted = await database.teamDao.deleteAllTeams();
      expect(deleted, false);
    });

    // Verifies that addTeamsAsList returns false when given an empty list.
    test('Adding teams as list with empty list returns false', () async {
      final added = await database.teamDao.addTeamsAsList(teams: []);
      expect(added, false);
    });

    // Verifies that addTeamsAsList with duplicate IDs ignores duplicates and keeps the first.
    test('Adding teams with duplicate IDs ignores duplicates', () async {
      final duplicateTeam = Team(
        id: testTeam1.id,
        name: 'Duplicate Team',
        members: [testPlayer4],
      );

      await database.teamDao.addTeamsAsList(
        teams: [testTeam1, duplicateTeam, testTeam2],
      );

      final teamCount = await database.teamDao.getTeamCount();
      expect(teamCount, 2);

      // The first one should be kept (insertOrIgnore)
      final fetchedTeam = await database.teamDao.getTeamById(
        teamId: testTeam1.id,
      );
      expect(fetchedTeam.name, testTeam1.name);
    });

    // Verifies that getAllTeams returns empty list when no teams exist.
    test('Getting all teams when empty returns empty list', () async {
      final allTeams = await database.teamDao.getAllTeams();
      expect(allTeams.isEmpty, true);
    });

    // Verifies that getTeamById throws exception for non-existent team.
    test('Getting non-existent team throws exception', () async {
      expect(
        () => database.teamDao.getTeamById(teamId: 'non-existent-id'),
        throwsA(isA<StateError>()),
      );
    });

    // Verifies that updating team name preserves other fields.
    test('Updating team name preserves other team fields', () async {
      await database.teamDao.addTeam(team: testTeam1);
      final originalTeam = await database.teamDao.getTeamById(
        teamId: testTeam1.id,
      );
      final originalCreatedAt = originalTeam.createdAt;

      const newName = 'Brand New Team Name';
      await database.teamDao.updateTeamName(
        teamId: testTeam1.id,
        newName: newName,
      );

      final updatedTeam = await database.teamDao.getTeamById(
        teamId: testTeam1.id,
      );

      expect(updatedTeam.name, newName);
      expect(updatedTeam.id, testTeam1.id);
      expect(updatedTeam.createdAt, originalCreatedAt);
    });

    // Verifies that team name can be updated to an empty string.
    test('Updating team name to empty string works', () async {
      await database.teamDao.addTeam(team: testTeam1);

      await database.teamDao.updateTeamName(teamId: testTeam1.id, newName: '');

      final updatedTeam = await database.teamDao.getTeamById(
        teamId: testTeam1.id,
      );

      expect(updatedTeam.name, '');
    });

    // Verifies that team name can be updated to a very long string.
    test('Updating team name to long string works', () async {
      await database.teamDao.addTeam(team: testTeam1);
      final longName = 'A' * 500; // 500 character name

      await database.teamDao.updateTeamName(
        teamId: testTeam1.id,
        newName: longName,
      );

      final updatedTeam = await database.teamDao.getTeamById(
        teamId: testTeam1.id,
      );

      expect(updatedTeam.name, longName);
      expect(updatedTeam.name.length, 500);
    });

    // Verifies that updating non-existent team name doesn't throw error.
    test('Updating non-existent team name completes without error', () async {
      expect(
        () => database.teamDao.updateTeamName(
          teamId: 'non-existent-id',
          newName: 'New Name',
        ),
        returnsNormally,
      );
    });

    // Verifies that deleteTeam only affects the specified team.
    test('Deleting one team does not affect other teams', () async {
      await database.teamDao.addTeamsAsList(
        teams: [testTeam1, testTeam2, testTeam3],
      );

      await database.teamDao.deleteTeam(teamId: testTeam2.id);

      final allTeams = await database.teamDao.getAllTeams();
      expect(allTeams.length, 2);
      expect(allTeams.any((t) => t.id == testTeam1.id), true);
      expect(allTeams.any((t) => t.id == testTeam2.id), false);
      expect(allTeams.any((t) => t.id == testTeam3.id), true);
    });

    // Verifies that teams with overlapping members are independent.
    test('Teams with overlapping members are independent', () async {
      // Create two matches since player_match has primary key {playerId, matchId}
      final match1 = Match(name: 'Match 1', game: testGame1, notes: '');
      final match2 = Match(name: 'Match 2', game: testGame2, notes: '');
      await database.matchDao.addMatch(match: match1);
      await database.matchDao.addMatch(match: match2);

      // Add teams to database
      await database.teamDao.addTeamsAsList(teams: [testTeam1, testTeam3]);

      // Associate players with teams through match1
      // testTeam1: player1, player2
      await database.playerMatchDao.addPlayerToMatch(
        playerId: testPlayer1.id,
        matchId: match1.id,
        teamId: testTeam1.id,
      );
      await database.playerMatchDao.addPlayerToMatch(
        playerId: testPlayer2.id,
        matchId: match1.id,
        teamId: testTeam1.id,
      );

      // Associate players with teams through match2
      // testTeam3: player1, player3 (overlapping player1)
      await database.playerMatchDao.addPlayerToMatch(
        playerId: testPlayer1.id,
        matchId: match2.id,
        teamId: testTeam3.id,
      );
      await database.playerMatchDao.addPlayerToMatch(
        playerId: testPlayer3.id,
        matchId: match2.id,
        teamId: testTeam3.id,
      );

      final team1 = await database.teamDao.getTeamById(teamId: testTeam1.id);
      final team3 = await database.teamDao.getTeamById(teamId: testTeam3.id);

      expect(team1.members.length, 2);
      expect(team3.members.length, 2);
      expect(team1.members.any((p) => p.id == testPlayer1.id), true);
      expect(team3.members.any((p) => p.id == testPlayer1.id), true);
    });

    // Verifies that adding teams sequentially works correctly.
    test('Adding teams sequentially maintains correct count', () async {
      var count = await database.teamDao.getTeamCount();
      expect(count, 0);

      await database.teamDao.addTeam(team: testTeam1);
      count = await database.teamDao.getTeamCount();
      expect(count, 1);

      await database.teamDao.addTeam(team: testTeam2);
      count = await database.teamDao.getTeamCount();
      expect(count, 2);

      await database.teamDao.addTeam(team: testTeam3);
      count = await database.teamDao.getTeamCount();
      expect(count, 3);
    });

    // Verifies that getAllTeams returns all teams with correct data.
    test('Getting all teams returns all teams with correct data', () async {
      await database.teamDao.addTeamsAsList(
        teams: [testTeam1, testTeam2, testTeam3],
      );

      final allTeams = await database.teamDao.getAllTeams();

      expect(allTeams.length, 3);
      expect(allTeams.map((t) => t.id).toSet(), {
        testTeam1.id,
        testTeam2.id,
        testTeam3.id,
      });
    });

    // Verifies that teamExists returns false for deleted teams.
    test('Team existence returns false after deletion', () async {
      await database.teamDao.addTeam(team: testTeam1);
      expect(await database.teamDao.teamExists(teamId: testTeam1.id), true);

      await database.teamDao.deleteTeam(teamId: testTeam1.id);
      expect(await database.teamDao.teamExists(teamId: testTeam1.id), false);
    });

    // Verifies that adding multiple teams in batch then deleting returns correct count.
    test('Batch add then partial delete maintains correct count', () async {
      await database.teamDao.addTeamsAsList(
        teams: [testTeam1, testTeam2, testTeam3],
      );

      expect(await database.teamDao.getTeamCount(), 3);

      await database.teamDao.deleteTeam(teamId: testTeam1.id);
      expect(await database.teamDao.getTeamCount(), 2);

      await database.teamDao.deleteTeam(teamId: testTeam3.id);
      expect(await database.teamDao.getTeamCount(), 1);
    });

    // Verifies that deleteAllTeams with single team works.
    test('Deleting all teams with single team returns true', () async {
      await database.teamDao.addTeam(team: testTeam1);
      expect(await database.teamDao.getTeamCount(), 1);

      final deleted = await database.teamDao.deleteAllTeams();
      expect(deleted, true);
      expect(await database.teamDao.getTeamCount(), 0);
    });

    // Verifies that addTeam after deleteAllTeams works correctly.
    test('Adding team after deleteAllTeams works correctly', () async {
      await database.teamDao.addTeamsAsList(teams: [testTeam1, testTeam2]);
      expect(await database.teamDao.getTeamCount(), 2);

      await database.teamDao.deleteAllTeams();
      expect(await database.teamDao.getTeamCount(), 0);

      final added = await database.teamDao.addTeam(team: testTeam3);
      expect(added, true);
      expect(await database.teamDao.getTeamCount(), 1);

      final fetchedTeam = await database.teamDao.getTeamById(
        teamId: testTeam3.id,
      );
      expect(fetchedTeam.name, testTeam3.name);
    });

    // Verifies that addTeamsAsList with partial duplicates ignores duplicates.
    test('Adding teams with some duplicates ignores only duplicates', () async {
      await database.teamDao.addTeam(team: testTeam1);

      final duplicateTeam1 = Team(
        id: testTeam1.id,
        name: 'Different Name',
        members: [testPlayer3],
      );

      await database.teamDao.addTeamsAsList(
        teams: [duplicateTeam1, testTeam2, testTeam3],
      );

      final allTeams = await database.teamDao.getAllTeams();
      expect(allTeams.length, 3);

      // Verify testTeam1 retained original name (was inserted first)
      final team1 = await database.teamDao.getTeamById(teamId: testTeam1.id);
      expect(team1.name, testTeam1.name);
    });

    // Verifies that team IDs are preserved correctly.
    test('Team IDs are preserved through add and retrieve', () async {
      await database.teamDao.addTeam(team: testTeam1);

      final fetchedTeam = await database.teamDao.getTeamById(
        teamId: testTeam1.id,
      );

      expect(fetchedTeam.id, testTeam1.id);
    });

    // Verifies that createdAt timestamps are preserved.
    test('Team createdAt timestamps are preserved', () async {
      await database.teamDao.addTeam(team: testTeam1);

      final fetchedTeam = await database.teamDao.getTeamById(
        teamId: testTeam1.id,
      );

      expect(fetchedTeam.createdAt, testTeam1.createdAt);
    });
  });
}
