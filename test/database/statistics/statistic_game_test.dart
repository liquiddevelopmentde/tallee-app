import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/statistic.dart';

void main() {
  late AppDatabase database;
  late Game testGame1;
  late Game testGame2;
  late Game testGame3;
  late Statistic testStatistic;
  final fixedDate = DateTime(2025, 11, 19, 00, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() async {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

    withClock(fakeClock, () {
      testGame1 = Game(
        id: 'game1',
        name: 'Chess',
        ruleset: Ruleset.singleWinner,
        description: 'A classic strategy game',
        color: AppColor.blue,
        icon: '',
      );
      testGame2 = Game(
        id: 'game2',
        name: 'Poker',
        ruleset: Ruleset.highestScore,
        description: 'Card game',
        color: AppColor.red,
        icon: '',
      );
      testGame3 = Game(
        id: 'game3',
        name: 'Monopoly',
        ruleset: Ruleset.lowestScore,
        description: 'Board game',
        color: AppColor.green,
        icon: '',
      );
      testStatistic = Statistic(
        type: StatisticType.totalWins,
        scopes: [StatisticScope.selectedGames],
        timeframe: Timeframe.allTime,
        color: AppColor.blue,
      );
    });

    await database.gameDao.addGamesAsList(
      games: [testGame1, testGame2, testGame3],
    );
    await database.statisticDao.addStatistic(statistic: testStatistic);
  });

  tearDown(() async {
    await database.close();
  });

  group('Statistic-Game Tests', () {
    group('READ', () {
      test('getGamesForStatistic() returns null for non-existing id', () async {
        final games = await database.statisticGameDao.getGamesForStatistic(
          'non-existing-id',
        );
        expect(games, isNull);
      });

      test('getGamesForStatistic() returns the correct game', () async {
        await database.statisticGameDao.addStatisticGames(
          statisticId: testStatistic.id,
          games: [testGame1],
        );

        final games = await database.statisticGameDao.getGamesForStatistic(
          testStatistic.id,
        );
        expect(games, isNotNull);
        expect(games!.length, 1);
        expect(games.first.id, testGame1.id);
        expect(games.first.name, testGame1.name);
        expect(games.first.ruleset, testGame1.ruleset);
        expect(games.first.description, testGame1.description);
        expect(games.first.color, testGame1.color);
      });

      test('getGamesForStatistic() returns all linked games', () async {
        await database.statisticGameDao.addStatisticGames(
          statisticId: testStatistic.id,
          games: [testGame1, testGame2, testGame3],
        );

        final games = await database.statisticGameDao.getGamesForStatistic(
          testStatistic.id,
        );
        expect(games, isNotNull);
        expect(games!.length, 3);

        final ids = games.map((g) => g.id).toSet();
        expect(ids.contains(testGame1.id), isTrue);
        expect(ids.contains(testGame2.id), isTrue);
        expect(ids.contains(testGame3.id), isTrue);
      });
    });

    group('CREATE', () {
      test('addStatisticGames() returns true on success', () async {
        final success = await database.statisticGameDao.addStatisticGames(
          statisticId: testStatistic.id,
          games: [testGame1],
        );
        expect(success, isTrue);
      });

      test('addStatisticGames() adds a single game correctly', () async {
        await database.statisticGameDao.addStatisticGames(
          statisticId: testStatistic.id,
          games: [testGame1],
        );

        final games = await database.statisticGameDao.getGamesForStatistic(
          testStatistic.id,
        );
        expect(games, isNotNull);
        expect(games!.length, 1);
        expect(games.first.id, testGame1.id);
        expect(games.first.createdAt, testGame1.createdAt);
        expect(games.first.name, testGame1.name);
        expect(games.first.ruleset, testGame1.ruleset);
        expect(games.first.description, testGame1.description);
        expect(games.first.color, testGame1.color);
        expect(games.first.icon, testGame1.icon);
      });

      test('addStatisticGames() adds multiple games correctly', () async {
        await database.statisticGameDao.addStatisticGames(
          statisticId: testStatistic.id,
          games: [testGame1, testGame2],
        );

        final games = await database.statisticGameDao.getGamesForStatistic(
          testStatistic.id,
        );
        expect(games, isNotNull);
        expect(games!.length, 2);
      });

      test(
        'addStatisticGames() with duplicate game does not create duplicate entries',
        () async {
          await database.statisticGameDao.addStatisticGames(
            statisticId: testStatistic.id,
            games: [testGame1],
          );
          await database.statisticGameDao.addStatisticGames(
            statisticId: testStatistic.id,
            games: [testGame1],
          );

          final games = await database.statisticGameDao.getGamesForStatistic(
            testStatistic.id,
          );
          expect(games!.length, 1);
        },
      );
    });
  });
}
