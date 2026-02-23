import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Player testPlayer5;
  late Group testGroup1;
  late Group testGroup2;
  late Match testMatch1;
  late Match testMatch2;
  late Match testMatchOnlyPlayers;
  late Match testMatchOnlyGroup;
  final fixedDate = DateTime(2025, 19, 11, 00, 11, 23);
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
      testPlayer5 = Player(name: 'Eve');
      testGroup1 = Group(
        name: 'Test Group 2',
        members: [testPlayer1, testPlayer2, testPlayer3],
      );
      testGroup2 = Group(
        name: 'Test Group 2',
        members: [testPlayer4, testPlayer5],
      );
      testMatch1 = Match(
        name: 'First Test Match',
        group: testGroup1,
        players: [testPlayer4, testPlayer5],
        winner: testPlayer4,
      );
      testMatch2 = Match(
        name: 'Second Test Match',
        group: testGroup2,
        players: [testPlayer1, testPlayer2, testPlayer3],
        winner: testPlayer2,
      );
      testMatchOnlyPlayers = Match(
        name: 'Test Match with Players',
        players: [testPlayer1, testPlayer2, testPlayer3],
        winner: testPlayer3,
      );
      testMatchOnlyGroup = Match(
        name: 'Test Match with Group',
        group: testGroup2,
      );
    });
    await database.playerDao.addPlayersAsList(
      players: [
        testPlayer1,
        testPlayer2,
        testPlayer3,
        testPlayer4,
        testPlayer5,
      ],
    );
    await database.groupDao.addGroupsAsList(groups: [testGroup1, testGroup2]);
  });
  tearDown(() async {
    await database.close();
  });

  group('Match Tests', () {
    test('Adding and fetching single match works correctly', () async {
      await database.matchDao.addMatch(match: testMatch1);

      final result = await database.matchDao.getMatchById(
        matchId: testMatch1.id,
      );

      expect(result.id, testMatch1.id);
      expect(result.name, testMatch1.name);
      expect(result.createdAt, testMatch1.createdAt);

      if (result.winner != null && testMatch1.winner != null) {
        expect(result.winner!.id, testMatch1.winner!.id);
        expect(result.winner!.name, testMatch1.winner!.name);
        expect(result.winner!.createdAt, testMatch1.winner!.createdAt);
      } else {
        expect(result.winner, testMatch1.winner);
      }

      if (result.group != null) {
        expect(result.group!.members.length, testGroup1.members.length);

        for (int i = 0; i < testGroup1.members.length; i++) {
          expect(result.group!.members[i].id, testGroup1.members[i].id);
          expect(result.group!.members[i].name, testGroup1.members[i].name);
        }
      } else {
        fail('Group is null');
      }
      if (result.players != null) {
        expect(result.players!.length, testMatch1.players!.length);

        for (int i = 0; i < testMatch1.players!.length; i++) {
          expect(result.players![i].id, testMatch1.players![i].id);
          expect(result.players![i].name, testMatch1.players![i].name);
          expect(
            result.players![i].createdAt,
            testMatch1.players![i].createdAt,
          );
        }
      } else {
        fail('Players is null');
      }
    });

    test('Adding and fetching multiple matches works correctly', () async {
      await database.matchDao.addMatchAsList(
        matches: [
          testMatch1,
          testMatch2,
          testMatchOnlyGroup,
          testMatchOnlyPlayers,
        ],
      );

      final allMatches = await database.matchDao.getAllMatches();
      expect(allMatches.length, 4);

      final testMatches = {
        testMatch1.id: testMatch1,
        testMatch2.id: testMatch2,
        testMatchOnlyGroup.id: testMatchOnlyGroup,
        testMatchOnlyPlayers.id: testMatchOnlyPlayers,
      };

      for (final match in allMatches) {
        final testMatch = testMatches[match.id]!;

        // Match-Checks
        expect(match.id, testMatch.id);
        expect(match.name, testMatch.name);
        expect(match.createdAt, testMatch.createdAt);
        if (match.winner != null && testMatch.winner != null) {
          expect(match.winner!.id, testMatch.winner!.id);
          expect(match.winner!.name, testMatch.winner!.name);
          expect(match.winner!.createdAt, testMatch.winner!.createdAt);
        } else {
          expect(match.winner, testMatch.winner);
        }

        // Group-Checks
        if (testMatch.group != null) {
          expect(match.group!.id, testMatch.group!.id);
          expect(match.group!.name, testMatch.group!.name);
          expect(match.group!.createdAt, testMatch.group!.createdAt);

          // Group Members-Checks
          expect(match.group!.members.length, testMatch.group!.members.length);
          for (int i = 0; i < testMatch.group!.members.length; i++) {
            expect(match.group!.members[i].id, testMatch.group!.members[i].id);
            expect(
              match.group!.members[i].name,
              testMatch.group!.members[i].name,
            );
            expect(
              match.group!.members[i].createdAt,
              testMatch.group!.members[i].createdAt,
            );
          }
        } else {
          expect(match.group, null);
        }

        // Players-Checks
        if (testMatch.players != null) {
          expect(match.players!.length, testMatch.players!.length);
          for (int i = 0; i < testMatch.players!.length; i++) {
            expect(match.players![i].id, testMatch.players![i].id);
            expect(match.players![i].name, testMatch.players![i].name);
            expect(
              match.players![i].createdAt,
              testMatch.players![i].createdAt,
            );
          }
        } else {
          expect(match.players, null);
        }
      }
    });

    test('Adding the same match twice does not create duplicates', () async {
      await database.matchDao.addMatch(match: testMatch1);
      await database.matchDao.addMatch(match: testMatch1);

      final matchCount = await database.matchDao.getMatchCount();
      expect(matchCount, 1);
    });

    test('Match existence check works correctly', () async {
      var matchExists = await database.matchDao.matchExists(
        matchId: testMatch1.id,
      );
      expect(matchExists, false);

      await database.matchDao.addMatch(match: testMatch1);

      matchExists = await database.matchDao.matchExists(matchId: testMatch1.id);
      expect(matchExists, true);
    });

    test('Deleting a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatch1);

      final matchDeleted = await database.matchDao.deleteMatch(
        matchId: testMatch1.id,
      );
      expect(matchDeleted, true);

      final matchExists = await database.matchDao.matchExists(
        matchId: testMatch1.id,
      );
      expect(matchExists, false);
    });

    test('Getting the match count works correctly', () async {
      var matchCount = await database.matchDao.getMatchCount();
      expect(matchCount, 0);

      await database.matchDao.addMatch(match: testMatch1);

      matchCount = await database.matchDao.getMatchCount();
      expect(matchCount, 1);

      await database.matchDao.addMatch(match: testMatch2);

      matchCount = await database.matchDao.getMatchCount();
      expect(matchCount, 2);

      await database.matchDao.deleteMatch(matchId: testMatch1.id);

      matchCount = await database.matchDao.getMatchCount();
      expect(matchCount, 1);

      await database.matchDao.deleteMatch(matchId: testMatch2.id);

      matchCount = await database.matchDao.getMatchCount();
      expect(matchCount, 0);
    });

    test('Checking if match has winner works correctly', () async {
      await database.matchDao.addMatch(match: testMatch1);
      await database.matchDao.addMatch(match: testMatchOnlyGroup);

      var hasWinner = await database.matchDao.hasWinner(matchId: testMatch1.id);
      expect(hasWinner, true);

      hasWinner = await database.matchDao.hasWinner(
        matchId: testMatchOnlyGroup.id,
      );
      expect(hasWinner, false);
    });

    test('Fetching the winner of a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatch1);

      final winner = await database.matchDao.getWinner(matchId: testMatch1.id);
      if (winner == null) {
        fail('Winner is null');
      } else {
        expect(winner.id, testMatch1.winner!.id);
        expect(winner.name, testMatch1.winner!.name);
        expect(winner.createdAt, testMatch1.winner!.createdAt);
      }
    });

    test('Updating the winner of a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatch1);

      final winner = await database.matchDao.getWinner(matchId: testMatch1.id);
      if (winner == null) {
        fail('Winner is null');
      } else {
        expect(winner.id, testMatch1.winner!.id);
        expect(winner.name, testMatch1.winner!.name);
        expect(winner.createdAt, testMatch1.winner!.createdAt);
        expect(winner.id, testPlayer4.id);
        expect(winner.id != testPlayer5.id, true);
      }

      await database.matchDao.setWinner(
        matchId: testMatch1.id,
        winnerId: testPlayer5.id,
      );

      final newWinner = await database.matchDao.getWinner(
        matchId: testMatch1.id,
      );

      if (newWinner == null) {
        fail('New winner is null');
      } else {
        expect(newWinner.id, testPlayer5.id);
        expect(newWinner.name, testPlayer5.name);
        expect(newWinner.createdAt, testPlayer5.createdAt);
      }
    });

    test('Removing a winner works correctly', () async {
      await database.matchDao.addMatch(match: testMatch2);

      var hasWinner = await database.matchDao.hasWinner(matchId: testMatch2.id);
      expect(hasWinner, true);

      await database.matchDao.removeWinner(matchId: testMatch2.id);

      hasWinner = await database.matchDao.hasWinner(matchId: testMatch2.id);
      expect(hasWinner, false);

      final removedWinner = await database.matchDao.getWinner(
        matchId: testMatch2.id,
      );

      expect(removedWinner, null);
    });

    test('Renaming a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatch1);

      var fetchedMatch = await database.matchDao.getMatchById(
        matchId: testMatch1.id,
      );
      expect(fetchedMatch.name, testMatch1.name);

      const newName = 'Updated Match Name';
      await database.matchDao.updateMatchName(
        matchId: testMatch1.id,
        newName: newName,
      );

      fetchedMatch = await database.matchDao.getMatchById(
        matchId: testMatch1.id,
      );
      expect(fetchedMatch.name, newName);
    });
  });
}
