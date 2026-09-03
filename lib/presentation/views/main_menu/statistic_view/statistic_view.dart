import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/icon_utils.dart';
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
import 'package:tallee/services/shared_preferences_service.dart';

class StatisticsView extends StatefulWidget {
  /// A view that displays player statistics
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  bool isLoading = true;

  // Data for the statistics
  List<Match> matches = [];
  List<Player> players = [];
  List<Group> groups = [];
  List<Game> games = [];
  List<Statistic> statistics = [];
  List<Widget> statisticTiles = List.generate(
    4,
    (index) => buildSkeletonStatisticTile(),
  );

  // Data for the filter option
  List<Game> filteredGames = [];
  List<Group> filteredGroups = [];
  List<StatisticType> filteredStatisticTypes = [];
  List<Timeframe> filteredTimeframes = [];
  bool showOnlyFavourites = false;

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
                      header: Container(
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
                                    Skeleton.unite(
                                      child: TextChip(
                                        text: isLoading ? 'skeleton' : loc.all,
                                        activated: noFilterActivated,
                                        onTap: () => {
                                          showOnlyFavourites = false,
                                          SharedPreferencesService.setShowFavourites(
                                            false,
                                          ),
                                          resetFilter(includeFavourites: true),
                                        },
                                      ),
                                    ),

                                    // Favourites chip
                                    Skeleton.unite(
                                      child: TextChip(
                                        text: loc.favourites,
                                        activated: showOnlyFavourites,
                                        onTap: () => {
                                          setState(() {
                                            showOnlyFavourites = true;
                                            resetFilter(
                                              includeFavourites: false,
                                            );
                                          }),
                                          SharedPreferencesService.setShowFavourites(
                                            showOnlyFavourites,
                                          ),
                                          createFilteredStatisticTiles(),
                                        },
                                      ),
                                    ),

                                    // Groups Chip
                                    Skeleton.unite(
                                      child: TextChip(
                                        text: isLoading
                                            ? 'skeleton'
                                            : loc.groups,
                                        activated: filteredGroups.isNotEmpty,
                                        count: filteredGroups.length,
                                        onTap: () async {
                                          final result =
                                              await Navigator.of(context).push(
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
                                            if (filteredGroups.isNotEmpty) {
                                              resetFavourites();
                                            }
                                          });
                                          SharedPreferencesService.setFilteredGroups(
                                            filteredGroups,
                                          );
                                          createFilteredStatisticTiles();
                                        },
                                      ),
                                    ),

                                    // Games Chip
                                    Skeleton.unite(
                                      child: TextChip(
                                        text: isLoading
                                            ? 'skeleton'
                                            : loc.games,
                                        count: filteredGames.length,
                                        activated: filteredGames.isNotEmpty,
                                        onTap: () async {
                                          final result =
                                              await Navigator.of(context).push(
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
                                            if (filteredGames.isNotEmpty) {
                                              resetFavourites();
                                            }
                                          });
                                          SharedPreferencesService.setFilteredGames(
                                            filteredGames,
                                          );
                                          createFilteredStatisticTiles();
                                        },
                                      ),
                                    ),

                                    // Type Chip
                                    Skeleton.unite(
                                      child: TextChip(
                                        text: isLoading ? 'skeleton' : loc.type,
                                        count: filteredStatisticTypes.length,
                                        activated:
                                            filteredStatisticTypes.isNotEmpty,
                                        onTap: () async {
                                          final result =
                                              await Navigator.of(context).push(
                                                adaptivePageRoute(
                                                  fullscreenDialog: true,
                                                  builder: (context) =>
                                                      ChooseEnumView<
                                                        StatisticType
                                                      >(
                                                        enumValue: StatisticType
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
                                                      const <StatisticType>[],
                                                );
                                            if (filteredStatisticTypes
                                                .isNotEmpty) {
                                              resetFavourites();
                                            }
                                          });
                                          SharedPreferencesService.setFilteredStatisticTypes(
                                            filteredStatisticTypes,
                                          );
                                          createFilteredStatisticTiles();
                                        },
                                      ),
                                    ),

                                    // Timeframe Chip
                                    Skeleton.unite(
                                      child: TextChip(
                                        text: isLoading
                                            ? 'skeleton'
                                            : loc.timeframe,
                                        count: filteredTimeframes.length,
                                        activated:
                                            filteredTimeframes.isNotEmpty,
                                        onTap: () async {
                                          final result =
                                              await Navigator.of(context).push(
                                                adaptivePageRoute(
                                                  fullscreenDialog: true,
                                                  builder: (context) =>
                                                      ChooseEnumView<Timeframe>(
                                                        enumValue:
                                                            Timeframe.values,

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
                                                  result ?? const <Timeframe>[],
                                                );
                                            if (filteredTimeframes.isNotEmpty) {
                                              resetFavourites();
                                            }
                                          });
                                          SharedPreferencesService.setFilteredTimeframes(
                                            filteredTimeframes,
                                          );
                                          createFilteredStatisticTiles();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        final db = Provider.of<AppDatabase>(
                          context,
                          listen: false,
                        );
                        db.statisticDao.updatePosition(statistics: statistics);
                      },
                      onReorderStart: (_) => HapticFeedback.heavyImpact(),
                      onReorderEnd: (_) => HapticFeedback.selectionClick(),
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
                        onStatisticCreated: (newStats) =>
                            onStatisticsCreated(newStats),
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
      filteredTimeframes.isEmpty &&
      !showOnlyFavourites;

  /// A placeholder tile with mock data for the loading state.
  static Widget buildSkeletonStatisticTile() {
    final count = 4 + Random().nextInt(5); // 4..8
    final values = <(Player, num)>[
      for (var i = 0; i < count; i++)
        (Player(name: 'Player ${i + 1}'), count - i),
    ];

    Statistic skeletonStatistic = Statistic(
      type: StatisticType.totalWins,
      scopes: [StatisticScope.allPlayers],
      color: getRandomAppColor(),
      selectedGames: [Game(name: 'Game 1', ruleset: Ruleset.highestScore)],
      selectedGroups: [Group(name: 'Group 1', members: [])],
    );

    return StatisticsTile(
      key: ValueKey('statistic_skeleton_${Random().nextInt(10000)}'),
      statistic: skeletonStatistic,
      values: values,
      displayCount: 5,
    );
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
      ..sort((a, b) => a.position.compareTo(b.position));
    matches = results[1] as List<Match>;
    players = results[2] as List<Player>;
    groups = results[3] as List<Group>;
    games = results[4] as List<Game>;

    loadFilterData();

    setState(() {
      createFilteredStatisticTiles();
      isLoading = false;
    });
  }

  /// Loads the filter data from shared preferences and applies it to the current data
  void loadFilterData() {
    final filteredGroupIds = SharedPreferencesService.getFilteredGroups();
    final filteredGameIds = SharedPreferencesService.getFilteredGames();

    filteredGroups = groups
        .where((group) => filteredGroupIds.contains(group.id))
        .toList();
    filteredGames = games
        .where((game) => filteredGameIds.contains(game.id))
        .toList();
    filteredStatisticTypes =
        SharedPreferencesService.getFilteredStatisticTypes();
    filteredTimeframes = SharedPreferencesService.getFilteredTimeframes();
    showOnlyFavourites = SharedPreferencesService.getShowFavourites();
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
        statistic: statistic,
        values: values,
        displayCount: statistic.displayCount,
        onStatisticChanged: refreshStatistic,
      ),
    );
  }

  // Create the statistic tiles based on the active filters
  void createFilteredStatisticTiles() {
    final displayedStats = statistics.where(matchesActiveFilters).toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    setState(() {
      statisticTiles = displayedStats
          .map((stat) => buildStatisticTile(context: context, statistic: stat))
          .toList();
    });
  }

  /// Adds the new statistic, updates the positions of all statistics and updates the tiles.
  void onStatisticsCreated(List<Statistic> newStats) {
    statistics = [...newStats, ...statistics];
    statistics = statistics
        .map((stat) => stat.copyWith(position: statistics.indexOf(stat)))
        .toList();
    final db = Provider.of<AppDatabase>(context, listen: false);
    db.statisticDao.updatePosition(statistics: statistics);
    createFilteredStatisticTiles();
  }

  /// Refreshes a statistic by the [statisticId], either updating it or removing it if
  /// it was deleted
  Future<void> refreshStatistic(String statisticId) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final newStat = await db.statisticDao.getStatisticById(
      statisticId: statisticId,
    );
    if (newStat == null) {
      // If the statistic was deleted, remove it from the list
      statistics = statistics.where((stat) => stat.id != statisticId).toList();
    } else {
      // else update it
      final index = statistics.indexWhere((stat) => stat.id == statisticId);
      if (index == -1) return;
      statistics[index] = newStat;
    }
    createFilteredStatisticTiles();
  }

  /// Whether [statistic] satisfies all currently active filters.
  bool matchesActiveFilters(Statistic statistic) {
    if (showOnlyFavourites && !statistic.isFavourite) {
      return false;
    }

    if (filteredStatisticTypes.isNotEmpty &&
        !filteredStatisticTypes.contains(statistic.type)) {
      return false;
    }

    if (filteredTimeframes.isNotEmpty &&
        !filteredTimeframes.contains(statistic.timeframe)) {
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

  Future<void> resetFilter({required bool includeFavourites}) async {
    setState(() {
      filteredGroups = [];
      filteredGames = [];
      filteredStatisticTypes = [];
      filteredTimeframes = [];
      if (includeFavourites) showOnlyFavourites = false;
    });
    SharedPreferencesService.deleteAllFilters(
      includeFavourites: includeFavourites,
    );
    createFilteredStatisticTiles();
  }

  Future<void> resetFavourites() async {
    setState(() {
      showOnlyFavourites = false;
      SharedPreferencesService.setShowFavourites(false);
    });
  }
}
