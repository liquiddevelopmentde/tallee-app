import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/data/statistics/statistic_calculator.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/statistic_view/create_statistic_view.dart';
import 'package:tallee/presentation/views/main_menu/statistic_view/statistic_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/animated_dialog_button.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
import 'package:tallee/presentation/widgets/tiles/statistics_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class StatisticsView extends StatefulWidget {
  /// A view that displays player statistics
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  bool isLoading = true;
  List<Match> matches = const [];
  List<Player> players = const [];
  List<Statistic> statistics = const [];
  List<Widget> statisticTiles = List.generate(
    4,
    (index) => Column(
      children: [buildSkeletonStatisticTile(), const SizedBox(height: 12)],
    ),
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      loadStatistics(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AppSkeleton(
              enabled: isLoading,
              fixLayoutBuilder: true,
              alignment: Alignment.topCenter,
              child: Visibility(
                visible: statisticTiles.isNotEmpty,
                replacement: Center(
                  child: TopCenteredMessage(
                    icon: Icons.info,
                    title: loc.info,
                    content: Skeleton.unite(
                      child: Column(
                        children: [
                          Text(loc.no_statistics_created_yet),
                          AnimatedDialogButton(
                            buttonText: loc.create_example_statistics,
                            onPressed: () => createExampleStatistics(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: ListView.builder(
                  padding: CustomTheme.listViewPadding(context),
                  itemCount: statisticTiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return statisticTiles[index];
                  },
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 20,
              child: MainMenuButton(
                text: loc.create_statistic,
                icon: Icons.bar_chart,
                onPressed: () async {
                  if (!mounted) return;
                  final navigator = Navigator.of(this.context);
                  await navigator.push<Statistic>(
                    adaptivePageRoute(
                      builder: (context) => CreateStatisticView(
                        onStatisticCreated: (newStats) {
                          if (!mounted) return;
                          setState(() {
                            statistics = [...newStats, ...statistics];
                            statisticTiles = statistics
                                .map(
                                  (stat) => buildStatisticTile(
                                    context: context,
                                    statistic: stat,
                                  ),
                                )
                                .toList();
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Creates example statistics
  void createExampleStatistics() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final stat1 = Statistic(
      type: StatisticType.totalWins,
      color: AppColor.blue,
      displayCount: 5,
      createdAt: DateTime.now(),
      scopes: [StatisticScope.selectedGroups],
    );
    final stat2 = Statistic(
      type: StatisticType.averageScore,
      color: AppColor.pink,
      displayCount: 5,
      createdAt: DateTime.now(),
      scopes: [StatisticScope.selectedGroups],
    );
    final stat3 = Statistic(
      type: StatisticType.averageScore,
      color: AppColor.green,
      displayCount: 5,
      createdAt: DateTime.now(),
      scopes: [StatisticScope.selectedGroups],
    );
    await db.statisticDao.addStatisticsAsList(
      statistics: [stat1, stat2, stat3],
    );

    statistics = [stat1, stat2, stat3];
    setState(() {
      statisticTiles = statistics
          .map((stat) => buildStatisticTile(context: context, statistic: stat))
          .toList();
    });
  }

  /// Loads all statistics, matches, and players from the database
  Future<void> loadStatistics(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final db = Provider.of<AppDatabase>(context, listen: false);

    final results = await Future.wait([
      db.statisticDao.getAllStatistics(),
      db.matchDao.getAllMatches(),
      db.playerDao.getAllPlayers(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]);

    if (!mounted) return;

    statistics = results[0] as List<Statistic>
      ..sort((stat1, stat2) => stat2.createdAt.compareTo(stat1.createdAt));
    matches = results[1] as List<Match>;
    players = results[2] as List<Player>;

    setState(() {
      statisticTiles = statistics
          .map((stat) => buildStatisticTile(context: context, statistic: stat))
          .toList();
      isLoading = false;
    });
  }

  /// Refreshes a statistic by its ID, either updating it or removing it if
  /// it was deleted
  Future<void> refreshStatistic(String statId) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final newStat = await db.statisticDao.getStatisticById(statisticId: statId);
    if (newStat == null) {
      // If the statistic was deleted, remove it from the list
      statistics = statistics.where((stat) => stat.id != statId).toList();
    } else {
      // else update it
      final index = statistics.indexWhere((stat) => stat.id == statId);
      if (index == -1) {
        return;
      } else {
        statistics[index] = newStat;
      }
    }
    setState(() {
      statisticTiles = statistics
          .map((stat) => buildStatisticTile(context: context, statistic: stat))
          .toList();
    });
  }

  /// Builds a [StatisticTile] for a given statistic.
  Widget buildStatisticTile({
    required BuildContext context,
    required Statistic statistic,
    double? width,
  }) {
    final values = StatisticCalculator.computeStatisticValues(
      statistic: statistic,
      matches: matches,
      players: players,
    );

    return GestureDetector(
      onTap: () async {
        if (!mounted) return;
        final navigator = Navigator.of(this.context);
        await navigator.push(
          adaptivePageRoute(
            builder: (context) => StatisticDetailView(
              statistic: statistic,
              values: values,
              icon: getStatisticIcon(type: statistic.type),
              barColor: getColorFromAppColor(statistic.color),
              refreshStatistic: refreshStatistic,
            ),
          ),
        );
      },
      child: StatisticsTile(
        icon: getStatisticIcon(type: statistic.type),
        title: translateStatisticTypeToString(statistic.type, context),
        values: values,
        barColor: getColorFromAppColor(statistic.color),
        displayCount: statistic.displayCount,
        selectedGroups: statistic.selectedGroups,
        selectedGames: statistic.selectedGames,
      ),
    );
  }

  /// A placeholder tile with mock data for the loading state.
  static Widget buildSkeletonStatisticTile() {
    final count = 4 + Random().nextInt(5); // 4..8
    final values = <(Player, num)>[
      for (var i = 0; i < count; i++)
        (Player(name: 'Player ${i + 1}'), count - i),
    ];

    return StatisticsTile(
      icon: Icons.bar_chart,
      title: 'Skeleton title',
      values: values,
      barColor: getRandomAppColorValue(),
      selectedGames: [Game(name: 'Game 1', ruleset: Ruleset.highestScore)],
      selectedGroups: [Group(name: 'Group 1', members: [])],
      displayCount: 5,
    );
  }
}
