import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_match_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/cards/text_chip.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/match_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';
import 'package:tallee/services/shared_preferences_service.dart';
import 'package:tallee/state/match_search_provider.dart';

class MatchView extends StatefulWidget {
  /// A view that displays a list of matches
  const MatchView({super.key});

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  late final AppDatabase db;
  late final MatchSearchProvider searchProvider;
  bool isLoading = true;
  MatchFilter selectedFilter =
      SharedPreferencesService.getMatchFilter() ?? MatchFilter.all;

  TextEditingController searchBarController = TextEditingController();

  /// Loaded matches from the database, initially filled with skeleton matches
  List<Match> allMatches = List.filled(
    4,
    Match(
      name: 'Skeleton match name',
      game: Game(
        name: 'Game name',
        ruleset: Ruleset.winner,
        color: AppColor.blue,
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

  /// Matches based on the selected filter
  late List<Match> filteredMatches = [...allMatches];

  /// Matches based on the search query
  late List<Match> displayedMatches = [...allMatches];

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    searchProvider = Provider.of<MatchSearchProvider>(context, listen: false);
    searchProvider.addListener(handleSearchToggle);

    loadMatches();
  }

  @override
  void dispose() {
    searchProvider.removeListener(handleSearchToggle);
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final searchProvider = Provider.of<MatchSearchProvider>(context);

    // Reset filtered matches when search is disabled
    if (!searchProvider.isSearching) applySearch('');

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AppSkeleton(
            enabled: isLoading,

            // No matches created
            child: Column(
              children: [
                // Searchbar
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
                                applySearch(value);
                              });
                            },
                          ),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('match-searchbar-hidden'),
                        ),
                ),

                // Filter row
                SingleChildScrollView(
                  padding: CustomTheme.filterRowPadding,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 5,
                    children: [
                      // All matches
                      TextChip(
                        text: loc.all,
                        onTap: () => setFilter(MatchFilter.all),
                        activated: selectedFilter == MatchFilter.all,
                      ),

                      // Active matches
                      TextChip(
                        text: loc.active_matches,
                        onTap: () => setFilter(MatchFilter.active),
                        activated: selectedFilter == MatchFilter.active,
                      ),

                      // Finished matches
                      TextChip(
                        text: loc.finished_matches,
                        onTap: () => setFilter(MatchFilter.finished),
                        activated: selectedFilter == MatchFilter.finished,
                      ),

                      // Team matches
                      TextChip(
                        text: loc.team_matches,
                        onTap: () => setFilter(MatchFilter.team),
                        activated: selectedFilter == MatchFilter.team,
                      ),

                      // To keep padding on the right side
                      const SizedBox.shrink(),
                    ],
                  ),
                ),

                // Matches
                Expanded(
                  // No matches created

                  child: allMatches.isEmpty
                      ? Center(
                          child: TopCenteredMessage(
                            icon: Icons.info,
                            title: loc.info,
                            message: loc.no_matches_created_yet,
                          ),
                        )
                      // No matches in filter
                      : filteredMatches.isEmpty
                      ? Center(
                          child: TopCenteredMessage(
                            icon: Icons.info,
                            title: loc.info,
                            message: loc.there_is_no_match_matching_your_filter,
                          ),
                        )
                      // No matches in search
                      : displayedMatches.isEmpty
                      ? TopCenteredMessage(
                          icon: Icons.info,
                          title: loc.info,
                          message: loc.there_is_no_match_matching_your_search,
                        )
                      : ListView.builder(
                          padding: CustomTheme.listViewPadding(context),
                          itemCount: displayedMatches.length,
                          itemBuilder: (BuildContext context, int index) {
                            return MatchTile(
                              width: MediaQuery.sizeOf(context).width * 0.95,
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  adaptivePageRoute(
                                    settings: const RouteSettings(
                                      name: RouteNames.matchDetailView,
                                    ),
                                    builder: (context) => MatchDetailView(
                                      match: displayedMatches[index],
                                      onMatchUpdate: loadMatches,
                                    ),
                                  ),
                                );
                              },
                              match: displayedMatches[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: FloatingAnimatedButton(
              text: loc.create_match,
              icon: MATCH_ICON,
              showAddBadge: true,
              onPressed: () async {
                Navigator.push(
                  context,
                  adaptivePageRoute(
                    settings: const RouteSettings(
                      name: RouteNames.createMatchView,
                    ),
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

  void setFilter(MatchFilter filter) {
    setState(() {
      selectedFilter = filter;
      applyFilter(filter);
    });
    SharedPreferencesService.setMatchFilter(filter);
  }

  void applyFilter(MatchFilter filter) {
    switch (filter) {
      case MatchFilter.all:
        filteredMatches = [...allMatches];
      case MatchFilter.active:
        filteredMatches = allMatches
            .where((match) => match.endedAt == null)
            .toList();
      case MatchFilter.finished:
        filteredMatches = allMatches
            .where((match) => match.endedAt != null)
            .toList();
      case MatchFilter.team:
        filteredMatches = allMatches
            .where((match) => match.isTeamMatch)
            .toList();
    }
    displayedMatches = [...filteredMatches];
  }

  void applySearch(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedMatches = [...filteredMatches];
      } else {
        final List<({Match match, int score})> scoredMatches = [];

        for (final match in allMatches) {
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

          if (maxScore >= FUZZY_SEARCH_THRESHOLD) {
            scoredMatches.add((match: match, score: maxScore));
          }
        }

        // Sort by score descending
        scoredMatches.sort((a, b) => b.score.compareTo(a.score));
        displayedMatches = scoredMatches.map((e) => e.match).toList();
      }
    });
  }

  void handleSearchToggle() {
    if (!mounted) {
      return;
    }

    if (!searchProvider.isSearching) {
      searchBarController.clear();
    }
  }

  /// Loads the matches from the database and sorts them by creation date.
  void loadMatches() {
    setState(() => isLoading = true);

    Future.wait([
      db.matchDao.getAllMatches(includeDeletedPlayer: true),
      Future.delayed(MINIMUM_SKELETON_DURATION),
    ]).then((results) {
      if (!mounted) return;

      final loadedMatches = results[0] as List<Match>;
      setState(() {
        allMatches = [...loadedMatches]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        filteredMatches = [...allMatches];

        searchBarController.text.isEmpty
            ? displayedMatches = [...allMatches]
            : applySearch(searchBarController.text);

        isLoading = false;
      });
    });
  }
}
