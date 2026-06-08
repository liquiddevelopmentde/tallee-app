import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/data/statistics/statistic_calculator.dart';

void main() {
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Game testGame1;
  late Game testGame2;
  late Group testGroup;

  Match buildMatch({
    required String name,
    required Game game,
    required List<Player> players,
    required Map<Player, int> scores,
    Group? group,
    DateTime? endedAt,
  }) {
    return Match(
      name: name,
      game: game,
      players: players,
      group: group,
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

    testGame1 = Game(
      name: 'Game A',
      ruleset: Ruleset.highestScore,
      color: AppColor.blue,
      icon: '',
    );
    testGame2 = Game(
      name: 'Game B',
      ruleset: Ruleset.singleWinner,
      color: AppColor.green,
      icon: '',
    );

    testGroup = Group(name: 'Group AB', members: [testPlayer1, testPlayer2]);
  });

  group('StatisticCalculator', () {
    test('Calculates total wins and sorts descending', () {
      final matches = [
        buildMatch(
          name: 'm1',
          game: testGame1,
          players: [testPlayer1, testPlayer2],
          scores: {testPlayer1: 10, testPlayer2: 5},
        ),
        buildMatch(
          name: 'm2',
          game: testGame1,
          players: [testPlayer1, testPlayer2],
          scores: {testPlayer1: 7, testPlayer2: 12},
        ),
        buildMatch(
          name: 'm3',
          game: testGame1,
          players: [testPlayer1, testPlayer2],
          scores: {testPlayer1: 11, testPlayer2: 9},
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.totalWins,
        scopes: [StatisticScope.allPlayers],
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: matches,
        players: [testPlayer1, testPlayer2],
      );

      expect(values.length, 2);
      expect(values[0].$1.id, testPlayer1.id);
      expect(values[0].$2, 2);
      expect(values[1].$1.id, testPlayer2.id);
      expect(values[1].$2, 1);
    });

    test('Calculates average score with two decimals', () {
      final matches = [
        buildMatch(
          name: 'm1',
          game: testGame1,
          players: [testPlayer1],
          scores: {testPlayer1: 10},
        ),
        buildMatch(
          name: 'm2',
          game: testGame1,
          players: [testPlayer1],
          scores: {testPlayer1: 11},
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.averageScore,
        scopes: [StatisticScope.allPlayers],
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: matches,
        players: [testPlayer1],
      );

      expect(values.single.$2, 10.5);
    });

    test('Filters out non score-based rulesets for score statistics', () {
      final scoreGame = Game(
        name: 'Score Game',
        ruleset: Ruleset.highestScore,
        color: AppColor.purple,
        icon: '',
      );
      final winnerOnlyGame = Game(
        name: 'Winner Game',
        ruleset: Ruleset.singleWinner,
        color: AppColor.orange,
        icon: '',
      );

      final matches = [
        buildMatch(
          name: 'winner-only-match',
          game: winnerOnlyGame,
          players: [testPlayer1],
          scores: {testPlayer1: 99},
        ),
        buildMatch(
          name: 'score-match',
          game: scoreGame,
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
        matches: matches,
        players: [testPlayer1],
      );

      expect(values.single.$2, 10);
    });

    test(
      'Filters by selected games and only keeps players from filtered matches',
      () {
        final matches = [
          buildMatch(
            name: 'game-a-match',
            game: testGame1,
            players: [testPlayer1, testPlayer2],
            scores: {testPlayer1: 8, testPlayer2: 5},
          ),
          buildMatch(
            name: 'game-b-match',
            game: testGame2,
            players: [testPlayer3],
            scores: {testPlayer3: 9},
          ),
        ];

        final statistic = Statistic(
          type: StatisticType.totalMatches,
          scopes: [StatisticScope.selectedGames],
          selectedGames: [testGame2],
        );

        final values = StatisticCalculator.computeStatisticValues(
          statistic: statistic,
          matches: matches,
          players: [testPlayer1, testPlayer2, testPlayer3],
        );

        expect(values.length, 1);
        expect(values.single.$1.id, testPlayer3.id);
        expect(values.single.$2, 1);
      },
    );

    test('Filters by selected groups and keeps only group members', () {
      final matches = [
        buildMatch(
          name: 'group-match',
          game: testGame1,
          group: testGroup,
          players: [testPlayer1, testPlayer2],
          scores: {testPlayer1: 3, testPlayer2: 2},
        ),
        buildMatch(
          name: 'outside-group-match',
          game: testGame1,
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
        matches: matches,
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
      final matches = [
        buildMatch(
          name: 'recent',
          game: testGame1,
          players: [testPlayer1],
          scores: {testPlayer1: 10},
          endedAt: now.subtract(const Duration(days: 2)),
        ),
        buildMatch(
          name: 'old',
          game: testGame1,
          players: [testPlayer1],
          scores: {testPlayer1: 20},
          endedAt: now.subtract(const Duration(days: 20)),
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.totalMatches,
        scopes: [StatisticScope.allPlayers],
        timeframe: Timeframe.last7Days,
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: matches,
        players: [testPlayer1],
      );

      expect(values.single.$2, 1);
    });

    test('Sorts worst score ascending', () {
      final matches = [
        buildMatch(
          name: 'm1',
          game: testGame1,
          players: [testPlayer1, testPlayer2, testPlayer3],
          scores: {testPlayer1: 8, testPlayer2: 2, testPlayer3: 5},
        ),
        buildMatch(
          name: 'm2',
          game: testGame1,
          players: [testPlayer1, testPlayer2, testPlayer3],
          scores: {testPlayer1: 7, testPlayer2: 9, testPlayer3: 4},
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.worstScore,
        scopes: [StatisticScope.allPlayers],
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: matches,
        players: [testPlayer1, testPlayer2, testPlayer3],
      );

      expect(values.map((v) => v.$1.id).toList(), [
        testPlayer2.id,
        testPlayer3.id,
        testPlayer1.id,
      ]);
      expect(values.map((v) => v.$2).toList(), [2, 4, 7]);
    });

    test('Returns 0.0 winrate for players with no played matches', () {
      final matches = [
        buildMatch(
          name: 'm1',
          game: testGame1,
          players: [testPlayer1, testPlayer2],
          scores: {testPlayer1: 10, testPlayer2: 5},
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.winrate,
        scopes: [StatisticScope.allPlayers],
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: matches,
        players: [testPlayer1, testPlayer2, testPlayer4],
      );

      final dianaValue = values.firstWhere(
        (entry) => entry.$1.id == testPlayer4.id,
      );
      expect(dianaValue.$2, 0.0);
    });

    test('Counts total losses only for single loser ruleset', () {
      final singleLoserGame = Game(
        name: 'Single Loser',
        ruleset: Ruleset.singleLoser,
        color: AppColor.red,
        icon: '',
      );

      final matches = [
        buildMatch(
          name: 'l1',
          game: singleLoserGame,
          players: [testPlayer1, testPlayer2, testPlayer3],
          scores: {testPlayer1: 10, testPlayer2: 5, testPlayer3: 3},
        ),
        buildMatch(
          name: 'l2',
          game: singleLoserGame,
          players: [testPlayer1, testPlayer2, testPlayer3],
          scores: {testPlayer1: 8, testPlayer2: 2, testPlayer3: 7},
        ),
        // Not a single-loser match; must not affect totalLosses.
        buildMatch(
          name: 'winner-game',
          game: testGame2,
          players: [testPlayer1, testPlayer2],
          scores: {testPlayer1: 1, testPlayer2: 9},
        ),
      ];

      final statistic = Statistic(
        type: StatisticType.totalLosses,
        scopes: [StatisticScope.allPlayers],
      );

      final values = StatisticCalculator.computeStatisticValues(
        statistic: statistic,
        matches: matches,
        players: [testPlayer1, testPlayer2, testPlayer3],
      );

      final byId = {for (final entry in values) entry.$1.id: entry.$2};
      expect(byId[testPlayer2.id], 1);
      expect(byId[testPlayer3.id], 1);
      expect(byId[testPlayer1.id], 0);
    });
  });
}
