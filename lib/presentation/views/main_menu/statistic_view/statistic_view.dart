import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/icon_utils.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/data/statistics/statistic_calculator.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_group_view.dart';
import 'package:tallee/presentation/views/main_menu/statistic_view/choose_enum_view.dart';
import 'package:tallee/presentation/views/main_menu/statistic_view/create_statistic_view.dart';
import 'package:tallee/presentation/views/main_menu/statistic_view/statistic_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/cards/text_chip.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/statistics_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class StatisticsView extends StatefulWidget {
  /// A view that displays player statistics
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  bool isLoading = true;
  int selectedFilterIndex = 0;
  List<Match> matches = [];
  List<Player> players = [];
  List<Group> groups = [];
  List<Game> games = [];
  List<Statistic> statistics = [];
  List<Widget> statisticTiles = List.generate(
    4,
    (index) => buildSkeletonStatisticTile(),
  );

  List<Game> filteredGames = [];
  List<Group> filteredGroups = [];
  List<StatisticType> filteredStatisticTypes = [];
  List<StatisticScope> filteredStatisticScopes = [];
  List<Timeframe> filteredTimeframes = [];

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
              child: statistics.isEmpty && !isLoading
                  ? Center(
                      child: TopCenteredMessage(
                        icon: Icons.info,
                        title: loc.info,
                        message: loc.no_statistics_created_yet,
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: CustomTheme.listViewPadding(context),
                      header: statistics.isEmpty && !isLoading
                          ? Skeleton.keep(
                              child: Container(
                                margin: CustomTheme.tileMargin,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          spacing: 10,
                                          children: [
                                            // All Chip
                                            TextChip(
                                              text: loc.all,
                                              activated: noFilterActivated,
                                              onTap: () => resetFilter(),
                                            ),

                                            // Groups Chip
                                            TextChip(
                                              text: loc.groups,
                                              activated:
                                                  filteredGroups.isNotEmpty,
                                              count: filteredGroups.length,
                                              onTap: () async {
                                                final result =
                                                    await Navigator.of(
                                                      context,
                                                    ).push(
                                                      adaptivePageRoute(
                                                        fullscreenDialog: true,
                                                        builder: (context) =>
                                                            ChooseGroupView(
                                                              groups: groups,
                                                              initialGroups:
                                                                  filteredGroups,
                                                              enableMultiSelection:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                setState(() {
                                                  filteredGroups = result ?? [];
                                                });
                                                filterStatistics();
                                              },
                                            ),

                                            // Games Chip
                                            TextChip(
                                              text: loc.games,
                                              count: filteredGames.length,
                                              activated:
                                                  filteredGames.isNotEmpty,
                                              onTap: () async {
                                                final result =
                                                    await Navigator.of(
                                                      context,
                                                    ).push(
                                                      adaptivePageRoute(
                                                        fullscreenDialog: true,
                                                        builder: (context) =>
                                                            ChooseGameView(
                                                              games: games,
                                                              initialGames:
                                                                  filteredGames,
                                                              enableMultiSelection:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                setState(() {
                                                  filteredGames = result ?? [];
                                                });
                                                filterStatistics();
                                              },
                                            ),

                                            // Type Chip
                                            TextChip(
                                              text: loc.type,
                                              count:
                                                  filteredStatisticTypes.length,
                                              activated: filteredStatisticTypes
                                                  .isNotEmpty,
                                              onTap: () async {
                                                final result =
                                                    await Navigator.of(
                                                      context,
                                                    ).push(
                                                      adaptivePageRoute(
                                                        fullscreenDialog: true,
                                                        builder: (context) =>
                                                            ChooseEnumView<
                                                              StatisticType
                                                            >(
                                                              enumValue:
                                                                  StatisticType
                                                                      .values,

                                                              initialEnums:
                                                                  filteredStatisticTypes,
                                                              enableMultiSelection:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                setState(() {
                                                  filteredStatisticTypes =
                                                      List<StatisticType>.from(
                                                        result ??
                                                            const <
                                                              StatisticType
                                                            >[],
                                                      );
                                                });
                                                filterStatistics();
                                              },
                                            ),

                                            // Timeframe Chip
                                            TextChip(
                                              text: loc.timeframe,
                                              count: filteredTimeframes.length,
                                              activated:
                                                  filteredTimeframes.isNotEmpty,
                                              onTap: () async {
                                                final result =
                                                    await Navigator.of(
                                                      context,
                                                    ).push(
                                                      adaptivePageRoute(
                                                        fullscreenDialog: true,
                                                        builder: (context) =>
                                                            ChooseEnumView<
                                                              Timeframe
                                                            >(
                                                              enumValue:
                                                                  Timeframe
                                                                      .values,

                                                              initialEnums:
                                                                  filteredTimeframes,
                                                              enableMultiSelection:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                setState(() {
                                                  filteredTimeframes =
                                                      List<Timeframe>.from(
                                                        result ??
                                                            const <Timeframe>[],
                                                      );
                                                });
                                                filterStatistics();
                                              },
                                            ),

                                            // Scope
                                            TextChip(
                                              text: loc.scope,
                                              count: filteredStatisticScopes
                                                  .length,
                                              activated: filteredStatisticScopes
                                                  .isNotEmpty,
                                              onTap: () async {
                                                final result =
                                                    await Navigator.of(
                                                      context,
                                                    ).push(
                                                      adaptivePageRoute(
                                                        fullscreenDialog: true,
                                                        builder: (context) =>
                                                            ChooseEnumView<
                                                              StatisticScope
                                                            >(
                                                              enumValue:
                                                                  StatisticScope
                                                                      .values,
                                                              initialEnums:
                                                                  filteredStatisticScopes,
                                                              enableMultiSelection:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                setState(() {
                                                  filteredStatisticScopes =
                                                      List<StatisticScope>.from(
                                                        result ??
                                                            const <
                                                              StatisticScope
                                                            >[],
                                                      );
                                                });
                                                filterStatistics();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : null,
                      footer: statisticTiles.isEmpty && !isLoading
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: TopCenteredMessage(
                                icon: Icons.info,
                                title: loc.info,
                                message: loc.no_statistics_with_filter,
                              ),
                            )
                          : null,
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          child: child,
                          builder: (context, child) {
                            final t = Curves.easeOut.transform(animation.value);
                            const tileMargin = CustomTheme.tileMargin;
                            return Transform.scale(
                              scale: 1.0 + (0.02 * t),
                              child: Material(
                                color: Colors.transparent,
                                elevation: 8 * t,
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    ?child,
                                    Positioned(
                                      left: tileMargin.left,
                                      right: tileMargin.right,
                                      top: tileMargin.top,
                                      bottom: tileMargin.bottom,
                                      child: IgnorePointer(
                                        child: AnimatedOpacity(
                                          duration: const Duration(
                                            milliseconds: 100,
                                          ),
                                          opacity: 1 * t,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(15),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          final stat = statistics.removeAt(oldIndex);
                          statistics.insert(newIndex, stat);
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
                      itemCount: statisticTiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return statisticTiles[index];
                      },
                    ),
            ),
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 20,
              child: FloatingAnimatedButton(
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

  bool get noFilterActivated =>
      filteredGroups.isEmpty &&
      filteredGames.isEmpty &&
      filteredStatisticTypes.isEmpty &&
      filteredStatisticScopes.isEmpty &&
      filteredTimeframes.isEmpty;

  void resetFilter() {
    setState(() {
      filteredGroups = [];
      filteredGames = [];
      filteredStatisticTypes = [];
      filteredStatisticScopes = [];
      filteredTimeframes = [];
    });
    filterStatistics();
  }

  /// Loads all statistics and needed data from the database
  Future<void> loadStatistics(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final db = Provider.of<AppDatabase>(context, listen: false);

    final results = await Future.wait([
      db.statisticDao.getAllStatistics(),
      db.matchDao.getAllMatches(),
      db.playerDao.getAllPlayers(),
      db.groupDao.getAllGroups(),
      db.gameDao.getAllGames(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]);

    if (!mounted) return;

    statistics = results[0] as List<Statistic>
      ..sort((stat1, stat2) => stat2.createdAt.compareTo(stat1.createdAt));
    matches = results[1] as List<Match>;
    players = results[2] as List<Player>;
    groups = results[3] as List<Group>;
    games = results[4] as List<Game>;

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
      key: ValueKey(statistic.id),
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
      key: ValueKey('statistic_skeleton_${Random().nextInt(10000)}'),
      icon: Icons.bar_chart,
      title: 'Skeleton title',
      values: values,
      barColor: getRandomAppColorValue(),
      selectedGames: [Game(name: 'Game 1', ruleset: Ruleset.highestScore)],
      selectedGroups: [Group(name: 'Group 1', members: [])],
      displayCount: 5,
    );
  }

  // Filtering the statistics
  void filterStatistics() {
    final filtered = statistics.where(matchesActiveFilters).toList();

    setState(() {
      statisticTiles = filtered
          .map((stat) => buildStatisticTile(context: context, statistic: stat))
          .toList();
    });
  }

  /// Whether [statistic] satisfies all currently active filters.
  bool matchesActiveFilters(Statistic statistic) {
    if (filteredStatisticTypes.isNotEmpty &&
        !filteredStatisticTypes.contains(statistic.type)) {
      return false;
    }

    if (filteredTimeframes.isNotEmpty &&
        !filteredTimeframes.contains(statistic.timeframe)) {
      return false;
    }

    if (filteredStatisticScopes.isNotEmpty &&
        !statistic.scopes.any(filteredStatisticScopes.contains)) {
      return false;
    }

    if (filteredGroups.isNotEmpty) {
      final groupIds =
          statistic.selectedGroups?.map((group) => group.id).toSet() ??
          const <String>{};
      if (!filteredGroups.any((group) => groupIds.contains(group.id))) {
        return false;
      }
    }

    if (filteredGames.isNotEmpty) {
      final gameIds =
          statistic.selectedGames?.map((game) => game.id).toSet() ??
          const <String>{};
      if (!filteredGames.any((game) => gameIds.contains(game.id))) {
        return false;
      }
    }

    return true;
  }
}
