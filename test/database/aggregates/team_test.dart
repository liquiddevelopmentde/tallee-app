import 'dart:core' hide Match;

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
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
  late Team testTeam4;
  late Game testGame;
  late Match testMatch1;
  late Match testMatch2;
  late Match matchWithNoTeams;
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
      testPlayer1 = Player(name: 'Alice');
      testPlayer2 = Player(name: 'Bob');
      testPlayer3 = Player(name: 'Charlie');
      testPlayer4 = Player(name: 'Diana');
      testTeam1 = Team(name: 'Team Alpha', members: [testPlayer1, testPlayer2]);
      testTeam2 = Team(name: 'Team Beta', members: [testPlayer3, testPlayer4]);
      testTeam3 = Team(name: 'Team Gamma', members: [testPlayer1, testPlayer3]);
      testTeam4 = Team(name: 'Team Omega', members: [testPlayer2, testPlayer4]);
      testGame = Game(
        name: 'Test Game',
        ruleset: Ruleset.highestScore,
        color: AppColor.blue,
        icon: '',
      );
      testMatch1 = Match(
        name: 'Match 1',
        game: testGame,
        players: [],
        teams: [testTeam1, testTeam2],
      );
      testMatch2 = Match(
        name: 'Match 2',
        game: testGame,
        players: [],
        teams: [testTeam3, testTeam4],
      );
      matchWithNoTeams = Match(
        name: 'Match with no teams',
        game: testGame,
        players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
      );
    });
    await database.gameDao.addGame(game: testGame);
    await database.playerDao.addPlayersAsList(
      players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('Team Tests', () {
    group('CREATE', () {
      test('Adding and fetching a single team works correctly', () async {
        await database.matchDao.addMatch(match: matchWithNoTeams);
        final added = await database.teamDao.addTeam(
          team: testTeam1,
          matchId: matchWithNoTeams.id,
        );
        expect(added, isTrue);

        final fetchedTeam = await database.teamDao.getTeamById(
          teamId: testTeam1.id,
        );

        expect(fetchedTeam.id, testTeam1.id);
        expect(fetchedTeam.name, testTeam1.name);
        expect(fetchedTeam.createdAt, testTeam1.createdAt);
        expect(fetchedTeam.members.length, testTeam1.members.length);
        for (int i = 0; i < fetchedTeam.members.length; i++) {
          expect(fetchedTeam.members[i].id, testTeam1.members[i].id);
          expect(fetchedTeam.members[i].name, testTeam1.members[i].name);
        }
      });

      test('Adding and fetching multiple teams works correctly', () async {
        await database.matchDao.addMatch(match: matchWithNoTeams);
        await database.teamDao.addTeamsAsList(
          teams: [testTeam1, testTeam2, testTeam3],
          matchId: matchWithNoTeams.id,
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

      test('addTeam() ignores duplicates', () async {
        await database.matchDao.addMatch(match: matchWithNoTeams);
        var added = await database.teamDao.addTeam(
          team: testTeam1,
          matchId: matchWithNoTeams.id,
        );
        expect(added, isTrue);

        added = await database.teamDao.addTeam(
          team: testTeam1,
          matchId: matchWithNoTeams.id,
        );
        expect(added, isFalse);

        final teamCount = await database.teamDao.getTeamCount();
        expect(teamCount, 1);
      });

      test('addTeamsAsList() with empty list returns isFalse', () async {
        final added = await database.teamDao.addTeamsAsList(
          teams: [],
          matchId: matchWithNoTeams.id,
        );
        expect(added, isFalse);
      });

      test('addTeamsAsList() ignores duplicates', () async {
        await database.matchDao.addMatch(match: matchWithNoTeams);
        final added = await database.teamDao.addTeamsAsList(
          teams: [testTeam1, testTeam2, testTeam1],
          matchId: matchWithNoTeams.id,
        );
        expect(added, isTrue);

        final teamCount = await database.teamDao.getTeamCount();
        expect(teamCount, 2);
      });
    });

    group('READ', () {
      test('getTeamCount works correctly', () async {
        var count = await database.teamDao.getTeamCount();
        expect(count, 0);

        await database.matchDao.addMatch(match: testMatch1);

        count = await database.teamDao.getTeamCount();
        expect(count, 2);

        await database.teamDao.addTeam(
          team: testTeam2,
          matchId: matchWithNoTeams.id,
        );

        count = await database.teamDao.getTeamCount();
        expect(count, 2);

        await database.teamDao.deleteTeam(teamId: testTeam1.id);

        count = await database.teamDao.getTeamCount();
        expect(count, 1);

        await database.teamDao.deleteTeam(teamId: testTeam2.id);

        count = await database.teamDao.getTeamCount();
        expect(count, 0);
      });

      test('teamExists() works correctly', () async {
        var teamExists = await database.teamDao.teamExists(
          teamId: testTeam1.id,
        );
        expect(teamExists, isFalse);

        await database.matchDao.addMatch(match: matchWithNoTeams);

        await database.teamDao.addTeam(
          team: testTeam1,
          matchId: matchWithNoTeams.id,
        );

        teamExists = await database.teamDao.teamExists(teamId: testTeam1.id);
        expect(teamExists, isTrue);
      });

      test('getAllTeams() with no teams returns empty list', () async {
        final allTeams = await database.teamDao.getAllTeams();
        expect(allTeams, isA<List<Team>>());
        expect(allTeams.isEmpty, isTrue);
      });

      test('getAllTeams() works correctly', () async {
        await database.matchDao.addMatch(match: matchWithNoTeams);

        await database.teamDao.addTeamsAsList(
          teams: [testTeam1, testTeam2, testTeam3],
          matchId: matchWithNoTeams.id,
        );

        final allTeams = await database.teamDao.getAllTeams();

        expect(allTeams.length, 3);
        expect(allTeams.map((t) => t.id).toSet(), {
          testTeam1.id,
          testTeam2.id,
          testTeam3.id,
        });
      });

      test('Getting non-existent team throws exception', () async {
        expect(
          () => database.teamDao.getTeamById(teamId: 'non-existent-id'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('UPDATED', () {
      test('updateTeamName() works correctly', () async {
        await database.matchDao.addMatch(match: matchWithNoTeams);

        await database.teamDao.addTeam(
          team: testTeam1,
          matchId: matchWithNoTeams.id,
        );

        var fetchedTeam = await database.teamDao.getTeamById(
          teamId: testTeam1.id,
        );
        expect(fetchedTeam.name, testTeam1.name);

        const newName = 'New name';
        await database.teamDao.updateTeamName(
          teamId: testTeam1.id,
          name: newName,
        );

        fetchedTeam = await database.teamDao.getTeamById(teamId: testTeam1.id);
        expect(fetchedTeam.name, newName);

        final match = await database.matchDao.getMatchById(
          matchId: matchWithNoTeams.id,
        );
        expect(match.endedAt, isNull);
      });

      test('updateTeamName() does nothing for non-existent team', () async {
        final updated = await database.teamDao.updateTeamName(
          teamId: 'non-existing-id',
          name: 'New Name',
        );
        expect(updated, isFalse);

        final allTeams = await database.teamDao.getAllTeams();
        expect(allTeams, isEmpty);
      });
    });

    group('DELETE', () {
      test('deleteTeam() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);
        await database.matchDao.addMatch(match: matchWithNoTeams);

        await database.teamDao.addTeam(
          team: testTeam1,
          matchId: matchWithNoTeams.id,
        );

        final deleted = await database.teamDao.deleteTeam(teamId: testTeam1.id);
        expect(deleted, isTrue);

        final teamExists = await database.teamDao.teamExists(
          teamId: testTeam1.id,
        );
        expect(teamExists, isFalse);
      });

      test('Deleting a non-existent team returns isFalse', () async {
        final deleted = await database.teamDao.deleteTeam(
          teamId: 'non-existent-id',
        );
        expect(deleted, isFalse);
      });

      test('deleteAllTeams() works correctly', () async {
        await database.matchDao.addMatchesAsList(
          matches: [testMatch1, testMatch2],
        );
        var teamCount = await database.teamDao.getTeamCount();
        expect(teamCount, 4);

        final deleted = await database.teamDao.deleteAllTeams();
        expect(deleted, isTrue);

        teamCount = await database.teamDao.getTeamCount();
        expect(teamCount, 0);
      });

      test('deleteAllTeams() with empty list returns false', () async {
        final deleted = await database.teamDao.deleteAllTeams();
        expect(deleted, isFalse);
      });
    });

    group('SCORE', () {
      test('updateTeamScore() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final updated = await database.teamDao.updateTeamScore(
          teamId: testTeam1.id,
          matchId: testMatch1.id,
          score: 5,
        );
        expect(updated, isTrue);
        final team = await database.teamDao.getTeamById(teamId: testTeam1.id);
        expect(team.score, 5);

        for (final member in testTeam1.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNotNull);
          expect(entry!.score, 5);
        }
      });

      test('set-/removeWinnerTeam() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final set = await database.teamDao.setWinnerTeam(
          teamId: testTeam1.id,
          matchId: testMatch1.id,
        );
        expect(set, isTrue);

        var team = await database.teamDao.getTeamById(teamId: testTeam1.id);
        expect(team.score, 1);

        for (final member in testTeam1.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNotNull);
          expect(entry!.score, 1);
        }

        var match = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(match.endedAt, isNotNull);

        final removed = await database.teamDao.removeWinnerTeam(
          matchId: testMatch1.id,
        );
        expect(removed, isTrue);

        team = await database.teamDao.getTeamById(teamId: testTeam1.id);
        expect(team.score, isNull);

        for (final member in testTeam1.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNull);
        }

        match = await database.matchDao.getMatchById(matchId: testMatch1.id);
        expect(match.endedAt, isNull);
      });

      test('set-/removeLoserTeam() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final set = await database.teamDao.setLoserTeam(
          teamId: testTeam1.id,
          matchId: testMatch1.id,
        );
        expect(set, isTrue);

        var team = await database.teamDao.getTeamById(teamId: testTeam1.id);
        expect(team.score, 0);

        for (final member in testTeam1.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNotNull);
          expect(entry!.score, 0);
        }

        var match = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(match.endedAt, isNotNull);

        final removed = await database.teamDao.removeLoserTeam(
          matchId: testMatch1.id,
        );
        expect(removed, isTrue);

        team = await database.teamDao.getTeamById(teamId: testTeam1.id);
        expect(team.score, isNull);

        for (final member in testTeam1.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNull);
        }

        match = await database.matchDao.getMatchById(matchId: testMatch1.id);
        expect(match.endedAt, isNull);
      });

      test('set-/removeWinnerTeams() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final set = await database.teamDao.setWinnerTeams(
          winners: [testTeam1, testTeam2],
          matchId: testMatch1.id,
        );
        expect(set, isTrue);

        // check both teams got the winner score
        var team = await database.teamDao.getTeamById(teamId: testTeam1.id);
        expect(team.score, 1);
        team = await database.teamDao.getTeamById(teamId: testTeam2.id);
        expect(team.score, 1);

        // check all members of both teams got the winner score
        for (final member in testTeam1.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNotNull);
          expect(entry!.score, 1);
        }

        var match = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(match.endedAt, isNotNull);

        for (final member in testTeam2.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNotNull);
          expect(entry!.score, 1);
        }

        final removed = await database.teamDao.removeWinnerTeam(
          matchId: testMatch1.id,
        );
        expect(removed, isTrue);

        team = await database.teamDao.getTeamById(teamId: testTeam1.id);
        expect(team.score, isNull);

        team = await database.teamDao.getTeamById(teamId: testTeam2.id);
        expect(team.score, isNull);

        for (final member in testTeam1.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNull);
        }

        for (final member in testTeam2.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNull);
        }

        match = await database.matchDao.getMatchById(matchId: testMatch1.id);
        expect(match.endedAt, isNull);
      });

      test('setTeamPlacements() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final set = await database.teamDao.setTeamPlacements(
          teams: [testTeam1, testTeam2],
          matchId: testMatch1.id,
        );
        expect(set, isTrue);

        var team = await database.teamDao.getTeamById(teamId: testTeam1.id);
        expect(team.score, 2);
        team = await database.teamDao.getTeamById(teamId: testTeam2.id);
        expect(team.score, 1);

        for (final member in testTeam1.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNotNull);
          expect(entry!.score, 2);
        }

        for (final member in testTeam2.members) {
          final entry = await database.scoreEntryDao.getScore(
            playerId: member.id,
            matchId: testMatch1.id,
          );
          expect(entry, isNotNull);
          expect(entry!.score, 1);
        }

        final match = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(match.endedAt, isNotNull);
      });
    });
  });
}
