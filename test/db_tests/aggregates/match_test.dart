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
      testPlayer1 = Player(name: 'Alice', description: '');
      testPlayer2 = Player(name: 'Bob', description: '');
      testPlayer3 = Player(name: 'Charlie', description: '');
      testPlayer4 = Player(name: 'Diana', description: '');
      testPlayer5 = Player(name: 'Eve', description: '');
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
        color: GameColor.blue,
        icon: '',
      );
      testMatch1 = Match(
        name: 'First Test Match',
        game: testGame,
        group: testGroup1,
        players: [testPlayer4, testPlayer5],
        winner: testPlayer4,
        notes: '',
      );
      testMatch2 = Match(
        name: 'Second Test Match',
        game: testGame,
        group: testGroup2,
        players: [testPlayer1, testPlayer2, testPlayer3],
        winner: testPlayer2,
        notes: '',
      );
      testMatchOnlyPlayers = Match(
        name: 'Test Match with Players',
        game: testGame,
        players: [testPlayer1, testPlayer2, testPlayer3],
        winner: testPlayer3,
        notes: '',
      );
      testMatchOnlyGroup = Match(
        name: 'Test Match with Group',
        game: testGame,
        group: testGroup2,
        notes: '',
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
    // Verifies that a single match can be added and retrieved with all fields, group, and players intact.
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

    // Verifies that multiple matches can be added and retrieved with correct groups and players.
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
        expect(match.players.length, testMatch.players.length);
        for (int i = 0; i < testMatch.players.length; i++) {
          expect(match.players[i].id, testMatch.players[i].id);
          expect(match.players[i].name, testMatch.players[i].name);
          expect(match.players[i].createdAt, testMatch.players[i].createdAt);
        }
      }
    });

    // Verifies that adding the same match twice does not create duplicates.
    test('Adding the same match twice does not create duplicates', () async {
      await database.matchDao.addMatch(match: testMatch1);
      await database.matchDao.addMatch(match: testMatch1);

      final matchCount = await database.matchDao.getMatchCount();
      expect(matchCount, 1);
    });

    // Verifies that matchExists returns correct boolean based on match presence.
    test('Match existence check works correctly', () async {
      var matchExists = await database.matchDao.matchExists(
        matchId: testMatch1.id,
      );
      expect(matchExists, false);

      await database.matchDao.addMatch(match: testMatch1);

      matchExists = await database.matchDao.matchExists(matchId: testMatch1.id);
      expect(matchExists, true);
    });

    // Verifies that deleteMatch removes the match and returns true.
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

    // Verifies that getMatchCount returns correct count through add/delete operations.
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

    // Verifies that updateMatchName correctly updates only the name field.
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

    test('Fetching a winner works correctly', () async {
      await database.matchDao.addMatch(match: testMatch1);

      var fetchedMatch = await database.matchDao.getMatchById(
        matchId: testMatch1.id,
      );

      expect(fetchedMatch.winner, isNotNull);
      expect(fetchedMatch.winner!.id, testPlayer4.id);
    });

    test('Setting a winner works correctly', () async {
      await database.matchDao.addMatch(match: testMatch1);

      await database.scoreEntryDao.setWinner(
        matchId: testMatch1.id,
        playerId: testPlayer5.id,
      );

      final fetchedMatch = await database.matchDao.getMatchById(
        matchId: testMatch1.id,
      );
      expect(fetchedMatch.winner, isNotNull);
      expect(fetchedMatch.winner!.id, testPlayer5.id);
    });

    test(
      'removeMatchGroup removes group from match with existing group',
      () async {
        await database.matchDao.addMatch(match: testMatch1);

        final removed = await database.matchDao.removeMatchGroup(
          matchId: testMatch1.id,
        );
        expect(removed, isTrue);

        final updatedMatch = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(updatedMatch.group, null);
        expect(updatedMatch.game.id, testMatch1.game.id);
        expect(updatedMatch.name, testMatch1.name);
        expect(updatedMatch.notes, testMatch1.notes);
      },
    );

    test(
      'removeMatchGroup on match that already has no group still succeeds',
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

    test('removeMatchGroup on non-existing match returns false', () async {
      final removed = await database.matchDao.removeMatchGroup(
        matchId: 'non-existing-id',
      );
      expect(removed, isFalse);
    });

    test('Fetching all matches related to a group', () async {
      var matches = await database.matchDao.getGroupMatches(
        groupId: 'non-existing-id',
      );

      expect(matches, isEmpty);

      await database.matchDao.addMatch(match: testMatch1);

      matches = await database.matchDao.getGroupMatches(groupId: testGroup1.id);

      expect(matches, isNotEmpty);

      final match = matches.first;
      expect(match.id, testMatch1.id);
      expect(match.group, isNotNull);
      expect(match.group!.id, testGroup1.id);
    });
  });
}
