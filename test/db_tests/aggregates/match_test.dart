import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Player testPlayer5;
  late Group testGroup1;
  late Group testGroup2;
  late Game testGame;
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
        name: 'Test Group 1',
        description: '',
        members: [testPlayer1, testPlayer2, testPlayer3],
      );
      testGroup2 = Group(
        name: 'Test Group 2',
        description: '',
        members: [testPlayer4, testPlayer5],
      );
      testGame = Game(
        name: 'Test Game',
        ruleset: Ruleset.singleWinner,
        description: 'A test game',
        color: AppColor.blue,
        icon: '',
      );
      testMatch1 = Match(
        name: 'First Test Match',
        game: testGame,
        group: testGroup1,
        players: [testPlayer4, testPlayer5],
        scores: {testPlayer4.id: ScoreEntry(score: 1)},
      );
      testMatch2 = Match(
        name: 'Second Test Match',
        game: testGame,
        group: testGroup2,
        players: [testPlayer1, testPlayer2, testPlayer3],
      );
      testMatchOnlyPlayers = Match(
        name: 'Test Match with Players',
        game: testGame,
        players: [testPlayer1, testPlayer2, testPlayer3],
      );
      testMatchOnlyGroup = Match(
        name: 'Test Match with Group',
        game: testGame,
        group: testGroup2,
        players: testGroup2.members,
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
    await database.gameDao.addGame(game: testGame);
  });
  tearDown(() async {
    await database.close();
  });

  group('Match Tests', () {
    group('CREATE', () {
      test('Adding and fetching single match works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final result = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );

        expect(result.id, testMatch1.id);
        expect(result.name, testMatch1.name);
        expect(result.createdAt, testMatch1.createdAt);

        if (result.group != null) {
          expect(result.group!.members.length, testGroup1.members.length);

          for (int i = 0; i < testGroup1.members.length; i++) {
            expect(result.group!.members[i].id, testGroup1.members[i].id);
            expect(result.group!.members[i].name, testGroup1.members[i].name);
          }
        } else {
          fail('Group is null');
        }
        expect(result.players.length, testMatch1.players.length);

        for (int i = 0; i < testMatch1.players.length; i++) {
          expect(result.players[i].id, testMatch1.players[i].id);
          expect(result.players[i].name, testMatch1.players[i].name);
          expect(result.players[i].createdAt, testMatch1.players[i].createdAt);
        }
      });

      test('Adding and fetching multiple matches works correctly', () async {
        await database.matchDao.addMatchesAsList(
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

          // Group-Checks
          if (testMatch.group != null) {
            expect(match.group!.id, testMatch.group!.id);
            expect(match.group!.name, testMatch.group!.name);
            expect(match.group!.createdAt, testMatch.group!.createdAt);

            // Group Members-Checks
            expect(
              match.group!.members.length,
              testMatch.group!.members.length,
            );
            for (int i = 0; i < testMatch.group!.members.length; i++) {
              expect(
                match.group!.members[i].id,
                testMatch.group!.members[i].id,
              );
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
          expect(match.players.length, testMatch.players.length);
          for (int i = 0; i < testMatch.players.length; i++) {
            expect(match.players[i].id, testMatch.players[i].id);
            expect(match.players[i].name, testMatch.players[i].name);
            expect(match.players[i].createdAt, testMatch.players[i].createdAt);
          }
        }
      });

      test('addMatch() ignores duplicate games', () async {
        var added = await database.matchDao.addMatch(match: testMatch1);
        expect(added, isTrue);

        added = await database.matchDao.addMatch(match: testMatch1);
        expect(added, isFalse);

        final matchCount = await database.matchDao.getMatchCount();
        expect(matchCount, 1);
      });

      test('addMatchesAsList() returns isFalse for empty list', () async {
        var added = await database.matchDao.addMatchesAsList(matches: []);
        expect(added, isFalse);
      });

      test('addMatchesAsList() ignores duplicate games', () async {
        final added = await database.matchDao.addMatchesAsList(
          matches: [testMatch1, testMatch2, testMatch1],
        );
        expect(added, isTrue);

        final matchCount = await database.matchDao.getMatchCount();
        expect(matchCount, 2);
      });
    });

    group('READ', () {
      test('matchExists() works correctly', () async {
        var matchExists = await database.matchDao.matchExists(
          matchId: testMatch1.id,
        );
        expect(matchExists, isFalse);

        await database.matchDao.addMatch(match: testMatch1);

        matchExists = await database.matchDao.matchExists(
          matchId: testMatch1.id,
        );
        expect(matchExists, isTrue);
      });

      test('getMatchesByGroup() works correctly', () async {
        var matches = await database.matchDao.getMatchesByGroup(
          groupId: 'non-existing-id',
        );

        expect(matches, isEmpty);

        await database.matchDao.addMatch(match: testMatch1);
        matches = await database.matchDao.getMatchesByGroup(
          groupId: testGroup1.id,
        );
        expect(matches, isNotEmpty);

        final match = matches.first;
        expect(match.id, testMatch1.id);
        expect(match.group, isNotNull);
        expect(match.group!.id, testGroup1.id);
      });

      test('getMatchCount() works correctly', () async {
        var count = await database.matchDao.getMatchCount();
        expect(count, 0);

        await database.matchDao.addMatch(match: testMatch1);

        count = await database.matchDao.getMatchCount();
        expect(count, 1);

        await database.matchDao.addMatch(match: testMatch2);

        count = await database.matchDao.getMatchCount();
        expect(count, 2);

        await database.matchDao.deleteMatch(matchId: testMatch1.id);

        count = await database.matchDao.getMatchCount();
        expect(count, 1);

        await database.matchDao.deleteMatch(matchId: testMatch2.id);

        count = await database.matchDao.getMatchCount();
        expect(count, 0);
      });

      test('getMatchCountByGame() works correctly', () async {
        var count = await database.matchDao.getMatchCountByGame(
          gameId: testGame.id,
        );
        expect(count, 0);

        await database.matchDao.addMatch(match: testMatch1);
        count = await database.matchDao.getMatchCountByGame(
          gameId: testGame.id,
        );
        expect(count, 1);

        await database.matchDao.addMatch(match: testMatch2);
        count = await database.matchDao.getMatchCountByGame(
          gameId: testGame.id,
        );
        expect(count, 2);

        await database.matchDao.deleteMatch(matchId: testMatch1.id);
        count = await database.matchDao.getMatchCountByGame(
          gameId: testGame.id,
        );
        expect(count, 1);

        await database.matchDao.deleteMatch(matchId: testMatch2.id);
        count = await database.matchDao.getMatchCountByGame(
          gameId: testGame.id,
        );
        expect(count, 0);
      });

      test('getMatchCountByGame() returns 0 for non-existent game', () async {
        final count = await database.matchDao.getMatchCountByGame(
          gameId: 'non-existent-game-id',
        );
        expect(count, 0);
      });
    });

    group('UPDATE', () {
      test('updateMatchName() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        const newName = 'New name';
        await database.matchDao.updateMatchName(
          matchId: testMatch1.id,
          name: newName,
        );

        final fetchedMatch = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(fetchedMatch.name, newName);
      });

      test('updateMatchName() does nothing for non-existent match', () async {
        final updated = await database.matchDao.updateMatchName(
          matchId: 'non-existing-id',
          name: 'New Name',
        );
        expect(updated, isFalse);

        final allMatches = await database.matchDao.getAllMatches();
        expect(allMatches, isEmpty);
      });

      test('updateMatchGroup() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);
        await database.groupDao.addGroup(group: testGroup2);

        await database.matchDao.updateMatchGroup(
          matchId: testMatch1.id,
          groupId: testGroup2.id,
        );

        final fetchedMatch = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(fetchedMatch.group?.id, testGroup2.id);
      });

      test('updateMatchGroup() does nothing for non-existent match', () async {
        final updated = await database.matchDao.updateMatchGroup(
          matchId: 'non-existing-id',
          groupId: 'group-id',
        );
        expect(updated, isFalse);

        final allMatches = await database.matchDao.getAllMatches();
        expect(allMatches, isEmpty);
      });

      test('removeMatchGroup() works correctly', () async {
        expect(testMatch1.group, isNotNull);
        await database.matchDao.addMatch(match: testMatch1);

        final removed = await database.matchDao.removeMatchGroup(
          matchId: testMatch1.id,
        );
        expect(removed, isTrue);

        final updatedMatch = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(updatedMatch.group, null);
      });

      test(
        'removeMatchGroup() on match that already has no group still succeeds',
        () async {
          await database.matchDao.addMatch(match: testMatchOnlyPlayers);

          final removed = await database.matchDao.removeMatchGroup(
            matchId: testMatchOnlyPlayers.id,
          );
          expect(removed, isTrue);

          final updatedMatch = await database.matchDao.getMatchById(
            matchId: testMatchOnlyPlayers.id,
          );
          expect(updatedMatch.group, null);
        },
      );

      test(
        'removeMatchGroup() on non-existing match returns isFalse',
        () async {
          final removed = await database.matchDao.removeMatchGroup(
            matchId: 'non-existing-id',
          );
          expect(removed, isFalse);
        },
      );

      test('updateMatchNotes() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        const newName = 'New name';
        await database.matchDao.updateMatchName(
          matchId: testMatch1.id,
          name: newName,
        );

        final fetchedMatch = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(fetchedMatch.name, newName);
      });

      test('updateMatchNotes() does nothing for non-existent game', () async {
        final updated = await database.matchDao.updateMatchNotes(
          matchId: 'non-existing-id',
          notes: 'New notes',
        );
        expect(updated, isFalse);

        final allMatches = await database.matchDao.getAllMatches();
        expect(allMatches, isEmpty);
      });

      test('updateMatchEndedAt() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        DateTime newEndedAt = DateTime(2030, 1, 1, 12, 0, 0);
        await database.matchDao.updateMatchEndedAt(
          matchId: testMatch1.id,
          endedAt: newEndedAt,
        );

        final fetchedMatch = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(fetchedMatch.endedAt, newEndedAt);
      });

      test('updateMatchEndedAt() does nothing for non-existent game', () async {
        final updated = await database.matchDao.updateMatchEndedAt(
          matchId: 'non-existing-id',
          endedAt: DateTime.now(),
        );
        expect(updated, isFalse);

        final allMatches = await database.matchDao.getAllMatches();
        expect(allMatches, isEmpty);
      });
    });

    group('DELETE', () {
      test('deleteMatch() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        var deleted = await database.matchDao.deleteMatch(
          matchId: testMatch1.id,
        );
        expect(deleted, isTrue);

        final matchExists = await database.matchDao.matchExists(
          matchId: testMatch1.id,
        );
        expect(matchExists, isFalse);

        deleted = await database.matchDao.deleteMatch(matchId: testMatch1.id);
        expect(deleted, isFalse);
      });

      test('deleteAllMatches() works correctly', () async {
        await database.matchDao.addMatchesAsList(
          matches: [testMatch1, testMatch2, testMatchOnlyPlayers],
        );

        var count = await database.matchDao.getMatchCount();
        expect(count, 3);

        var deleted = await database.matchDao.deleteAllMatches();
        expect(deleted, isTrue);

        count = await database.matchDao.getMatchCount();
        expect(count, 0);

        deleted = await database.matchDao.deleteAllMatches();
        expect(deleted, isFalse);
      });
    });

    test('deleteMatchesByGame() deletes all matches for a game', () async {
      await database.matchDao.addMatch(match: testMatch1);
      await database.matchDao.addMatch(match: testMatch2);

      var count = await database.matchDao.getMatchCountByGame(
        gameId: testGame.id,
      );
      expect(count, 2);

      final deletedCount = await database.matchDao.deleteMatchesByGame(
        gameId: testGame.id,
      );
      expect(deletedCount, 2);

      count = await database.matchDao.getMatchCountByGame(gameId: testGame.id);
      expect(count, 0);

      final allMatches = await database.matchDao.getAllMatches();
      expect(allMatches, isEmpty);
    });

    test('deleteMatchesByGame() returns 0 for non-existent game', () async {
      final deletedCount = await database.matchDao.deleteMatchesByGame(
        gameId: 'non-existent-game-id',
      );
      expect(deletedCount, 0);
    });
  });
}
