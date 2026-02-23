import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull;
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
  late Player testPlayer6;
  late Group testgroup;
  late Match testMatchOnlyGroup;
  late Match testMatchOnlyPlayers;
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
      testPlayer6 = Player(name: 'Frank');
      testgroup = Group(
        name: 'Test Group',
        members: [testPlayer1, testPlayer2, testPlayer3],
      );
      testMatchOnlyGroup = Match(
        name: 'Test Match with Group',
        group: testgroup,
      );
      testMatchOnlyPlayers = Match(
        name: 'Test Match with Players',
        players: [testPlayer4, testPlayer5, testPlayer6],
      );
    });
    await database.playerDao.addPlayersAsList(
      players: [
        testPlayer1,
        testPlayer2,
        testPlayer3,
        testPlayer4,
        testPlayer5,
        testPlayer6,
      ],
    );
    await database.groupDao.addGroup(group: testgroup);
  });
  tearDown(() async {
    await database.close();
  });

  group('Player-Match Tests', () {
    test('Match has player works correctly', () async {
      await database.matchDao.addMatch(match: testMatchOnlyGroup);
      await database.playerDao.addPlayer(player: testPlayer1);

      var matchHasPlayers = await database.playerMatchDao.matchHasPlayers(
        matchId: testMatchOnlyGroup.id,
      );

      expect(matchHasPlayers, false);

      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
      );

      matchHasPlayers = await database.playerMatchDao.matchHasPlayers(
        matchId: testMatchOnlyGroup.id,
      );

      expect(matchHasPlayers, true);
    });

    test('Adding a player to a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatchOnlyGroup);
      await database.playerDao.addPlayer(player: testPlayer5);
      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer5.id,
      );

      var playerAdded = await database.playerMatchDao.isPlayerInMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer5.id,
      );

      expect(playerAdded, true);

      playerAdded = await database.playerMatchDao.isPlayerInMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: '',
      );

      expect(playerAdded, false);
    });

    test('Removing player from match works correctly', () async {
      await database.matchDao.addMatch(match: testMatchOnlyPlayers);

      final playerToRemove = testMatchOnlyPlayers.players![0];

      final removed = await database.playerMatchDao.removePlayerFromMatch(
        playerId: playerToRemove.id,
        matchId: testMatchOnlyPlayers.id,
      );
      expect(removed, true);

      final result = await database.matchDao.getMatchById(
        matchId: testMatchOnlyPlayers.id,
      );
      expect(result.players!.length, testMatchOnlyPlayers.players!.length - 1);

      final playerExists = result.players!.any(
        (p) => p.id == playerToRemove.id,
      );
      expect(playerExists, false);
    });

    test('Retrieving players of a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatchOnlyPlayers);
      final players = await database.playerMatchDao.getPlayersOfMatch(
        matchId: testMatchOnlyPlayers.id,
      );

      if (players == null) {
        fail('Players should not be null');
      }

      for (int i = 0; i < players.length; i++) {
        expect(players[i].id, testMatchOnlyPlayers.players![i].id);
        expect(players[i].name, testMatchOnlyPlayers.players![i].name);
        expect(
          players[i].createdAt,
          testMatchOnlyPlayers.players![i].createdAt,
        );
      }
    });

    test('Updating the match players works coreclty', () async {
      await database.matchDao.addMatch(match: testMatchOnlyPlayers);

      final newPlayers = [testPlayer1, testPlayer2, testPlayer4];
      await database.playerDao.addPlayersAsList(players: newPlayers);

      // First, remove all existing players
      final existingPlayers = await database.playerMatchDao.getPlayersOfMatch(
        matchId: testMatchOnlyPlayers.id,
      );

      if (existingPlayers == null || existingPlayers.isEmpty) {
        fail('Existing players should not be null or empty');
      }

      await database.playerMatchDao.updatePlayersFromMatch(
        matchId: testMatchOnlyPlayers.id,
        newPlayer: newPlayers,
      );

      final updatedPlayers = await database.playerMatchDao.getPlayersOfMatch(
        matchId: testMatchOnlyPlayers.id,
      );

      if (updatedPlayers == null) {
        fail('Updated players should not be null');
      }

      expect(updatedPlayers.length, newPlayers.length);

      /// Create a map of new players for easy lookup
      final testPlayers = {for (var p in newPlayers) p.id: p};

      /// Verify each updated player matches the new players
      for (final player in updatedPlayers) {
        final testPlayer = testPlayers[player.id]!;

        expect(player.id, testPlayer.id);
        expect(player.name, testPlayer.name);
        expect(player.createdAt, testPlayer.createdAt);
      }
    });

    test(
      'Adding the same player to seperate matches works correctly',
      () async {
        final playersList = [testPlayer1, testPlayer2, testPlayer3];
        final match1 = Match(name: 'Match 1', players: playersList);
        final match2 = Match(name: 'Match 2', players: playersList);

        await Future.wait([
          database.matchDao.addMatch(match: match1),
          database.matchDao.addMatch(match: match2),
        ]);

        final players1 = await database.playerMatchDao.getPlayersOfMatch(
          matchId: match1.id,
        );
        final players2 = await database.playerMatchDao.getPlayersOfMatch(
          matchId: match2.id,
        );

        expect(players1, isNotNull);
        expect(players2, isNotNull);

        expect(
          players1!.map((p) => p.id).toList(),
          equals(players2!.map((p) => p.id).toList()),
        );
        expect(
          players1.map((p) => p.name).toList(),
          equals(players2.map((p) => p.name).toList()),
        );
        expect(
          players1.map((p) => p.createdAt).toList(),
          equals(players2.map((p) => p.createdAt).toList()),
        );
      },
    );
  });
}
