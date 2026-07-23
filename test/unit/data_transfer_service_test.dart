import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
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
  late Statistic testStatistic;
  final fixedDate = DateTime(2025, 11, 19, 0, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
        color: AppColor.blue,
        icon: 'chess_icon',
      );

      testGroup = Group(
        name: 'Test Group',
        description: 'Group for testing',
        members: [testPlayer1, testPlayer2],
      );

      testTeam = Team(
        name: 'Test Team',
        color: AppColor.yellow,
        score: 5,
        members: [testPlayer1, testPlayer2],
      );

      testMatch = Match(
        name: 'Test Match',
        game: testGame,
        group: testGroup,
        players: [testPlayer1, testPlayer2],
        notes: 'Test notes',
        scores: {
          testPlayer1.id: ScoreEntry(roundNumber: 1, score: 10, change: 10),
          testPlayer2.id: ScoreEntry(roundNumber: 1, score: 15, change: 15),
        },
      );

      testStatistic = Statistic(
        type: StatisticType.totalScore,
        scopes: [StatisticScope.selectedGames, StatisticScope.selectedGroups],
        timeframe: Timeframe.last30Days,
        color: AppColor.yellow,
        selectedGames: [testGame],
        selectedGroups: [testGroup],
        displayCount: 7,
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

  // Builds a schema-valid .tallee json string from the test entities.
  String buildJson() => json.encode({
    'players': [
      {
        'id': testPlayer1.id,
        'name': testPlayer1.name,
        'description': testPlayer1.description,
        'createdAt': testPlayer1.createdAt.toIso8601String(),
        'deleted': false,
      },
      {
        'id': testPlayer2.id,
        'name': testPlayer2.name,
        'description': testPlayer2.description,
        'createdAt': testPlayer2.createdAt.toIso8601String(),
        'deleted': false,
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
    'matches': [
      {
        'id': testMatch.id,
        'name': testMatch.name,
        'gameId': testGame.id,
        'groupId': testGroup.id,
        'playerIds': [testPlayer1.id, testPlayer2.id],
        'notes': testMatch.notes,
        'scores': {
          testPlayer1.id: {'roundNumber': 1, 'score': 10, 'change': 10},
          testPlayer2.id: {'roundNumber': 1, 'score': 15, 'change': 15},
        },
        'createdAt': testMatch.createdAt.toIso8601String(),
        'endedAt': null,
        'isTeamMatch': false,
        'teams': null,
      },
    ],
    'statistics': <dynamic>[],
  });

  group('DataTransferService Tests', () {
    testWidgets('deleteAllData()', (tester) async {
      await database.playerDao.addPlayer(player: testPlayer1);
      await database.gameDao.addGame(game: testGame);
      await database.groupDao.addGroup(group: testGroup);
      await database.matchDao.addMatch(match: testMatch);
      await database.teamDao.addTeam(team: testTeam, matchId: testMatch.id);

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
          await database.matchDao.addMatch(match: testMatch);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);

          expect(jsonString, isNotEmpty);

          final decoded = json.decode(jsonString) as Map<String, dynamic>;

          expect(decoded.containsKey('players'), isTrue);
          expect(decoded.containsKey('games'), isTrue);
          expect(decoded.containsKey('groups'), isTrue);
          expect(decoded.containsKey('matches'), isTrue);

          final players = decoded['players'] as List<dynamic>;
          final games = decoded['games'] as List<dynamic>;
          final groups = decoded['groups'] as List<dynamic>;
          final matches = decoded['matches'] as List<dynamic>;

          expect(players.length, 2);
          expect(games.length, 1);
          expect(groups.length, 1);
          expect(matches.length, 1);
        });

        testWidgets('Exporting empty returns empty string', (tester) async {
          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);

          expect(jsonString, isEmpty);
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

          // Verify scores are properly structured (single score per player, not list)
          expect(scoresJson[testPlayer1.id], isNotNull);
          expect(scoresJson[testPlayer2.id], isNotNull);

          // Parse player 1 score
          final player1ScoreJson =
              scoresJson[testPlayer1.id] as Map<String, dynamic>;
          final player1Score = ScoreEntry.fromJson(player1ScoreJson);
          expect(player1Score.roundNumber, 1);
          expect(player1Score.score, 10);
          expect(player1Score.change, 10);

          // Parse player 2 score
          final player2ScoreJson =
              scoresJson[testPlayer2.id] as Map<String, dynamic>;
          final player2Score = ScoreEntry.fromJson(player2ScoreJson);
          expect(player2Score.roundNumber, 1);
          expect(player2Score.score, 15);
          expect(player2Score.change, 15);
        });

        testWidgets('Statistic data is correct', (tester) async {
          await database.playerDao.addPlayersAsList(
            players: [testPlayer1, testPlayer2],
          );
          await database.gameDao.addGame(game: testGame);
          await database.groupDao.addGroup(group: testGroup);
          await database.statisticDao.addStatistic(statistic: testStatistic);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;

          expect(decoded.containsKey('statistics'), isTrue);
          final stats = decoded['statistics'] as List<dynamic>;
          expect(stats.length, 1);

          final statData = stats[0] as Map<String, dynamic>;
          expect(statData['id'], testStatistic.id);
          expect(statData['type'], testStatistic.type.name);
          expect(statData['timeframe'], testStatistic.timeframe.name);
          expect(statData['color'], testStatistic.color.name);
          expect(statData['displayCount'], testStatistic.displayCount);
          expect(
            statData['selectedGames'],
            containsAll(testStatistic.selectedGames!.map((g) => g.id)),
          );
          expect(
            statData['selectedGroups'],
            containsAll(testStatistic.selectedGroups!.map((g) => g.id)),
          );
        });

        testWidgets('Match with teams is handled correctly', (tester) async {
          final matchWithTeams = Match(
            name: 'Match with Teams',
            game: testGame,
            players: [testPlayer1, testPlayer2],
            teams: [testTeam],
            notes: 'Team match',
          );

          await database.playerDao.addPlayersAsList(
            players: [testPlayer1, testPlayer2],
          );
          await database.gameDao.addGame(game: testGame);
          await database.matchDao.addMatch(match: matchWithTeams);

          final ctx = await getContext(tester);
          final jsonString = await DataTransferService.getAppDataAsJson(ctx);
          final decoded = json.decode(jsonString) as Map<String, dynamic>;
          final matches = decoded['matches'] as List<dynamic>;

          expect(matches.length, 1);

          final matchData = matches[0] as Map<String, dynamic>;
          expect(matchData['id'], matchWithTeams.id);
          expect(matchData['name'], matchWithTeams.name);
          expect(
            matchData['teams'],
            isNotNull,
            reason: 'teams should not be null',
          );
          expect(matchData['teams'], isA<List>());

          final teamsInMatch = matchData['teams'] as List<dynamic>;
          expect(teamsInMatch.length, 1);

          final teamData = teamsInMatch[0] as Map<String, dynamic>;
          expect(teamData['id'], testTeam.id);
          expect(teamData['name'], testTeam.name);
          expect(teamData['memberIds'], isA<List>());

          final memberIds = teamData['memberIds'] as List<dynamic>;
          expect(memberIds.length, 2);
          expect(memberIds, containsAll([testPlayer1.id, testPlayer2.id]));
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
              color: AppColor.red,
              icon: 'icon',
            ),
            Game(
              name: 'Blue Game',
              ruleset: Ruleset.singleWinner,
              color: AppColor.blue,
              icon: 'icon',
            ),
            Game(
              name: 'Green Game',
              ruleset: Ruleset.singleWinner,
              color: AppColor.green,
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
              color: AppColor.blue,
              icon: 'icon',
            ),
            Game(
              name: 'Lowest Score Game',
              ruleset: Ruleset.lowestScore,
              color: AppColor.blue,
              icon: 'icon',
            ),
            Game(
              name: 'Single Winner',
              ruleset: Ruleset.singleWinner,
              color: AppColor.blue,
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
              'deleted': false,
            },
            {
              'id': testPlayer2.id,
              'name': testPlayer2.name,
              'description': testPlayer2.description,
              'createdAt': testPlayer2.createdAt.toIso8601String(),
              'deleted': true,
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

        final teamsJson = [
          {
            'id': testTeam.id,
            'name': testTeam.name,
            'memberIds': [testPlayer1.id],
            'createdAt': testTeam.createdAt.toIso8601String(),
            'color': testTeam.color.name,
            'score': testTeam.score,
          },
        ];

        final teams = DataTransferService.parseTeamsFromJson(
          teamsJson,
          playerById,
        );

        expect(teams.length, 1);
        expect(teams[0].id, testTeam.id);
        expect(teams[0].name, testTeam.name);
        expect(teams[0].members.length, 1);
        expect(teams[0].members[0].id, testPlayer1.id);
        expect(teams[0].color, testTeam.color);
        expect(teams[0].score, testTeam.score);
      });

      test('parseTeamsFromJson() empty list', () {
        final teams = DataTransferService.parseTeamsFromJson([], {});
        expect(teams, isEmpty);
      });

      test('parseTeamsFromJson() missing memberIds', () {
        final teamsJson = [
          {
            'id': testTeam.id,
            'name': testTeam.name,
            'createdAt': testTeam.createdAt.toIso8601String(),
          },
        ];
        final teams = DataTransferService.parseTeamsFromJson(teamsJson, {});
        expect(teams.length, 1);
        expect(teams[0].members, isEmpty);
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
              'isTeamMatch': false,
              'teams': null,
              'scores': null,
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

      test('parseMatchesFromJson() throws exception for missing game', () {
        final playerById = {testPlayer1.id: testPlayer1};
        final gameById = <String, Game>{};
        final groupById = <String, Group>{};
        const gameId = 'game-id';

        final jsonMap = {
          'matches': [
            {
              'id': testMatch.id,
              'name': testMatch.name,
              'gameId': gameId,
              'playerIds': [testPlayer1.id],
              'isTeamMatch': false,
              'teams': null,
              'scores': null,
              'notes': '',
              'createdAt': testMatch.createdAt.toIso8601String(),
            },
          ],
        };

        expect(
          () => DataTransferService.parseMatchesFromJson(
            jsonMap,
            gameById,
            groupById,
            playerById,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.toString(),
              'message',
              contains(gameId),
            ),
          ),
        );
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
              'isTeamMatch': false,
              'teams': null,
              'scores': null,
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
              'isTeamMatch': false,
              'teams': null,
              'scores': null,
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

      test('parseStatsFromJson()', () {
        final gamesById = {testGame.id: testGame};
        final groupsById = {testGroup.id: testGroup};
        final jsonMap = {
          'statistics': [
            {
              'id': testStatistic.id,
              'createdAt': testStatistic.createdAt.toIso8601String(),
              'type': testStatistic.type.name,
              'scopes': testStatistic.scopes.map((s) => s.name).toList(),
              'timeframe': testStatistic.timeframe.name,
              'color': testStatistic.color.name,
              'selectedGroups': [testGroup.id],
              'selectedGames': [testGame.id],
              'displayCount': testStatistic.displayCount,
            },
          ],
        };

        final stats = DataTransferService.parseStatsFromJson(
          jsonMap,
          gamesById,
          groupsById,
        );

        expect(stats.length, 1);
        expect(stats[0].id, testStatistic.id);
        expect(stats[0].type, testStatistic.type);
        expect(stats[0].timeframe, testStatistic.timeframe);
        expect(stats[0].color, testStatistic.color);
        expect(stats[0].displayCount, testStatistic.displayCount);
        expect(stats[0].selectedGames, isNotNull);
        expect(stats[0].selectedGames!.map((g) => g.id), contains(testGame.id));
        expect(stats[0].selectedGroups, isNotNull);
        expect(
          stats[0].selectedGroups!.map((g) => g.id),
          contains(testGroup.id),
        );
      });

      test('parseStatsFromJson() empty list', () {
        final stats = DataTransferService.parseStatsFromJson(
          {'statistics': []},
          {},
          {},
        );
        expect(stats, isEmpty);
      });

      test('parseStatsFromJson() missing key', () {
        final stats = DataTransferService.parseStatsFromJson(
          <String, dynamic>{},
          {},
          {},
        );
        expect(stats, isEmpty);
      });

      test('parseStatsFromJson() ignores invalid game/group ids', () {
        final jsonMap = {
          'statistics': [
            {
              'id': testStatistic.id,
              'createdAt': testStatistic.createdAt.toIso8601String(),
              'type': testStatistic.type.toString(),
              'scopes': testStatistic.scopes.map((s) => s.toString()).toList(),
              'timeframe': testStatistic.timeframe.toString(),
              'color': testStatistic.color.toString(),
              'selectedGroups': ['unknown-group-id'],
              'selectedGames': ['unknown-game-id'],
              'displayCount': testStatistic.displayCount,
            },
          ],
        };

        final stats = DataTransferService.parseStatsFromJson(jsonMap, {}, {});

        expect(stats.length, 1);
        expect(stats[0].selectedGames, isNull);
        expect(stats[0].selectedGroups, isNull);
      });

      test('validateJsonSchema() works correctly', () async {
        final validJson = json.encode({
          'players': [
            {
              'id': testPlayer1.id,
              'name': testPlayer1.name,
              'description': testPlayer1.description,
              'createdAt': testPlayer1.createdAt.toIso8601String(),
              'deleted': false,
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
          'matches': [
            {
              'id': testMatch.id,
              'name': testMatch.name,
              'gameId': testGame.id,
              'groupId': testGroup.id,
              'playerIds': [testPlayer1.id, testPlayer2.id],
              'notes': testMatch.notes,
              'scores': {
                testPlayer1.id: {'roundNumber': 1, 'score': 10, 'change': 10},
                testPlayer2.id: {'roundNumber': 1, 'score': 15, 'change': 15},
              },
              'createdAt': testMatch.createdAt.toIso8601String(),
              'endedAt': null,
              'isTeamMatch': true,
              'teams': [
                {
                  'id': testTeam.id,
                  'name': testTeam.name,
                  'memberIds': [testPlayer1.id, testPlayer2.id],
                  'createdAt': testTeam.createdAt.toIso8601String(),
                  'color': testTeam.color.name,
                  'score': testTeam.score,
                },
                {
                  'id': 'team-2',
                  'name': 'Team 2',
                  'memberIds': [testPlayer3.id],
                  'createdAt': testTeam.createdAt.toIso8601String(),
                  'color': 'red',
                  'score': 0,
                },
              ],
            },
          ],
          'statistics': [
            {
              'id': testStatistic.id,
              'createdAt': testStatistic.createdAt.toIso8601String(),
              'type': testStatistic.type.name,
              'scopes': testStatistic.scopes.map((s) => s.name).toList(),
              'timeframe': testStatistic.timeframe.name,
              'color': testStatistic.color.name,
              'selectedGroups': null,
              'selectedGames': [testGame.id],
              'displayCount': testStatistic.displayCount,
              'isFavourite': testStatistic.isFavourite,
            },
            {
              'id': testStatistic.id,
              'createdAt': testStatistic.createdAt.toIso8601String(),
              'type': testStatistic.type.name,
              'scopes': testStatistic.scopes.map((s) => s.name).toList(),
              'timeframe': testStatistic.timeframe.name,
              'color': testStatistic.color.name,
              'selectedGroups': [testGroup.id],
              'selectedGames': null,
              'displayCount': testStatistic.displayCount,
              'isFavourite': testStatistic.isFavourite,
            },
            {
              'id': testStatistic.id,
              'createdAt': testStatistic.createdAt.toIso8601String(),
              'type': testStatistic.type.name,
              'scopes': testStatistic.scopes.map((s) => s.name).toList(),
              'timeframe': testStatistic.timeframe.name,
              'color': testStatistic.color.name,
              'selectedGroups': [testGroup.id],
              'selectedGames': [testGame.id],
              'displayCount': testStatistic.displayCount,
              'isFavourite': testStatistic.isFavourite,
            },
          ],
        });

        final isValidRoot = await DataTransferService.validateJsonSchema(
          validJson,
        );
        expect(isValidRoot, true);
      });

      group('Schema Validation', () {
        test('validateJsonSchema() returns true for valid data', () async {
          final validJson = json.encode({
            'players': [
              {
                'id': testPlayer1.id,
                'name': testPlayer1.name,
                'description': testPlayer1.description,
                'createdAt': testPlayer1.createdAt.toIso8601String(),
                'deleted': false,
              },
              {
                'id': testPlayer2.id,
                'name': testPlayer2.name,
                'description': testPlayer2.description,
                'createdAt': testPlayer2.createdAt.toIso8601String(),
                'deleted': true,
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
            'matches': [
              {
                'id': testMatch.id,
                'name': testMatch.name,
                'gameId': testGame.id,
                'groupId': testGroup.id,
                'playerIds': [testPlayer1.id, testPlayer2.id],
                'notes': testMatch.notes,
                'isTeamMatch': false,
                'teams': null,
                'scores': {
                  testPlayer1.id: {'roundNumber': 1, 'score': 10, 'change': 10},
                  testPlayer2.id: {'roundNumber': 1, 'score': 15, 'change': 15},
                },
                'createdAt': testMatch.createdAt.toIso8601String(),
                'endedAt': null,
              },
            ],
            'statistics': [
              {
                'id': testStatistic.id,
                'createdAt': testStatistic.createdAt.toIso8601String(),
                'type': testStatistic.type.name,
                'scopes': testStatistic.scopes.map((s) => s.name).toList(),
                'timeframe': testStatistic.timeframe.name,
                'color': testStatistic.color.name,
                'selectedGroups': [testGroup.id],
                'selectedGames': [testGame.id],
                'displayCount': testStatistic.displayCount,
                'isFavourite': testStatistic.isFavourite,
              },
              {
                'id': testStatistic.id,
                'createdAt': testStatistic.createdAt.toIso8601String(),
                'type': testStatistic.type.name,
                'scopes': testStatistic.scopes.map((s) => s.name).toList(),
                'timeframe': testStatistic.timeframe.name,
                'color': testStatistic.color.name,
                'selectedGroups': null,
                'selectedGames': [testGame.id],
                'displayCount': testStatistic.displayCount,
                'isFavourite': testStatistic.isFavourite,
              },
              {
                'id': testStatistic.id,
                'createdAt': testStatistic.createdAt.toIso8601String(),
                'type': testStatistic.type.name,
                'scopes': testStatistic.scopes.map((s) => s.name).toList(),
                'timeframe': testStatistic.timeframe.name,
                'color': testStatistic.color.name,
                'selectedGroups': [testGroup.id],
                'selectedGames': null,
                'displayCount': testStatistic.displayCount,
                'isFavourite': testStatistic.isFavourite,
              },
            ],
          });

          final isValid = await DataTransferService.validateJsonSchema(
            validJson,
          );
          expect(isValid, true);
        });

        test(
          'validateJsonSchema() returns false for group with only 1 member',
          () async {
            final invalidJson = json.encode({
              'players': [
                {
                  'id': testPlayer1.id,
                  'name': testPlayer1.name,
                  'description': testPlayer1.description,
                  'createdAt': testPlayer1.createdAt.toIso8601String(),
                },
              ],
              'games': [],
              'groups': [
                {
                  'id': 'group-1',
                  'name': 'Invalid Group',
                  'description': '',
                  'memberIds': [testPlayer1.id],
                  'createdAt': fixedDate.toIso8601String(),
                },
              ],
              'matches': [],
              'statistics': [
                {
                  'id': testStatistic.id,
                  'createdAt': testStatistic.createdAt.toIso8601String(),
                  'type': testStatistic.type.name,
                  'scopes': testStatistic.scopes.map((s) => s.name).toList(),
                  'timeframe': testStatistic.timeframe.name,
                  'color': testStatistic.color.name,
                  'selectedGroups': [testGroup.id],
                  'selectedGames': [testGame.id],
                  'displayCount': testStatistic.displayCount,
                },
              ],
            });

            final isValid = await DataTransferService.validateJsonSchema(
              invalidJson,
            );
            expect(isValid, false);
          },
        );

        test(
          'validateJsonSchema() returns false for match with only 1 player',
          () async {
            final invalidJson = json.encode({
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
              'groups': [],
              'matches': [
                {
                  'id': 'match-1',
                  'name': 'Invalid Match',
                  'gameId': testGame.id,
                  'playerIds': [testPlayer1.id],
                  'notes': '',
                  'createdAt': fixedDate.toIso8601String(),
                },
              ],
              'statistics': [],
            });

            final isValid = await DataTransferService.validateJsonSchema(
              invalidJson,
            );
            expect(isValid, false);
          },
        );

        test(
          'validateJsonSchema() returns false for team with 0 members',
          () async {
            final invalidJson = json.encode({
              'players': [
                {
                  'id': testPlayer1.id,
                  'name': testPlayer1.name,
                  'description': '',
                  'createdAt': fixedDate.toIso8601String(),
                },
              ],
              'games': [
                {
                  'id': testGame.id,
                  'name': testGame.name,
                  'ruleset': testGame.ruleset.name,
                  'description': '',
                  'color': testGame.color.name,
                  'icon': '',
                  'createdAt': fixedDate.toIso8601String(),
                },
              ],
              'groups': [],
              'matches': [
                {
                  'id': 'match-1',
                  'name': 'Match',
                  'gameId': testGame.id,
                  'playerIds': [testPlayer1.id, testPlayer2.id],
                  'notes': '',
                  'createdAt': fixedDate.toIso8601String(),
                  'isTeamMatch': true,
                  'scores': {},
                  'teams': [
                    {
                      'id': 'team-1',
                      'name': 'Team 1',
                      'createdAt': fixedDate.toIso8601String(),
                      'color': 'blue',
                      'score': 0,
                      'memberIds': [], // Invalid: minItems 1
                    },
                    {
                      'id': 'team-2',
                      'name': 'Team 2',
                      'createdAt': fixedDate.toIso8601String(),
                      'color': 'red',
                      'score': 0,
                      'memberIds': [testPlayer2.id],
                    },
                  ],
                },
              ],
              'statistics': [],
            });

            final isValid = await DataTransferService.validateJsonSchema(
              invalidJson,
            );
            expect(isValid, false);
          },
        );

        test(
          'validateJsonSchema() returns false for team match with only 1 team',
          () async {
            final invalidJson = json.encode({
              'players': [
                {
                  'id': testPlayer1.id,
                  'name': testPlayer1.name,
                  'description': '',
                  'createdAt': fixedDate.toIso8601String(),
                },
              ],
              'games': [
                {
                  'id': testGame.id,
                  'name': testGame.name,
                  'ruleset': testGame.ruleset.name,
                  'description': '',
                  'color': testGame.color.name,
                  'icon': '',
                  'createdAt': fixedDate.toIso8601String(),
                },
              ],
              'groups': [],
              'matches': [
                {
                  'id': 'match-1',
                  'name': 'Match',
                  'gameId': testGame.id,
                  'playerIds': [testPlayer1.id, testPlayer2.id],
                  'notes': '',
                  'createdAt': fixedDate.toIso8601String(),
                  'isTeamMatch': true,
                  'scores': {},
                  'teams': [
                    {
                      'id': 'team-1',
                      'name': 'Team 1',
                      'createdAt': fixedDate.toIso8601String(),
                      'color': 'blue',
                      'score': 0,
                      'memberIds': [testPlayer1.id],
                    },
                  ],
                },
              ],
              'statistics': [],
            });

            final isValid = await DataTransferService.validateJsonSchema(
              invalidJson,
            );
            expect(isValid, false);
          },
        );
      });

      testWidgets('validateJsonSchema() validates exported json file', (
        tester,
      ) async {
        await database.playerDao.addPlayer(player: testPlayer1);
        await database.playerDao.addPlayer(player: testPlayer2);
        await database.gameDao.addGame(game: testGame);
        await database.groupDao.addGroup(group: testGroup);
        await database.matchDao.addMatch(match: testMatch);

        final ctx = await getContext(tester);
        final jsonString = await DataTransferService.getAppDataAsJson(ctx);

        expect(jsonString, isNotEmpty);

        final isValid = await tester.runAsync(
          () => DataTransferService.validateJsonSchema(jsonString),
        );
        expect(isValid, true);
      });
    });

    group('validateContent()', () {
      test('validateContent() returns true for valid data', () {
        final validData = {
          'players': [
            {'name': 'A' * 32, 'description': 'D'},
          ],
          'games': [
            {'name': 'G' * 32, 'description': 'D' * 256},
          ],
          'groups': [
            {'name': 'Gr' * 16},
          ],
          'matches': [
            {
              'name': 'M' * 32,
              'teams': [
                {'name': 'T' * 32},
              ],
            },
          ],
        };
        expect(DataTransferService.validateContent(validData), isTrue);
      });

      test('validateContent() returns false if player name is too long', () {
        final data = {
          'players': [
            {'name': 'A' * 33},
          ],
        };
        expect(DataTransferService.validateContent(data), isFalse);
      });

      test('validateContent() returns false if game name is too long', () {
        final data = {
          'games': [
            {'name': 'G' * 33},
          ],
        };
        expect(DataTransferService.validateContent(data), isFalse);
      });

      test(
        'validateContent() returns false if game description is too long',
        () {
          final data = {
            'games': [
              {'name': 'G', 'description': 'D' * 257},
            ],
          };
          expect(DataTransferService.validateContent(data), isFalse);
        },
      );

      test('validateContent() returns false if group name is too long', () {
        final data = {
          'groups': [
            {'name': 'Gr' * 17},
          ],
        };
        expect(DataTransferService.validateContent(data), isFalse);
      });

      test('validateContent() returns false if match name is too long', () {
        final data = {
          'matches': [
            {'name': 'M' * 33},
          ],
        };
        expect(DataTransferService.validateContent(data), isFalse);
      });

      test('validateContent() returns false if team name is too long', () {
        final data = {
          'matches': [
            {
              'name': 'M',
              'teams': [
                {'name': 'T' * 33},
              ],
            },
          ],
        };
        expect(DataTransferService.validateContent(data), isFalse);
      });
    });

    group('readFileContent()', () {
      test('returns decoded string when bytes are present', () async {
        const content = '{"players": []}';
        final file = PlatformFile(
          name: 'data.tallee',
          size: content.length,
          bytes: Uint8List.fromList(utf8.encode(content)),
        );

        final result = await DataTransferService.readFileContent(file);

        expect(result, content);
      });

      test('reads from path when bytes are null', () async {
        const content = '{"games": []}';
        final tempFile = File(
          '${Directory.systemTemp.path}/read_file_content_test.tallee',
        );
        await tempFile.writeAsString(content);
        addTearDown(() async {
          if (tempFile.existsSync()) await tempFile.delete();
        });

        final file = PlatformFile(
          name: 'data.tallee',
          size: content.length,
          path: tempFile.path,
        );

        final result = await DataTransferService.readFileContent(file);

        expect(result, content);
      });

      test('returns null when both bytes and path are null', () async {
        final file = PlatformFile(name: 'data.tallee', size: 0);

        final result = await DataTransferService.readFileContent(file);

        expect(result, isNull);
      });
    });

    group('commitImport()', () {
      test('returns success and writes data for valid json', () async {
        final result = await DataTransferService.commitImport(
          database,
          buildJson(),
        );

        expect(result, ImportResult.success);
        expect(await database.playerDao.getPlayerCount(), greaterThan(0));
        expect(await database.gameDao.getGameCount(), greaterThan(0));
        expect(await database.groupDao.getGroupCount(), greaterThan(0));
        expect(await database.matchDao.getMatchCount(), greaterThan(0));
      });

      test(
        'returns invalidSchema and writes nothing for invalid json',
        () async {
          final result = await DataTransferService.commitImport(
            database,
            '{"players": "not a list"}',
          );

          expect(result, ImportResult.invalidSchema);
          expect(await database.playerDao.getPlayerCount(), 0);
          expect(await database.matchDao.getMatchCount(), 0);
        },
      );

      test('returns invalidSchema for malformed json', () async {
        final result = await DataTransferService.commitImport(
          database,
          'not-json',
        );

        expect(result, ImportResult.invalidSchema);
      });
    });

    group('getDataFromPath()', () {
      test('returns fileNotFound when the file does not exist', () async {
        final missingPath = '${Directory.systemTemp.path}/missing.tallee';

        final result = await DataTransferService.getDataFromPath(missingPath);

        expect(result.$1, ImportResult.fileNotFound);
        expect(result.$2, isNull);
      });

      test('returns success and json for a valid file', () async {
        final validJson = buildJson();
        final file = File('${Directory.systemTemp.path}/data.tallee');
        await file.writeAsString(validJson);
        addTearDown(() async {
          if (file.existsSync()) await file.delete();
        });

        final result = await DataTransferService.getDataFromPath(file.path);

        expect(result.$1, ImportResult.success);
        expect(result.$2, validJson);
      });

      test('returns invalidSchema and null json for an invalid file', () async {
        final file = File('${Directory.systemTemp.path}/invalid.tallee');
        await file.writeAsString('{"players": "not a list"}');
        addTearDown(() async {
          if (file.existsSync()) await file.delete();
        });

        final result = await DataTransferService.getDataFromPath(file.path);

        expect(result.$1, ImportResult.invalidSchema);
        expect(result.$2, isNull);
      });
    });
  });
}
