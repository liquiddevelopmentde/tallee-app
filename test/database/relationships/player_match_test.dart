import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/match.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Player testPlayer5;
  late Game testGame;
  late Match testMatch1;
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
      testPlayer1 = Player(name: 'Alice');
      testPlayer2 = Player(name: 'Bob');
      testPlayer3 = Player(name: 'Charlie');
      testPlayer4 = Player(name: 'Diana');
      testPlayer5 = Player(name: 'Eve');
      testGame = Game(
        name: 'Test Game',
        ruleset: Ruleset.singleWinner,
        description: 'A test game',
        color: AppColor.blue,
        icon: '',
      );
      testMatch1 = Match(
        name: 'Test Match with Players',
        game: testGame,
        players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
      );
      testTeam1 = Team(name: 'Team Alpha', members: [testPlayer1, testPlayer2]);
      testTeam2 = Team(name: 'Team Beta', members: [testPlayer3, testPlayer4]);
    });
    await database.playerDao.addPlayersAsList(
      players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
    );
    await database.gameDao.addGame(game: testGame);
  });
  tearDown(() async {
    await database.close();
  });

  group('Player-Match Tests', () {
    group('CREATE', () {
      test('addPlayerToMatch() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);
        await database.playerDao.addPlayer(player: testPlayer1);

        var added = await database.playerMatchDao.addPlayerToMatch(
          matchId: testMatch1.id,
          playerId: testPlayer1.id,
        );
        expect(added, isTrue);

        added = await database.playerMatchDao.isPlayerInMatch(
          matchId: testMatch1.id,
          playerId: testPlayer1.id,
        );
        expect(added, isTrue);
      });

      test('addPlayerToMatch() with team works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);
        await database.teamDao.addTeam(team: testTeam1, matchId: testMatch1.id);

        await database.playerMatchDao.addPlayerToMatch(
          matchId: testMatch1.id,
          playerId: testPlayer3.id,
          teamId: testTeam1.id,
        );

        final playersInTeam = await database.playerMatchDao
            .getPlayersOfTeamInMatch(
              matchId: testMatch1.id,
              teamId: testTeam1.id,
            );

        expect(playersInTeam, isNotEmpty);
        expect(playersInTeam.length, 3);
      });

      test('addPlayerToMatch() ignores duplicates', () async {
        await database.matchDao.addMatch(match: testMatch1);
        await database.playerDao.addPlayer(player: testPlayer5);

        final isInMatch = await database.playerMatchDao.isPlayerInMatch(
          matchId: testMatch1.id,
          playerId: testPlayer5.id,
        );
        expect(isInMatch, isFalse);

        var players = await database.playerMatchDao.getPlayersOfMatch(
          matchId: testMatch1.id,
        );
        expect(players.length, testMatch1.players.length);

        await database.playerMatchDao.addPlayerToMatch(
          matchId: testMatch1.id,
          playerId: testPlayer5.id,
        );
        await database.playerMatchDao.addPlayerToMatch(
          matchId: testMatch1.id,
          playerId: testPlayer5.id,
        );

        players = await database.playerMatchDao.getPlayersOfMatch(
          matchId: testMatch1.id,
        );

        expect(players.length, testMatch1.players.length + 1);
      });
    });

    group('READ', () {
      test('hasMatchPlayers() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);
        var matchHasPlayers = await database.playerMatchDao.hasMatchPlayers(
          matchId: testMatch1.id,
        );
        expect(matchHasPlayers, isTrue);
      });

      test('hasMatchPlayers() returns false for non-existent match', () async {
        final hasPlayers = await database.playerMatchDao.hasMatchPlayers(
          matchId: 'non-existent-match-id',
        );
        expect(hasPlayers, isFalse);
      });

      test('isPlayerInMatch() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);
        final isInMatch = await database.playerMatchDao.isPlayerInMatch(
          matchId: testMatch1.id,
          playerId: testPlayer1.id,
        );
        expect(isInMatch, isTrue);
      });

      test('isPlayerInMatch() returns false for non-existent match', () async {
        final isInMatch = await database.playerMatchDao.isPlayerInMatch(
          matchId: 'non-existent-match-id',
          playerId: testPlayer1.id,
        );
        expect(isInMatch, isFalse);
      });

      test('getPlayersOfMatch() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final players = await database.playerMatchDao.getPlayersOfMatch(
          matchId: testMatch1.id,
        );
        expect(players, isNotEmpty);

        for (int i = 0; i < players.length; i++) {
          expect(players[i].id, testMatch1.players[i].id);
          expect(players[i].name, testMatch1.players[i].name);
          expect(players[i].createdAt, testMatch1.players[i].createdAt);
        }
      });

      test(
        'getPlayersOfMatch() returns empty list for non-existent match',
        () async {
          final players = await database.playerMatchDao.getPlayersOfMatch(
            matchId: 'non-existent-match-id',
          );
          expect(players, isEmpty);
        },
      );

      test('getPlayersInTeam() works correctly', () async {
        // Create a match with teams
        final matchWithTeams = Match(
          name: 'Match with teams',
          game: testGame,
          players: [],
          teams: [testTeam1, testTeam2],
        );
        await database.matchDao.addMatch(match: matchWithTeams);

        var playersInTeam = await database.playerMatchDao
            .getPlayersOfTeamInMatch(
              matchId: matchWithTeams.id,
              teamId: testTeam1.id,
            );

        expect(playersInTeam, isNotEmpty);
        expect(playersInTeam.length, 2);

        var playerIds = playersInTeam.map((p) => p.id).toSet();
        expect(playerIds.contains(testPlayer1.id), isTrue);
        expect(playerIds.contains(testPlayer2.id), isTrue);

        playersInTeam = await database.playerMatchDao.getPlayersOfTeamInMatch(
          matchId: matchWithTeams.id,
          teamId: testTeam2.id,
        );

        expect(playersInTeam, isNotEmpty);
        expect(playersInTeam.length, 2);

        playerIds = playersInTeam.map((p) => p.id).toSet();
        expect(playerIds.contains(testPlayer3.id), isTrue);
        expect(playerIds.contains(testPlayer4.id), isTrue);
      });

      test(
        'getPlayersInTeam() returns empty list for non-existent match',
        () async {
          final players = await database.playerMatchDao.getPlayersOfTeamInMatch(
            matchId: 'non-existent-match-id',
            teamId: testTeam1.id,
          );
          expect(players, isEmpty);
        },
      );
    });

    group('UPDATE', () {
      test('updateMatchPlayers() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final newPlayers = [testPlayer1, testPlayer2, testPlayer4];
        await database.playerDao.addPlayersAsList(players: newPlayers);

        final existingPlayers = await database.playerMatchDao.getPlayersOfMatch(
          matchId: testMatch1.id,
        );
        expect(existingPlayers, isNotEmpty);

        await database.playerMatchDao.updateMatchPlayers(
          matchId: testMatch1.id,
          player: newPlayers,
        );

        final updatedPlayers = await database.playerMatchDao.getPlayersOfMatch(
          matchId: testMatch1.id,
        );
        expect(updatedPlayers, isNotEmpty);
        expect(updatedPlayers.length, newPlayers.length);

        /// Create a map of new players for easy lookup
        final testPlayers = {for (var p in newPlayers) p.id: p};

        for (final player in updatedPlayers) {
          final testPlayer = testPlayers[player.id]!;

          expect(player.id, testPlayer.id);
          expect(player.name, testPlayer.name);
          expect(player.createdAt, testPlayer.createdAt);
        }
      });

      test('updatePlayersTeam() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);
        await database.teamDao.addTeam(team: testTeam1, matchId: testMatch1.id);
        await database.teamDao.addTeam(team: testTeam2, matchId: testMatch1.id);

        await database.playerMatchDao.addPlayerToMatch(
          matchId: testMatch1.id,
          playerId: testPlayer1.id,
          teamId: testTeam1.id,
        );

        final updated = await database.playerMatchDao.updatePlayersTeam(
          matchId: testMatch1.id,
          playerId: testPlayer1.id,
          teamId: testTeam2.id,
        );

        expect(updated, isTrue);

        final playersInTeam2 = await database.playerMatchDao
            .getPlayersOfTeamInMatch(
              matchId: testMatch1.id,
              teamId: testTeam2.id,
            );
        expect(playersInTeam2, isNotEmpty);
        expect(playersInTeam2.length, 3);

        final playersInTeam1 = await database.playerMatchDao
            .getPlayersOfTeamInMatch(
              matchId: testMatch1.id,
              teamId: testTeam1.id,
            );

        expect(playersInTeam1, isNotEmpty);
        expect(playersInTeam1.length, 1);
        expect(playersInTeam1[0].id, testPlayer2.id);
      });

      test(
        'updatePlayersTeam() returns false for non-existent player-match',
        () async {
          await database.matchDao.addMatch(match: testMatch1);

          final updated = await database.playerMatchDao.updatePlayersTeam(
            matchId: testMatch1.id,
            playerId: 'non-existent-player-id',
            teamId: testTeam1.id,
          );
          expect(updated, isFalse);
        },
      );

      test('updateMatchPlayers() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        var matchPlayers = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(matchPlayers.players.length, testMatch1.players.length);

        final newPlayersList = [testPlayer1, testPlayer2];
        await database.playerMatchDao.updateMatchPlayers(
          matchId: testMatch1.id,
          player: newPlayersList,
        );

        matchPlayers = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );

        expect(matchPlayers.players.length, 2);
        expect(matchPlayers.players.any((p) => p.id == testPlayer1.id), isTrue);
        expect(matchPlayers.players.any((p) => p.id == testPlayer2.id), isTrue);
      });

      test('updateMatchPlayers() with same players makes is ignored', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final originalPlayers = testMatch1.players;

        final updated = await database.playerMatchDao.updateMatchPlayers(
          matchId: testMatch1.id,
          player: originalPlayers,
        );
        expect(updated, isFalse);

        final players = await database.playerMatchDao.getPlayersOfMatch(
          matchId: testMatch1.id,
        );

        expect(players.length, originalPlayers.length);
        final playerIds = players.map((p) => p.id).toSet();
        for (final originalPlayer in originalPlayers) {
          expect(playerIds.contains(originalPlayer.id), isTrue);
        }
      });

      test('updateMatchPlayers() with empty list returns false', () async {
        await database.matchDao.addMatch(match: testMatch1);
        final updated = await database.playerMatchDao.updateMatchPlayers(
          matchId: testMatch1.id,
          player: [],
        );

        expect(updated, isFalse);
      });
    });

    group('DELETE', () {
      test('removePlayerFromMatch() works correctly', () async {
        await database.matchDao.addMatch(match: testMatch1);

        final playerToRemove = testMatch1.players[0];

        final removed = await database.playerMatchDao.removePlayerFromMatch(
          playerId: playerToRemove.id,
          matchId: testMatch1.id,
        );
        expect(removed, isTrue);

        final result = await database.matchDao.getMatchById(
          matchId: testMatch1.id,
        );
        expect(result.players.length, testMatch1.players.length - 1);

        final playerExists = result.players.any(
          (p) => p.id == playerToRemove.id,
        );
        expect(playerExists, isFalse);
      });

      test(
        'removePlayerFromMatch() returns false for non-existent player',
        () async {
          await database.matchDao.addMatch(match: testMatch1);

          final removed = await database.playerMatchDao.removePlayerFromMatch(
            playerId: 'non-existent-player-id',
            matchId: testMatch1.id,
          );

          expect(removed, isFalse);
        },
      );
    });
  });
}
