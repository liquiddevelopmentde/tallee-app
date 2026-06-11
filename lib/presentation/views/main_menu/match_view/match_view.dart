import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:once/once.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_match_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/match_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';
import 'package:tallee/state/match_search_provider.dart';

class MatchView extends StatefulWidget {
  /// A view that displays a list of matches
  const MatchView({super.key});

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  late final AppDatabase db;
  late final MatchSearchProvider _searchProvider;
  bool isLoading = true;

  TextEditingController searchBarController = TextEditingController();

  /// Loaded matches from the database, initially filled with skeleton matches
  List<Match> matches = List.filled(
    4,
    Match(
      name: 'Skeleton match name',
      game: Game(
        name: 'Game name',
        ruleset: Ruleset.singleWinner,
        color: AppColor.blue,
        icon: '',
      ),
      group: Group(
        name: 'Group name',
        members: List.filled(5, Player(name: 'Player')),
      ),
      players: [
        Player(name: 'Player'),
        Player(name: 'Player'),
        Player(name: 'Player'),
        Player(name: 'Player'),
        Player(id: 'mvp_id', name: 'Player'),
      ],
      scores: {'mvp_id': ScoreEntry(score: 1)},
      endedAt: DateTime.now(),
    ),
  );

  late List<Match> filteredMatches = [...matches];

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _searchProvider = Provider.of<MatchSearchProvider>(context, listen: false);
    _searchProvider.addListener(_handleSearchToggle);

    Once.runOnce(
      'exampleStats',
      callback: () {
        addExampleStatistics();
      },
    );

    loadMatches();
  }

  @override
  void dispose() {
    _searchProvider.removeListener(_handleSearchToggle);
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final searchProvider = Provider.of<MatchSearchProvider>(context);

    // Reset filtered matches when search is disabled
    if (!searchProvider.isSearching) {
      filteredMatches = [...matches];
    }

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );

                  return ClipRect(
                    child: SizeTransition(
                      sizeFactor: curvedAnimation,
                      alignment: Alignment.topCenter,
                      child: FadeTransition(
                        opacity: curvedAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                child: searchProvider.isSearching
                    ? Padding(
                        key: const ValueKey('match-searchbar-visible'),
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 10,
                        ),
                        child: CustomSearchBar(
                          controller: searchBarController,
                          hintText: '',
                          onChanged: (value) {
                            setState(() {
                              filterMatches(value);
                            });
                          },
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('match-searchbar-hidden'),
                      ),
              ),
              Expanded(
                child: AppSkeleton(
                  enabled: isLoading,
                  child: Visibility(
                    visible: matches.isNotEmpty,
                    replacement: Center(
                      child: TopCenteredMessage(
                        icon: Icons.info,
                        title: loc.info,
                        message: loc.no_matches_created_yet,
                      ),
                    ),
                    child: Visibility(
                      visible: filteredMatches.isNotEmpty,
                      replacement: Center(
                        child: TopCenteredMessage(
                          icon: Icons.info,
                          title: loc.info,
                          message: loc.there_is_no_match_matching_your_search,
                        ),
                      ),
                      child: ListView.builder(
                        padding: CustomTheme.listViewPadding(context),
                        itemCount: filteredMatches.length,

                        itemBuilder: (BuildContext context, int index) {
                          return MatchTile(
                            onPlayerEdited: loadMatches,
                            width: MediaQuery.sizeOf(context).width * 0.95,
                            onTap: () async {
                              Navigator.push(
                                context,
                                adaptivePageRoute(
                                  builder: (context) => MatchDetailView(
                                    match: filteredMatches[index],
                                    onMatchUpdate: loadMatches,
                                  ),
                                ),
                              );
                            },
                            match: filteredMatches[index],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: FloatingAnimatedButton(
              text: loc.create_match,
              icon: RpgAwesome.clovers_card,
              onPressed: () async {
                Navigator.push(
                  context,
                  adaptivePageRoute(
                    builder: (context) => CreateMatchView(
                      onWinnerChanged: loadMatches,
                      onMatchesUpdated: loadMatches,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void filterMatches(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMatches = [...matches];
      } else {
        final List<({Match match, int score})> scoredMatches = [];

        for (final match in matches) {
          int maxScore = 0;

          // Check match name
          maxScore = max(maxScore, weightedRatio(match.name, query));

          // Check game name
          maxScore = max(maxScore, weightedRatio(match.game.name, query));

          // Check group name
          if (match.group != null) {
            maxScore = max(maxScore, weightedRatio(match.group!.name, query));
          }

          // Check player names
          for (final player in match.players) {
            maxScore = max(
              maxScore,
              weightedRatio('${player.name} #${player.nameCount}', query),
            );
          }

          // Check team names
          if (match.teams != null) {
            for (final team in match.teams!) {
              maxScore = max(maxScore, weightedRatio(team.name, query));
            }
          }

          if (maxScore >= Constants.FUZZY_SEARCH_THRESHOLD) {
            scoredMatches.add((match: match, score: maxScore));
          }
        }

        // Sort by score descending
        scoredMatches.sort((a, b) => b.score.compareTo(a.score));
        filteredMatches = scoredMatches.map((e) => e.match).toList();
      }
    });
  }

  void _handleSearchToggle() {
    if (!mounted) {
      return;
    }

    if (!_searchProvider.isSearching) {
      searchBarController.clear();
    }
  }

  /// Loads the matches from the database and sorts them by creation date.
  void loadMatches() {
    isLoading = true;
    Future.wait([
      db.matchDao.getAllMatches(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]).then((results) {
      if (mounted) {
        setState(() {
          final loadedMatches = results[0] as List<Match>;
          matches = [...loadedMatches]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (searchBarController.text.isEmpty) {
            filteredMatches = [...matches];
          } else {
            filterMatches(searchBarController.text);
          }
          isLoading = false;
        });
      }
    });
  }

  Future<void> addExampleStatistics() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final stat1 = Statistic(
      type: StatisticType.totalWins,
      color: AppColor.blue,
      displayCount: 3,
      scopes: [StatisticScope.allPlayers],
    );
    final stat2 = Statistic(
      type: StatisticType.averageScore,
      color: AppColor.pink,
      displayCount: 5,
      scopes: [StatisticScope.allPlayers],
    );
    final stat3 = Statistic(
      type: StatisticType.averageScore,
      color: AppColor.green,
      displayCount: 8,
      scopes: [StatisticScope.allPlayers],
    );
    await db.statisticDao.addStatisticsAsList(
      statistics: [stat1, stat2, stat3],
    );
  }
}
