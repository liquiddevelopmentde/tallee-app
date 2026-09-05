import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/data/statistics/statistic_calculator.dart';

void main() {
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Game singleWinnerGame;
  late Game loserGame;
  late Game highestScoreGame;
  late Game lowestScoreGame;
  late Game multipleWinnersGame;
  late Game placementGame;
  late Game livesGame;
  late Group testGroup;
  late List<Match> matches;

  Match buildMatch({
    required String name,
    required Game game,
    required List<Player> players,
    required Map<Player, int> scores,
    Group? group,
    DateTime? createdAt,
    DateTime? endedAt,
  }) {
    return Match(
      name: name,
      game: game,
      players: players,
      group: group,
      createdAt: createdAt,
      endedAt: endedAt,
      scores: {
        for (final entry in scores.entries)
          entry.key.id: ScoreEntry(score: entry.value),
      },
    );
  }

  setUp(() {
    testPlayer1 = Player(name: 'Alice');
    testPlayer2 = Player(name: 'Bob');
    testPlayer3 = Player(name: 'Charlie');
    testPlayer4 = Player(name: 'Diana');

    singleWinnerGame = Game(
      name: 'Single Winner Game',
      ruleset: Ruleset.winner,
      color: AppColor.green,
    );
    loserGame = Game(
      name: 'Single Loser Game',
      ruleset: Ruleset.loser,
      color: AppColor.green,
    );
    highestScoreGame = Game(
      name: 'Highest Score Game',
      ruleset: Ruleset.highestScore,
      color: AppColor.blue,
    );
    lowestScoreGame = Game(
      name: 'Lowest Score Game',
      ruleset: Ruleset.lowestScore,
      color: AppColor.blue,
    );
    multipleWinnersGame = Game(
      name: 'Multiple Winners Game',
      ruleset: Ruleset.winner,
      color: AppColor.green,
    );
    placementGame = Game(
      name: 'Placement Game',
      ruleset: Ruleset.placement,
      color: AppColor.blue,
    );
    livesGame = Game(
      name: 'Lives Game',
      ruleset: Ruleset.lives,
      color: AppColor.blue,
    );

    testGroup = Group(name: 'Group AB', members: [testPlayer1, testPlayer2]);

    final players = [testPlayer1, testPlayer2, testPlayer3];
    matches = [
      buildMatch(
        name: 'highestScoreMatch1',
        game: highestScoreGame,
        players: players,
        scores: {testPlayer1: 10, testPlayer2: 5, testPlayer3: 8},
      ),
      buildMatch(
        name: 'highestScoreMatch2',
        game: highestScoreGame,
        players: players,
        scores: {testPlayer1: 4, testPlayer2: 9, testPlayer3: 6},
      ),
      buildMatch(
        name: 'lowestScoreMatch',
        game: lowestScoreGame,
        players: players,
        scores: {testPlayer1: 6, testPlayer2: 3, testPlayer3: 9},
      ),
      buildMatch(
        name: 'singleWinnerMatch',
        game: singleWinnerGame,
        players: players,
        scores: {testPlayer1: 1},
      ),
      buildMatch(
        name: 'loserMatch',
        game: loserGame,
        players: players,
        scores: {testPlayer1: 0},
      ),
      buildMatch(
        name: 'multipleWinnersMatch',
        game: multipleWinnersGame,
        players: players,
        scores: {testPlayer1: 1, testPlayer2: 1},
      ),
      buildMatch(
        name: 'placementMatch',
        game: placementGame,
        players: players,
        scores: {testPlayer1: 1, testPlayer2: 3, testPlayer3: 2},
      ),
      buildMatch(
        name: 'livesMatch',
        game: livesGame,
        players: players,
        scores: {testPlayer1: 2, testPlayer2: 0, testPlayer3: 3},
      ),
    ];
  });

  /// Expected value for every player id under a specific [type].
  Map<String, num> expectedFor(StatisticType type) {
    final a = testPlayer1.id;
    final b = testPlayer2.id;
    final c = testPlayer3.id;
    switch (type) {
      case StatisticType.totalMatches:
        return {a: 8, b: 8, c: 8};
      case StatisticType.totalWins:
        return {a: 4, b: 5, c: 2};
      case StatisticType.totalLosses:
        return {a: 4, b: 3, c: 6};
      case StatisticType.winrate:
        return {a: 0.5, b: 0.63, c: 0.25};
      case StatisticType.totalScore:
        return {a: 20, b: 17, c: 23};
      case StatisticType.averageScore:
        return {a: 6.67, b: 5.67, c: 7.67};
      case StatisticType.bestScore:
        return {a: 10, b: 9, c: 9};
      case StatisticType.worstScore:
        return {a: 4, b: 3, c: 6};
    }
  }

  group('StatisticCalculator computes values for every StatisticType', () {
    for (final type in StatisticType.values) {
      test('Computes correct values for ${type.name}', () {
        final statistic = Statistic(
          type: type,
          scopes: [StatisticScope.allPlayers],
        );

        final values = StatisticCalculator.computeStatisticValues(
          statistic: statistic,
          matches: matches,
          players: [testPlayer1, testPlayer2, testPlayer3],
        );

        final expected = expectedFor(type);

        final actual = {for (final entry in values) entry.$1.id: entry.$2};
        expect(actual, expected);

        // Sorted results, ascending for worstScore, descending otherwise
        final actualOrder = values.map((entry) => entry.$2).toList();
        final expectedOrder = expected.values.toList()
          ..sort(
            (x, y) => type == StatisticType.worstScore
                ? x.compareTo(y)
                : y.compareTo(x),
          );
        expect(actualOrder, expectedOrder);
      });
    }
  });

  group('StatisticCalculator filtering', () {
    test('Excludes players without score for score-based statistics', () {
      final scoreMatches = [
        Match(
          name: 'm1',
          game: highestScoreGame,
          players: [testPlayer1, testPlayer2],
          scores: {testPlayer1.id: ScoreEntry(score: 10), testPlayer2.id: null},
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.totalScore,
        scopes: [StatisticScope.allPlayers],
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: scoreMatches,
        players: [testPlayer1, testPlayer2],
      );

      expect(values.length, 1);
      expect(values.single.$1.id, testPlayer1.id);
      expect(values.single.$2, 10);
    });

    test('Filters out non score-based rulesets for score statistics', () {
      final scoreMatches = [
        buildMatch(
          name: 'winner-only-match',
          game: singleWinnerGame,
          players: [testPlayer1],
          scores: {testPlayer1: 1},
        ),
        buildMatch(
          name: 'score-match',
          game: highestScoreGame,
          players: [testPlayer1],
          scores: {testPlayer1: 10},
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.totalScore,
        scopes: [StatisticScope.allPlayers],
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: scoreMatches,
        players: [testPlayer1],
      );

      expect(values.single.$2, 10);
    });

    test(
      'Filters by selected games and only keeps players from filtered matches',
      () {
        final gameMatches = [
          buildMatch(
            name: 'game-a-match',
            game: singleWinnerGame,
            players: [testPlayer1, testPlayer2],
            scores: {testPlayer1: 1, testPlayer2: 0},
          ),
          buildMatch(
            name: 'game-b-match',
            game: loserGame,
            players: [testPlayer3],
            scores: {testPlayer3: 1},
          ),
        ];

        final statistic = Statistic(
          type: StatisticType.totalMatches,
          scopes: [StatisticScope.selectedGames],
          selectedGames: [loserGame],
        );

        final values = StatisticCalculator.computeStatisticValues(
          statistic: statistic,
          matches: gameMatches,
          players: [testPlayer1, testPlayer2, testPlayer3],
        );

        expect(values.length, 1);
        expect(values.single.$1.id, testPlayer3.id);
        expect(values.single.$2, 1);
      },
    );

    test('Filters by selected groups and keeps only group members', () {
      final groupMatches = [
        buildMatch(
          name: 'group-match',
          game: highestScoreGame,
          group: testGroup,
          players: [testPlayer1, testPlayer2],
          scores: {testPlayer1: 3, testPlayer2: 2},
        ),
        buildMatch(
          name: 'outside-group-match',
          game: highestScoreGame,
          players: [testPlayer3],
          scores: {testPlayer3: 7},
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.totalScore,
        scopes: [StatisticScope.selectedGroups],
        selectedGroups: [testGroup],
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: groupMatches,
        players: [testPlayer1, testPlayer2, testPlayer3],
      );

      expect(values.length, 2);
      expect(
        values.map((v) => v.$1.id),
        containsAll([testPlayer1.id, testPlayer2.id]),
      );
      expect(values.map((v) => v.$1.id), isNot(contains(testPlayer3.id)));
    });

    test('Filters matches by timeframe last7Days', () {
      final now = DateTime.now();
      final timeframeMatches = [
        buildMatch(
          name: 'recent',
          game: highestScoreGame,
          players: [testPlayer1],
          scores: {testPlayer1: 10},
          createdAt: now.subtract(const Duration(days: 2)),
          endedAt: now.subtract(const Duration(days: 2)),
        ),
        buildMatch(
          name: 'old',
          game: highestScoreGame,
          players: [testPlayer1],
          scores: {testPlayer1: 20},
          createdAt: now.subtract(const Duration(days: 20)),
          endedAt: now.subtract(const Duration(days: 20)),
        ),
        buildMatch(
          name: 'long time',
          game: highestScoreGame,
          players: [testPlayer1],
          scores: {testPlayer1: 20},
          createdAt: now.subtract(const Duration(days: 20)),
          endedAt: now.subtract(const Duration(days: 2)),
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.totalMatches,
        scopes: [StatisticScope.allPlayers],
        timeframe: Timeframe.last7Days,
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: timeframeMatches,
        players: [testPlayer1],
      );

      expect(values.single.$2, 1);
    });

    test('Filters matches by custom timeframe', () {
      final startDate = DateTime(2023, 1, 10);
      final endDate = DateTime(2023, 1, 20);

      final timeframeMatches = [
        buildMatch(
          name: 'too early',
          game: highestScoreGame,
          players: [testPlayer1],
          scores: {testPlayer1: 10},
          createdAt: DateTime(2023, 1, 9, 23, 59),
          endedAt: DateTime(2023, 1, 9, 23, 59),
        ),
        buildMatch(
          name: 'start day',
          game: highestScoreGame,
          players: [testPlayer1],
          scores: {testPlayer1: 10},
          createdAt: DateTime(2023, 1, 10, 0, 0),
          endedAt: DateTime(2023, 1, 10, 0, 0),
        ),
        buildMatch(
          name: 'middle',
          game: highestScoreGame,
          players: [testPlayer1],
          scores: {testPlayer1: 10},
          createdAt: DateTime(2023, 1, 15),
          endedAt: DateTime(2023, 1, 15),
        ),
        buildMatch(
          name: 'end day',
          game: highestScoreGame,
          players: [testPlayer1],
          scores: {testPlayer1: 10},
          createdAt: DateTime(2023, 1, 20, 23, 59),
          endedAt: DateTime(2023, 1, 20, 23, 59),
        ),
        buildMatch(
          name: 'too late',
          game: highestScoreGame,
          players: [testPlayer1],
          scores: {testPlayer1: 10},
          createdAt: DateTime(2023, 1, 21, 0, 0),
          endedAt: DateTime(2023, 1, 21, 0, 0),
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.totalMatches,
        scopes: [StatisticScope.allPlayers],
        timeframe: Timeframe.custom,
        startDate: startDate,
        endDate: endDate,
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: timeframeMatches,
        players: [testPlayer1],
      );

      expect(values.single.$2, 3);
    });

    test('Returns 0.0 winrate for players with no played matches', () {
      final statistic = Statistic(
        type: StatisticType.winrate,
        scopes: [StatisticScope.allPlayers],
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: matches,
        players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
      );

      final dianaValue = values.firstWhere(
        (entry) => entry.$1.id == testPlayer4.id,
      );
      expect(dianaValue.$2, 0.0);
    });
  });
}
