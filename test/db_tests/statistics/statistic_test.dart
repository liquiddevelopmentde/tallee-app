import 'dart:core';

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
import 'package:tallee/data/models/statistic.dart';

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
        color: GameColor.blue,
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

  test('Adding/fetching statistic works correclty', () async {
    final statistic = Statistic(
      type: StatisticType.averageScore,
      scopes: [StatisticScope.allPlayers, StatisticScope.selectedGames],
      timeframe: Timeframe.allTime,
      selectedGames: [testGame],
      selectedGroups: [testGroup1],
    );

    final added = await database.statisticDao.addStatistic(
      statistic: statistic,
    );
    expect(added, isTrue);

    final fetched = await database.statisticDao.getStatisticById(statistic.id);
    expect(fetched, isNotNull);
    expect(fetched!.type, statistic.type);
  });
}
