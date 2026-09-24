import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_game_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/empty_message.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/game_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';
import 'package:tallee/state/game_search_provider.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final AppDatabase db;
  late final GameSearchProvider searchProvider;

  bool isLoading = true;
  late List<(Game, int)> gameCounts = [];

  final TextEditingController searchBarController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  /// Loaded games from the database, initially filled with skeleton games
  List<Game> allGames = List.filled(
    4,
    Game(
      name: 'Skeleton game name',
      ruleset: Ruleset.winner,
      color: AppColor.blue,
      description: 'Skeleton description for the game tile',
    ),
  );

  late List<Game> displayedGames = [...allGames];
  bool isSearchBarVisible = true;

  @override
  void initState() {
    super.initState();
    db = context.read<AppDatabase>();
    searchProvider = context.read<GameSearchProvider>();
    searchProvider.addListener(handleSearchToggle);

    loadGames();
  }

  @override
  void dispose() {
    searchProvider.removeListener(handleSearchToggle);
    searchBarController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final searchProvider = context.read<GameSearchProvider>();

    // Reset filtered matches when search is disabled
    if (!searchProvider.isSearching) {
      displayedGames = [...allGames];
      isSearchBarVisible = true;
    }

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
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
                child: searchProvider.isSearching && isSearchBarVisible
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
                          trailingButtonShown:
                              searchBarController.text.isNotEmpty,
                          onTrailingButtonPressed: () {
                            searchBarController.clear();
                            setState(() {
                              applySearch('');
                            });
                          },

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

              // Content
              Expanded(
                child: AppSkeleton(
                  enabled: isLoading,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (allGames.isNotEmpty)
                        if (displayedGames.isEmpty)
                          // No filtered games
                          Expanded(
                            child: Center(
                              child: TopCenteredMessage(
                                icon: Icons.info,
                                title: loc.info,
                                message:
                                    loc.there_is_no_game_matching_your_search,
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: NotificationListener<UserScrollNotification>(
                              onNotification: (notification) {
                                if (notification.direction ==
                                        ScrollDirection.reverse &&
                                    isSearchBarVisible) {
                                  setState(() => isSearchBarVisible = false);
                                } else if (notification.direction ==
                                        ScrollDirection.forward &&
                                    !isSearchBarVisible) {
                                  setState(() => isSearchBarVisible = true);
                                }
                                return true;
                              },
                              child: ListView.builder(
                                padding: CustomTheme.listViewPadding(context),
                                itemCount: displayedGames.length,

                                itemBuilder: (BuildContext context, int index) {
                                  return GameTile(
                                    gameCount: getGameCount(
                                      displayedGames[index],
                                    ),
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        adaptivePageRoute(
                                          builder: (context) => CreateGameView(
                                            gameToEdit: displayedGames[index],
                                            onGameChanged: loadGames,
                                            gameCount: getGameCount(
                                              displayedGames[index],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    game: displayedGames[index],
                                  );
                                },
                              ),
                            ),
                          )
                      // No games
                      else if (!isLoading)
                        EmptyMessage(
                          icon: GAME_ICON,
                          title: loc.no_games,
                          description: loc.no_games_created_yet,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Outside the skeleton so it is not cross-faded on loading changes
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: FloatingAnimatedButton(
              text: loc.create_game,
              icon: Icons.add,
              onPressed: () async {
                Navigator.push(
                  context,
                  adaptivePageRoute(
                    builder: (context) =>
                        CreateGameView(onGameChanged: loadGames),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void applySearch(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedGames = [...allGames];
      } else {
        final List<({Game game, int score})> scoredGames = [];

        for (final game in allGames) {
          int maxScore = 0;

          // Check game name
          maxScore = max(maxScore, weightedRatio(game.name, query));

          // Check game description
          maxScore = max(maxScore, weightedRatio(game.description, query));

          // Check ruleset name
          maxScore = max(
            maxScore,
            weightedRatio(
              translateRulesetToString(game.ruleset, context),
              query,
            ),
          );

          if (maxScore >= FUZZY_SEARCH_THRESHOLD) {
            scoredGames.add((game: game, score: maxScore));
          }
        }

        // Sort by score descending
        scoredGames.sort((a, b) => b.score.compareTo(a.score));
        displayedGames = scoredGames.map((e) => e.game).toList();
      }
    });
  }

  void handleSearchToggle() {
    if (!mounted) {
      return;
    }

    setState(() {
      isSearchBarVisible = true;
      if (!searchProvider.isSearching) {
        searchBarController.clear();
      } else {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  /// Loads the games from the database and sorts them by creation date.
  void loadGames() {
    setState(() => isLoading = true);

    Future.wait([
      db.gameDao.getAllGames(),
      db.gameDao.getAllGameCounts(),
      Future.delayed(MINIMUM_SKELETON_DURATION),
    ]).then((results) {
      if (!mounted) return;

      final loadedGames = results[0] as List<Game>;
      gameCounts = results[1] as List<(Game, int)>;

      setState(() {
        allGames = [...loadedGames]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        searchBarController.text.isEmpty
            ? displayedGames = [...allGames]
            : applySearch(searchBarController.text);
        isLoading = false;
      });
    });
  }

  /// Returns the number of matches that use the given [game].
  int getGameCount(Game game) => gameCounts
      .firstWhere((gc) => gc.$1.id == game.id, orElse: () => (game, 0))
      .$2;
}
