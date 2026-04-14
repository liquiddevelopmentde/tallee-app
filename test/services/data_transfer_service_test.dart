import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/services/data_transfer_service.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Game testGame;
  late Group testGroup;
  late Team testTeam;
  late Match testMatch;
  final fixedDate = DateTime(2025, 11, 19, 0, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

    withClock(fakeClock, () {
      testPlayer1 = Player(name: 'Alice', description: 'First test player');
      testPlayer2 = Player(name: 'Bob', description: 'Second test player');
      testPlayer3 = Player(name: 'Charlie', description: 'Third player');

      testGame = Game(
        name: 'Chess',
        ruleset: Ruleset.singleWinner,
        description: 'Strategic board game',
        color: GameColor.blue,
        icon: 'chess_icon',
      );

      testGroup = Group(
        name: 'Test Group',
        description: 'Group for testing',
        members: [testPlayer1, testPlayer2],
      );

      testTeam = Team(name: 'Test Team', members: [testPlayer1, testPlayer2]);

      testMatch = Match(
        name: 'Test Match',
        game: testGame,
        group: testGroup,
        players: [testPlayer1, testPlayer2],
        notes: 'Test notes',
        scores: {
          testPlayer1.id: [
            ScoreEntry(roundNumber: 1, score: 10, change: 10),
            ScoreEntry(roundNumber: 2, score: 20, change: 10),
          ],
          testPlayer2.id: [
            ScoreEntry(roundNumber: 1, score: 15, change: 15),
            ScoreEntry(roundNumber: 2, score: 25, change: 10),
          ],
        },
      );
    });
  });

  tearDown(() async {
    await database.close();
  });

  // Helper for getting BuildContext
  Future<BuildContext> getContext(WidgetTester tester) async {
    // Minimal widget with Provider
    await tester.pumpWidget(
      Provider<AppDatabase>.value(
        value: database,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Container();
            },
          ),
        ),
      ),
    );
    final BuildContext context = tester.element(find.byType(Container));
    return context;
  }

  group('DataTransferService Tests', () {
    testWidgets('deleteAllData()', (tester) async {
      await database.playerDao.addPlayer(player: testPlayer1);
      await database.gameDao.addGame(game: testGame);
      await database.groupDao.addGroup(group: testGroup);
      await database.teamDao.addTeam(team: testTeam);
      await database.matchDao.addMatch(match: testMatch);

      var playerCount = await database.playerDao.getPlayerCount();
      var gameCount = await database.gameDao.getGameCount();
      var groupCount = await database.groupDao.getGroupCount();
      var teamCount = await database.teamDao.getTeamCount();
      var matchCount = await database.matchDao.getMatchCount();

      expect(playerCount, greaterThan(0));
      expect(gameCount, greaterThan(0));
      expect(groupCount, greaterThan(0));
      expect(teamCount, greaterThan(0));
      expect(matchCount, greaterThan(0));

      final ctx = await getContext(tester);
      await DataTransferService.deleteAllData(ctx);

      playerCount = await database.playerDao.getPlayerCount();
      gameCount = await database.gameDao.getGameCount();
      groupCount = await database.groupDao.getGroupCount();
      teamCount = await database.teamDao.getTeamCount();
      matchCount = await database.matchDao.getMatchCount();

      expect(playerCount, 0);
      expect(gameCount, 0);
      expect(groupCount, 0);
      expect(teamCount, 0);
      expect(matchCount, 0);
    });

    group('getAppDataAsJson()', () {
      group('Whole export', () {
        testWidgets('Exporting app data works correctly', (tester) async {
          await database.playerDao.addPlayer(player: testPlayer1);
          await database.playerDao.addPlayer(player: testPlayer2);
          await database.gameDao.addGame(game: testGame);
          await database.groupDao.addGroup(group: testGroup);
          await database.teamDao.addTeam(team: testTeam);
          await database.matchDao.addMatch(match: testMatch);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);

          expect(jsonString, isNotEmpty);

          final decoded = json.decode(jsonString) as Map<String, dynamic>;

          expect(decoded.containsKey('players'), true);
          expect(decoded.containsKey('games'), true);
          expect(decoded.containsKey('groups'), true);
          expect(decoded.containsKey('teams'), true);
          expect(decoded.containsKey('matches'), true);

          final players = decoded['players'] as List<dynamic>;
          final games = decoded['games'] as List<dynamic>;
          final groups = decoded['groups'] as List<dynamic>;
          final teams = decoded['teams'] as List<dynamic>;
          final matches = decoded['matches'] as List<dynamic>;

          expect(players.length, 2);
          expect(games.length, 1);
          expect(groups.length, 1);
          expect(teams.length, 1);
          expect(matches.length, 1);
        });

        testWidgets('Exporting empty data works correctly', (tester) async {
          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);

          final decoded = json.decode(jsonString) as Map<String, dynamic>;

          final players = decoded['players'] as List<dynamic>;
          final games = decoded['games'] as List<dynamic>;
          final groups = decoded['groups'] as List<dynamic>;
          final teams = decoded['teams'] as List<dynamic>;
          final matches = decoded['matches'] as List<dynamic>;

          expect(players, isEmpty);
          expect(games, isEmpty);
          expect(groups, isEmpty);
          expect(teams, isEmpty);
          expect(matches, isEmpty);
        });
      });

      group('Checking specific data', () {
        testWidgets('Player data is correct', (tester) async {
          await database.playerDao.addPlayer(player: testPlayer1);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final players = decoded['players'] as List<dynamic>;
          final playerData = players[0] as Map<String, dynamic>;

          expect(playerData['id'], testPlayer1.id);
          expect(playerData['name'], testPlayer1.name);
          expect(playerData['description'], testPlayer1.description);
          expect(
            playerData['createdAt'],
            testPlayer1.createdAt.toIso8601String(),
          );
        });

        testWidgets('Game data is correct', (tester) async {
          await database.gameDao.addGame(game: testGame);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final games = decoded['games'] as List<dynamic>;
          final gameData = games[0] as Map<String, dynamic>;

          expect(gameData['id'], testGame.id);
          expect(gameData['name'], testGame.name);
          expect(gameData['ruleset'], testGame.ruleset.name);
          expect(gameData['description'], testGame.description);
          expect(gameData['color'], testGame.color.name);
          expect(gameData['icon'], testGame.icon);
        });

        testWidgets('Group data is correct', (tester) async {
          await database.playerDao.addPlayer(player: testPlayer1);
          await database.playerDao.addPlayer(player: testPlayer2);
          await database.groupDao.addGroup(group: testGroup);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final groups = decoded['groups'] as List<dynamic>;
          final groupData = groups[0] as Map<String, dynamic>;

          expect(groupData['id'], testGroup.id);
          expect(groupData['name'], testGroup.name);
          expect(groupData['description'], testGroup.description);
          expect(groupData['memberIds'], isA<List>());

          final memberIds = groupData['memberIds'] as List<dynamic>;
          expect(memberIds.length, 2);
          expect(memberIds, containsAll([testPlayer1.id, testPlayer2.id]));
        });

        testWidgets('Team data is correct', (tester) async {
          await database.teamDao.addTeam(team: testTeam);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final teams = decoded['teams'] as List<dynamic>;

          expect(teams.length, 1);

          final teamData = teams[0] as Map<String, dynamic>;

          expect(teamData['id'], testTeam.id);
          expect(teamData['name'], testTeam.name);
          expect(teamData['memberIds'], isA<List>());

          // Note: In this system, teams don't have independent members.
          // Team members are only tracked through matches via PlayerMatchTable.
          // Therefore, memberIds will be empty for standalone teams.
          final memberIds = teamData['memberIds'] as List<dynamic>;
          expect(memberIds, isEmpty);
        });

        testWidgets('Match data is correct', (tester) async {
          await database.playerDao.addPlayersAsList(
            players: [testPlayer1, testPlayer2],
          );
          await database.gameDao.addGame(game: testGame);
          await database.groupDao.addGroup(group: testGroup);
          await database.matchDao.addMatch(match: testMatch);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final matches = decoded['matches'] as List<dynamic>;
          final matchData = matches[0] as Map<String, dynamic>;

          expect(matchData['id'], testMatch.id);
          expect(matchData['name'], testMatch.name);
          expect(matchData['gameId'], testGame.id);
          expect(matchData['groupId'], testGroup.id);
          expect(matchData['playerIds'], isA<List>());
          expect(matchData['notes'], testMatch.notes);

          // Check player ids
          final playerIds = matchData['playerIds'] as List<dynamic>;
          expect(playerIds.length, 2);
          expect(playerIds, containsAll([testPlayer1.id, testPlayer2.id]));

          // Check scores structure
          final scoresJson = matchData['scores'] as Map<String, dynamic>;
          expect(scoresJson, isA<Map<String, dynamic>>());

          final scores = scoresJson.map(
            (playerId, scoreList) => MapEntry(
              playerId,
              (scoreList as List)
                  .map((s) => ScoreEntry.fromJson(s as Map<String, dynamic>))
                  .toList(),
            ),
          );

          expect(scores, isA<Map<String, List<ScoreEntry>>>());

          /* Player 1 scores */
          // General structure
          expect(scores[testPlayer1.id], isNotNull);
          expect(scores[testPlayer1.id]!.length, 2);

          // Round 1
          expect(scores[testPlayer1.id]![0].roundNumber, 1);
          expect(scores[testPlayer1.id]![0].score, 10);
          expect(scores[testPlayer1.id]![0].change, 10);

          // Round 2
          expect(scores[testPlayer1.id]![1].roundNumber, 2);
          expect(scores[testPlayer1.id]![1].score, 20);
          expect(scores[testPlayer1.id]![1].change, 10);

          /* Player 2 scores */
          // General structure
          expect(scores[testPlayer2.id], isNotNull);
          expect(scores[testPlayer2.id]!.length, 2);

          // Round 1
          expect(scores[testPlayer2.id]![0].roundNumber, 1);
          expect(scores[testPlayer2.id]![0].score, 15);
          expect(scores[testPlayer2.id]![0].change, 15);

          // Round 2
          expect(scores[testPlayer2.id]![1].roundNumber, 2);
          expect(scores[testPlayer2.id]![1].score, 25);
          expect(scores[testPlayer2.id]![1].change, 10);
        });

        testWidgets('Match without group is handled correctly', (tester) async {
          final matchWithoutGroup = Match(
            name: 'No Group Match',
            game: testGame,
            group: null,
            players: [testPlayer1],
            notes: 'No group',
          );

          await database.playerDao.addPlayer(player: testPlayer1);
          await database.gameDao.addGame(game: testGame);
          await database.matchDao.addMatch(match: matchWithoutGroup);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final matches = decoded['matches'] as List<dynamic>;
          final matchData = matches[0] as Map<String, dynamic>;

          expect(matchData['groupId'], isNull);
        });

        testWidgets('Match with endedAt is handled correctly', (tester) async {
          final endedDate = DateTime(2025, 12, 1, 10, 0, 0);
          final endedMatch = Match(
            name: 'Ended Match',
            game: testGame,
            players: [testPlayer1],
            endedAt: endedDate,
            notes: 'Finished',
          );

          await database.playerDao.addPlayer(player: testPlayer1);
          await database.gameDao.addGame(game: testGame);
          await database.matchDao.addMatch(match: endedMatch);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final matches = decoded['matches'] as List<dynamic>;
          final matchData = matches[0] as Map<String, dynamic>;

          expect(matchData['endedAt'], endedDate.toIso8601String());
        });

        testWidgets('Structure is consistent', (tester) async {
          await database.playerDao.addPlayer(player: testPlayer1);
          await database.gameDao.addGame(game: testGame);

          final ctx = await getContext(tester);
          final jsonString1 = await DataTransferService.getAppDataAsJson(ctx);
          final jsonString2 = await DataTransferService.getAppDataAsJson(ctx);

          expect(jsonString1, equals(jsonString2));
        });

        testWidgets('Empty match notes is handled correctly', (tester) async {
          final matchWithEmptyNotes = Match(
            name: 'Empty Notes Match',
            game: testGame,
            players: [testPlayer1],
            notes: '',
          );

          await database.playerDao.addPlayer(player: testPlayer1);
          await database.gameDao.addGame(game: testGame);
          await database.matchDao.addMatch(match: matchWithEmptyNotes);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final matches = decoded['matches'] as List<dynamic>;
          final matchData = matches[0] as Map<String, dynamic>;

          expect(matchData['notes'], '');
        });

        testWidgets('Multiple players in match is handled correctly', (
          tester,
        ) async {
          final multiPlayerMatch = Match(
            name: 'Multi Player Match',
            game: testGame,
            players: [testPlayer1, testPlayer2, testPlayer3],
            notes: 'Three players',
          );

          await database.playerDao.addPlayersAsList(
            players: [testPlayer1, testPlayer2, testPlayer3],
          );
          await database.gameDao.addGame(game: testGame);
          await database.matchDao.addMatch(match: multiPlayerMatch);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final matches = decoded['matches'] as List<dynamic>;
          final matchData = matches[0] as Map<String, dynamic>;

          final playerIds = matchData['playerIds'] as List<dynamic>;
          expect(playerIds.length, 3);
          expect(
            playerIds,
            containsAll([testPlayer1.id, testPlayer2.id, testPlayer3.id]),
          );
        });

        testWidgets('All game colors are handled correctly', (tester) async {
          final games = [
            Game(
              name: 'Red Game',
              ruleset: Ruleset.singleWinner,
              color: GameColor.red,
              icon: 'icon',
            ),
            Game(
              name: 'Blue Game',
              ruleset: Ruleset.singleWinner,
              color: GameColor.blue,
              icon: 'icon',
            ),
            Game(
              name: 'Green Game',
              ruleset: Ruleset.singleWinner,
              color: GameColor.green,
              icon: 'icon',
            ),
          ];

          await database.gameDao.addGamesAsList(games: games);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final gamesJson = decoded['games'] as List<dynamic>;

          expect(gamesJson.length, 3);
          expect(
            gamesJson.map((g) => g['color']),
            containsAll(['red', 'blue', 'green']),
          );
        });

        testWidgets('All rulesets are handled correctly', (tester) async {
          final games = [
            Game(
              name: 'Highest Score Game',
              ruleset: Ruleset.highestScore,
              color: GameColor.blue,
              icon: 'icon',
            ),
            Game(
              name: 'Lowest Score Game',
              ruleset: Ruleset.lowestScore,
              color: GameColor.blue,
              icon: 'icon',
            ),
            Game(
              name: 'Single Winner',
              ruleset: Ruleset.singleWinner,
              color: GameColor.blue,
              icon: 'icon',
            ),
          ];

          await database.gameDao.addGamesAsList(games: games);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final gamesJson = decoded['games'] as List<dynamic>;

          expect(gamesJson.length, 3);
          expect(
            gamesJson.map((g) => g['ruleset']),
            containsAll(['highestScore', 'lowestScore', 'singleWinner']),
          );
        });
      });
    });

    group('Parse Methods', () {
      test('parsePlayersFromJson()', () {
        final jsonMap = {
          'players': [
            {
              'id': testPlayer1.id,
              'name': testPlayer1.name,
              'description': testPlayer1.description,
              'createdAt': testPlayer1.createdAt.toIso8601String(),
            },
            {
              'id': testPlayer2.id,
              'name': testPlayer2.name,
              'description': testPlayer2.description,
              'createdAt': testPlayer2.createdAt.toIso8601String(),
            },
          ],
        };

        final players = DataTransferService.parsePlayersFromJson(jsonMap);

        expect(players.length, 2);
        expect(players[0].id, testPlayer1.id);
        expect(players[0].name, testPlayer1.name);
        expect(players[1].id, testPlayer2.id);
        expect(players[1].name, testPlayer2.name);
      });

      test('parsePlayersFromJson() empty list', () {
        final jsonMap = {'players': []};
        final players = DataTransferService.parsePlayersFromJson(jsonMap);
        expect(players, isEmpty);
      });

      test('parsePlayersFromJson() missing key', () {
        final jsonMap = <String, dynamic>{};
        final players = DataTransferService.parsePlayersFromJson(jsonMap);
        expect(players, isEmpty);
      });

      test('parseGamesFromJson()', () {
        final jsonMap = {
          'games': [
            {
              'id': testGame.id,
              'name': testGame.name,
              'ruleset': testGame.ruleset.name,
              'description': testGame.description,
              'color': testGame.color.name,
              'icon': testGame.icon,
              'createdAt': testGame.createdAt.toIso8601String(),
            },
          ],
        };

        final games = DataTransferService.parseGamesFromJson(jsonMap);

        expect(games.length, 1);
        expect(games[0].id, testGame.id);
        expect(games[0].name, testGame.name);
        expect(games[0].ruleset, testGame.ruleset);
      });

      test('parseGamesFromJson() empty list', () {
        final jsonMap = {'games': []};
        final games = DataTransferService.parseGamesFromJson(jsonMap);
        expect(games, isEmpty);
      });

      test('parseGamesFromJson() missing key', () {
        final jsonMap = <String, dynamic>{};
        final games = DataTransferService.parseGamesFromJson(jsonMap);
        expect(games, isEmpty);
      });

      test('parseGroupsFromJson()', () {
        final playerById = {
          testPlayer1.id: testPlayer1,
          testPlayer2.id: testPlayer2,
        };

        final jsonMap = {
          'groups': [
            {
              'id': testGroup.id,
              'name': testGroup.name,
              'description': testGroup.description,
              'memberIds': [testPlayer1.id, testPlayer2.id],
              'createdAt': testGroup.createdAt.toIso8601String(),
            },
          ],
        };

        final groups = DataTransferService.parseGroupsFromJson(
          jsonMap,
          playerById,
        );

        expect(groups.length, 1);
        expect(groups[0].id, testGroup.id);
        expect(groups[0].name, testGroup.name);
        expect(groups[0].members.length, 2);
        expect(groups[0].members[0].id, testPlayer1.id);
        expect(groups[0].members[1].id, testPlayer2.id);
      });

      test('parseGroupsFromJson() empty list', () {
        final jsonMap = {'groups': []};
        final groups = DataTransferService.parseGroupsFromJson(jsonMap, {});
        expect(groups, isEmpty);
      });

      test('parseGroupsFromJson() missing key', () {
        final jsonMap = <String, dynamic>{};
        final groups = DataTransferService.parseGroupsFromJson(jsonMap, {});
        expect(groups, isEmpty);
      });

      test('parseGroupsFromJson() ignores invalid player ids', () {
        final playerById = {testPlayer1.id: testPlayer1};

        final jsonMap = {
          'groups': [
            {
              'id': testGroup.id,
              'name': testGroup.name,
              'description': testGroup.description,
              'memberIds': [testPlayer1.id, 'invalid-id'],
              'createdAt': testGroup.createdAt.toIso8601String(),
            },
          ],
        };

        final groups = DataTransferService.parseGroupsFromJson(
          jsonMap,
          playerById,
        );

        expect(groups.length, 1);
        expect(groups[0].members.length, 1);
        expect(groups[0].members[0].id, testPlayer1.id);
      });

      test('parseTeamsFromJson()', () {
        final playerById = {testPlayer1.id: testPlayer1};

        final jsonMap = {
          'teams': [
            {
              'id': testTeam.id,
              'name': testTeam.name,
              'memberIds': [testPlayer1.id],
              'createdAt': testTeam.createdAt.toIso8601String(),
            },
          ],
        };

        final teams = DataTransferService.parseTeamsFromJson(
          jsonMap,
          playerById,
        );

        expect(teams.length, 1);
        expect(teams[0].id, testTeam.id);
        expect(teams[0].name, testTeam.name);
        expect(teams[0].members.length, 1);
        expect(teams[0].members[0].id, testPlayer1.id);
      });

      test('parseTeamsFromJson() empty list', () {
        final jsonMap = {'teams': []};
        final teams = DataTransferService.parseTeamsFromJson(jsonMap, {});
        expect(teams, isEmpty);
      });

      test('parseTeamsFromJson() missing key', () {
        final jsonMap = <String, dynamic>{};
        final teams = DataTransferService.parseTeamsFromJson(jsonMap, {});
        expect(teams, isEmpty);
      });

      test('parseMatchesFromJson()', () {
        final playerById = {
          testPlayer1.id: testPlayer1,
          testPlayer2.id: testPlayer2,
        };
        final gameById = {testGame.id: testGame};
        final groupById = {testGroup.id: testGroup};

        final jsonMap = {
          'matches': [
            {
              'id': testMatch.id,
              'name': testMatch.name,
              'gameId': testGame.id,
              'groupId': testGroup.id,
              'playerIds': [testPlayer1.id, testPlayer2.id],
              'notes': testMatch.notes,
              'createdAt': testMatch.createdAt.toIso8601String(),
            },
          ],
        };

        final matches = DataTransferService.parseMatchesFromJson(
          jsonMap,
          gameById,
          groupById,
          playerById,
        );

        expect(matches.length, 1);
        expect(matches[0].id, testMatch.id);
        expect(matches[0].name, testMatch.name);
        expect(matches[0].game.id, testGame.id);
        expect(matches[0].group?.id, testGroup.id);
        expect(matches[0].players.length, 2);
      });

      test('parseMatchesFromJson() empty list', () {
        final jsonMap = {'teams': []};
        final matches = DataTransferService.parseMatchesFromJson(
          jsonMap,
          {},
          {},
          {},
        );
        expect(matches, isEmpty);
      });

      test('parseMatchesFromJson() missing key', () {
        final jsonMap = <String, dynamic>{};
        final matches = DataTransferService.parseMatchesFromJson(
          jsonMap,
          {},
          {},
          {},
        );
        expect(matches, isEmpty);
      });

      test('parseMatchesFromJson() creates unknown game for missing game', () {
        final playerById = {testPlayer1.id: testPlayer1};
        final gameById = <String, Game>{};
        final groupById = <String, Group>{};

        final jsonMap = {
          'matches': [
            {
              'id': testMatch.id,
              'name': testMatch.name,
              'gameId': 'non-existent-game-id',
              'playerIds': [testPlayer1.id],
              'notes': '',
              'createdAt': testMatch.createdAt.toIso8601String(),
            },
          ],
        };

        final matches = DataTransferService.parseMatchesFromJson(
          jsonMap,
          gameById,
          groupById,
          playerById,
        );

        expect(matches.length, 1);
        expect(matches[0].game.name, 'Unknown');
        expect(matches[0].game.ruleset, Ruleset.singleWinner);
      });

      test('parseMatchesFromJson() handles null group', () {
        final playerById = {testPlayer1.id: testPlayer1};
        final gameById = {testGame.id: testGame};
        final groupById = <String, Group>{};

        final jsonMap = {
          'matches': [
            {
              'id': testMatch.id,
              'name': testMatch.name,
              'gameId': testGame.id,
              'groupId': null,
              'playerIds': [testPlayer1.id],
              'notes': '',
              'createdAt': testMatch.createdAt.toIso8601String(),
            },
          ],
        };

        final matches = DataTransferService.parseMatchesFromJson(
          jsonMap,
          gameById,
          groupById,
          playerById,
        );

        expect(matches.length, 1);
        expect(matches[0].group, isNull);
      });

      test('parseMatchesFromJson() handles endedAt', () {
        final playerById = {testPlayer1.id: testPlayer1};
        final gameById = {testGame.id: testGame};
        final groupById = <String, Group>{};
        final endedDate = DateTime(2025, 12, 1, 10, 0, 0);

        final jsonMap = {
          'matches': [
            {
              'id': testMatch.id,
              'name': testMatch.name,
              'gameId': testGame.id,
              'playerIds': [testPlayer1.id],
              'notes': '',
              'createdAt': testMatch.createdAt.toIso8601String(),
              'endedAt': endedDate.toIso8601String(),
            },
          ],
        };

        final matches = DataTransferService.parseMatchesFromJson(
          jsonMap,
          gameById,
          groupById,
          playerById,
        );

        expect(matches.length, 1);
        expect(matches[0].endedAt, endedDate);
      });
    });

    test('validateJsonSchema()', () async {
      final validJson = json.encode({
        'players': [
          {
            'id': testPlayer1.id,
            'name': testPlayer1.name,
            'description': testPlayer1.description,
            'createdAt': testPlayer1.createdAt.toIso8601String(),
          },
        ],
        'games': [
          {
            'id': testGame.id,
            'name': testGame.name,
            'ruleset': testGame.ruleset.name,
            'description': testGame.description,
            'color': testGame.color.name,
            'icon': testGame.icon,
            'createdAt': testGame.createdAt.toIso8601String(),
          },
        ],
        'groups': [
          {
            'id': testGroup.id,
            'name': testGroup.name,
            'description': testGroup.description,
            'memberIds': [testPlayer1.id, testPlayer2.id],
            'createdAt': testGroup.createdAt.toIso8601String(),
          },
        ],
        'teams': [
          {
            'id': testTeam.id,
            'name': testTeam.name,
            'memberIds': [testPlayer1.id, testPlayer2.id],
            'createdAt': testTeam.createdAt.toIso8601String(),
          },
        ],
        'matches': [
          {
            'id': testMatch.id,
            'name': testMatch.name,
            'gameId': testGame.id,
            'groupId': testGroup.id,
            'playerIds': [testPlayer1.id, testPlayer2.id],
            'notes': testMatch.notes,
            'scores': {
              testPlayer1.id: [
                {'roundNumber': 1, 'score': 10, 'change': 10},
                {'roundNumber': 2, 'score': 20, 'change': 10},
              ],
              testPlayer2.id: [
                {'roundNumber': 1, 'score': 15, 'change': 15},
                {'roundNumber': 2, 'score': 25, 'change': 10},
              ],
            },
            'createdAt': testMatch.createdAt.toIso8601String(),
            'endedAt': null,
          },
        ],
      });

      final isValid = await DataTransferService.validateJsonSchema(validJson);
      expect(isValid, true);
    });
  });
}
