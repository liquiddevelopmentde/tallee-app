import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Player testPlayer5;
  late Player testPlayer6;
  late Group testGroup;
  late Game testGame;
  late Match testMatchOnlyGroup;
  late Match testMatchOnlyPlayers;
  late Team testTeam1;
  late Team testTeam2;
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
      testPlayer5 = Player(name: 'Eve', description: '');
      testPlayer6 = Player(name: 'Frank', description: '');
      testGroup = Group(
        name: 'Test Group',
        description: '',
        members: [testPlayer1, testPlayer2, testPlayer3],
      );
      testGame = Game(
        name: 'Test Game',
        ruleset: Ruleset.singleWinner,
        description: 'A test game',
        color: GameColor.blue,
        icon: '',
      );
      testMatchOnlyGroup = Match(
        name: 'Test Match with Group',
        game: testGame,
        group: testGroup,
        notes: '',
      );
      testMatchOnlyPlayers = Match(
        name: 'Test Match with Players',
        game: testGame,
        players: [testPlayer4, testPlayer5, testPlayer6],
        notes: '',
      );
      testTeam1 = Team(name: 'Team Alpha', members: [testPlayer1, testPlayer2]);
      testTeam2 = Team(name: 'Team Beta', members: [testPlayer3, testPlayer4]);
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
    await database.groupDao.addGroup(group: testGroup);
    await database.gameDao.addGame(game: testGame);
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

      final playerToRemove = testMatchOnlyPlayers.players[0];

      final removed = await database.playerMatchDao.removePlayerFromMatch(
        playerId: playerToRemove.id,
        matchId: testMatchOnlyPlayers.id,
      );
      expect(removed, true);

      final result = await database.matchDao.getMatchById(
        matchId: testMatchOnlyPlayers.id,
      );
      expect(result.players.length, testMatchOnlyPlayers.players.length - 1);

      final playerExists = result.players.any((p) => p.id == playerToRemove.id);
      expect(playerExists, false);
    });

    test('Retrieving players of a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatchOnlyPlayers);
      final players =
          await database.playerMatchDao.getPlayersOfMatch(
            matchId: testMatchOnlyPlayers.id,
          ) ??
          [];

      for (int i = 0; i < players.length; i++) {
        expect(players[i].id, testMatchOnlyPlayers.players[i].id);
        expect(players[i].name, testMatchOnlyPlayers.players[i].name);
        expect(players[i].createdAt, testMatchOnlyPlayers.players[i].createdAt);
      }
    });

    test('Updating the match players works correctly', () async {
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
      'Adding the same player to separate matches works correctly',
      () async {
        final playersList = [testPlayer1, testPlayer2, testPlayer3];
        final match1 = Match(
          name: 'Match 1',
          game: testGame,
          players: playersList,
          notes: '',
        );
        final match2 = Match(
          name: 'Match 2',
          game: testGame,
          players: playersList,
          notes: '',
        );

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

    // Verifies that getPlayersOfMatch returns null for a non-existent match.
    test('getPlayersOfMatch returns null for non-existent match', () async {
      final players = await database.playerMatchDao.getPlayersOfMatch(
        matchId: 'non-existent-match-id',
      );

      expect(players, isNull);
    });

    test('Adding player with teamId works correctly', () async {
      await database.matchDao.addMatch(match: testMatchOnlyGroup);
      await database.teamDao.addTeam(team: testTeam1);

      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
        teamId: testTeam1.id,
      );

      final playersInTeam = await database.playerMatchDao.getPlayersInTeam(
        matchId: testMatchOnlyGroup.id,
        teamId: testTeam1.id,
      );

      expect(playersInTeam.length, 1);
      expect(playersInTeam[0].id, testPlayer1.id);
    });

    test('updatePlayerTeam updates team correctly', () async {
      await database.matchDao.addMatch(match: testMatchOnlyGroup);
      await database.teamDao.addTeam(team: testTeam1);
      await database.teamDao.addTeam(team: testTeam2);

      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
        teamId: testTeam1.id,
      );

      // Update player's team
      final updated = await database.playerMatchDao.updatePlayerTeam(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
        teamId: testTeam2.id,
      );

      expect(updated, true);

      // Verify player is now in testTeam2
      final playersInTeam2 = await database.playerMatchDao.getPlayersInTeam(
        matchId: testMatchOnlyGroup.id,
        teamId: testTeam2.id,
      );

      expect(playersInTeam2.length, 1);
      expect(playersInTeam2[0].id, testPlayer1.id);

      // Verify player is no longer in testTeam1
      final playersInTeam1 = await database.playerMatchDao.getPlayersInTeam(
        matchId: testMatchOnlyGroup.id,
        teamId: testTeam1.id,
      );

      expect(playersInTeam1.isEmpty, true);
    });

    test('updatePlayerTeam can remove player from team', () async {
      await database.matchDao.addMatch(match: testMatchOnlyGroup);
      await database.teamDao.addTeam(team: testTeam1);

      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
        teamId: testTeam1.id,
      );

      // Remove player from team by setting teamId to null
      final updated = await database.playerMatchDao.updatePlayerTeam(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
        teamId: null,
      );

      expect(updated, true);

      final playersInTeam = await database.playerMatchDao.getPlayersInTeam(
        matchId: testMatchOnlyGroup.id,
        teamId: testTeam1.id,
      );

      expect(playersInTeam.isEmpty, true);
    });

    test(
      'updatePlayerTeam returns false for non-existent player-match',
      () async {
        await database.matchDao.addMatch(match: testMatchOnlyGroup);

        final updated = await database.playerMatchDao.updatePlayerTeam(
          matchId: testMatchOnlyGroup.id,
          playerId: 'non-existent-player-id',
          teamId: testTeam1.id,
        );

        expect(updated, false);
      },
    );

    // Verifies that getPlayersInTeam returns empty list for non-existent team.
    test('getPlayersInTeam returns empty list for non-existent team', () async {
      await database.matchDao.addMatch(match: testMatchOnlyPlayers);

      final players = await database.playerMatchDao.getPlayersInTeam(
        matchId: testMatchOnlyPlayers.id,
        teamId: 'non-existent-team-id',
      );

      expect(players.isEmpty, true);
    });

    test('getPlayersInTeam returns all players of a team', () async {
      await database.matchDao.addMatch(match: testMatchOnlyGroup);
      await database.teamDao.addTeam(team: testTeam1);

      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
        teamId: testTeam1.id,
      );
      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer2.id,
        teamId: testTeam1.id,
      );

      final playersInTeam = await database.playerMatchDao.getPlayersInTeam(
        matchId: testMatchOnlyGroup.id,
        teamId: testTeam1.id,
      );

      expect(playersInTeam.length, 2);
      final playerIds = playersInTeam.map((p) => p.id).toSet();
      expect(playerIds.contains(testPlayer1.id), true);
      expect(playerIds.contains(testPlayer2.id), true);
    });

    test(
      'removePlayerFromMatch returns false for non-existent player',
      () async {
        await database.matchDao.addMatch(match: testMatchOnlyPlayers);

        final removed = await database.playerMatchDao.removePlayerFromMatch(
          playerId: 'non-existent-player-id',
          matchId: testMatchOnlyPlayers.id,
        );

        expect(removed, false);
      },
    );

    test('Adding same player twice to same match is ignored', () async {
      await database.matchDao.addMatch(match: testMatchOnlyGroup);

      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
      );

      // Try to add the same player again with different score
      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
      );

      // Verify player count is still 1
      final players = await database.playerMatchDao.getPlayersOfMatch(
        matchId: testMatchOnlyGroup.id,
      );

      expect(players?.length, 1);
    });

    test(
      'updatePlayersFromMatch with empty list removes all players',
      () async {
        await database.matchDao.addMatch(match: testMatchOnlyPlayers);

        // Verify players exist initially
        var players = await database.playerMatchDao.getPlayersOfMatch(
          matchId: testMatchOnlyPlayers.id,
        );
        expect(players?.length, 3);

        // Update with empty list
        await database.playerMatchDao.updatePlayersFromMatch(
          matchId: testMatchOnlyPlayers.id,
          newPlayer: [],
        );

        // Verify all players are removed
        players = await database.playerMatchDao.getPlayersOfMatch(
          matchId: testMatchOnlyPlayers.id,
        );
        expect(players, isNull);
      },
    );

    test('updatePlayersFromMatch with same players makes no changes', () async {
      await database.matchDao.addMatch(match: testMatchOnlyPlayers);

      final originalPlayers = [testPlayer4, testPlayer5, testPlayer6];

      await database.playerMatchDao.updatePlayersFromMatch(
        matchId: testMatchOnlyPlayers.id,
        newPlayer: originalPlayers,
      );

      final players = await database.playerMatchDao.getPlayersOfMatch(
        matchId: testMatchOnlyPlayers.id,
      );

      expect(players?.length, originalPlayers.length);
      final playerIds = players!.map((p) => p.id).toSet();
      for (final originalPlayer in originalPlayers) {
        expect(playerIds.contains(originalPlayer.id), true);
      }
    });

    test('matchHasPlayers returns false for non-existent match', () async {
      final hasPlayers = await database.playerMatchDao.matchHasPlayers(
        matchId: 'non-existent-match-id',
      );

      expect(hasPlayers, false);
    });

    test('isPlayerInMatch returns false for non-existent match', () async {
      final isInMatch = await database.playerMatchDao.isPlayerInMatch(
        matchId: 'non-existent-match-id',
        playerId: testPlayer1.id,
      );

      expect(isInMatch, false);
    });

    // Verifies that getPlayersInTeam returns empty list for non-existent match.
    test(
      'getPlayersInTeam returns empty list for non-existent match',
      () async {
        await database.teamDao.addTeam(team: testTeam1);

        final players = await database.playerMatchDao.getPlayersInTeam(
          matchId: 'non-existent-match-id',
          teamId: testTeam1.id,
        );

        expect(players.isEmpty, true);
      },
    );

    // Verifies that players in different teams within the same match are returned correctly.
    test('Players in different teams within same match are separate', () async {
      await database.matchDao.addMatch(match: testMatchOnlyGroup);
      await database.teamDao.addTeam(team: testTeam1);
      await database.teamDao.addTeam(team: testTeam2);

      // Add players to different teams
      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
        teamId: testTeam1.id,
      );
      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer2.id,
        teamId: testTeam1.id,
      );
      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer3.id,
        teamId: testTeam2.id,
      );

      // Verify team 1 players
      final playersInTeam1 = await database.playerMatchDao.getPlayersInTeam(
        matchId: testMatchOnlyGroup.id,
        teamId: testTeam1.id,
      );
      expect(playersInTeam1.length, 2);
      final team1Ids = playersInTeam1.map((p) => p.id).toSet();
      expect(team1Ids.contains(testPlayer1.id), true);
      expect(team1Ids.contains(testPlayer2.id), true);
      expect(team1Ids.contains(testPlayer3.id), false);

      // Verify team 2 players
      final playersInTeam2 = await database.playerMatchDao.getPlayersInTeam(
        matchId: testMatchOnlyGroup.id,
        teamId: testTeam2.id,
      );
      expect(playersInTeam2.length, 1);
      expect(playersInTeam2[0].id, testPlayer3.id);
    });

    // Verifies that removePlayerFromMatch does not affect other matches.
    test('removePlayerFromMatch does not affect other matches', () async {
      final playersList = [testPlayer1, testPlayer2];
      final match1 = Match(
        name: 'Match 1',
        game: testGame,
        players: playersList,
        notes: '',
      );
      final match2 = Match(
        name: 'Match 2',
        game: testGame,
        players: playersList,
        notes: '',
      );

      await Future.wait([
        database.matchDao.addMatch(match: match1),
        database.matchDao.addMatch(match: match2),
      ]);

      // Remove player from match1
      final removed = await database.playerMatchDao.removePlayerFromMatch(
        playerId: testPlayer1.id,
        matchId: match1.id,
      );
      expect(removed, true);

      // Verify player is removed from match1
      final isInMatch1 = await database.playerMatchDao.isPlayerInMatch(
        matchId: match1.id,
        playerId: testPlayer1.id,
      );
      expect(isInMatch1, false);

      // Verify player still exists in match2
      final isInMatch2 = await database.playerMatchDao.isPlayerInMatch(
        matchId: match2.id,
        playerId: testPlayer1.id,
      );
      expect(isInMatch2, true);
    });

    // Verifies that updatePlayersFromMatch on non-existent match fails with constraint error.
    test(
      'updatePlayersFromMatch on non-existent match fails with foreign key constraint',
      () async {
        // Should throw due to foreign key constraint - match doesn't exist
        await expectLater(
          database.playerMatchDao.updatePlayersFromMatch(
            matchId: 'non-existent-match-id',
            newPlayer: [testPlayer1, testPlayer2],
          ),
          throwsA(anything),
        );
      },
    );

    // Verifies that a player can be in a match without being assigned to a team.
    test('Player can exist in match without team assignment', () async {
      await database.matchDao.addMatch(match: testMatchOnlyGroup);
      await database.teamDao.addTeam(team: testTeam1);

      // Add player to match without team
      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
      );

      // Add another player to match with team
      await database.playerMatchDao.addPlayerToMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer2.id,
        teamId: testTeam1.id,
      );

      // Verify both players are in the match
      final isPlayer1InMatch = await database.playerMatchDao.isPlayerInMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer1.id,
      );
      final isPlayer2InMatch = await database.playerMatchDao.isPlayerInMatch(
        matchId: testMatchOnlyGroup.id,
        playerId: testPlayer2.id,
      );

      expect(isPlayer1InMatch, true);
      expect(isPlayer2InMatch, true);

      // Verify only player2 is in the team
      final playersInTeam = await database.playerMatchDao.getPlayersInTeam(
        matchId: testMatchOnlyGroup.id,
        teamId: testTeam1.id,
      );

      expect(playersInTeam.length, 1);
      expect(playersInTeam[0].id, testPlayer2.id);
    });

    // Verifies that replaceMatchPlayers removes all existing players and replaces with new list.
    test('replaceMatchPlayers replaces all match players correctly', () async {
      // Create initial match with 3 players
      await database.matchDao.addMatch(match: testMatchOnlyPlayers);

      // Verify initial players
      var matchPlayers = await database.matchDao.getMatchById(
        matchId: testMatchOnlyPlayers.id,
      );
      expect(matchPlayers.players.length, 3);

      // Replace with new list containing 2 different players
      final newPlayersList = [testPlayer1, testPlayer2];
      await database.matchDao.replaceMatchPlayers(
        matchId: testMatchOnlyPlayers.id,
        newPlayers: newPlayersList,
      );

      // Get updated match and verify players
      matchPlayers = await database.matchDao.getMatchById(
        matchId: testMatchOnlyPlayers.id,
      );

      expect(matchPlayers.players.length, 2);
      expect(matchPlayers.players.any((p) => p.id == testPlayer1.id), true);
      expect(matchPlayers.players.any((p) => p.id == testPlayer2.id), true);
      expect(matchPlayers.players.any((p) => p.id == testPlayer4.id), false);
      expect(matchPlayers.players.any((p) => p.id == testPlayer5.id), false);
      expect(matchPlayers.players.any((p) => p.id == testPlayer6.id), false);
    });
  });
}
