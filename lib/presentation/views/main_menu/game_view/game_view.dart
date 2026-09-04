import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_game_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
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

  TextEditingController searchBarController = TextEditingController();

  /// Loaded games from the database, initially filled with skeleton games
  List<Game> games = List.filled(
    4,
    Game(
      name: 'Skeleton game name',
      ruleset: Ruleset.winner,
      color: AppColor.blue,
      description: 'Skeleton description for the game tile',
    ),
  );

  late List<Game> filteredGames = [...games];

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    searchProvider = Provider.of<GameSearchProvider>(context, listen: false);
    searchProvider.addListener(handleSearchToggle);

    loadGames();
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
    final searchProvider = Provider.of<GameSearchProvider>(context);

    // Reset filtered matches when search is disabled
    if (!searchProvider.isSearching) {
      filteredGames = [...games];
    }

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
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
                              filterGames(value);
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
                    visible: games.isNotEmpty,
                    replacement: Center(
                      child: TopCenteredMessage(
                        icon: Icons.info,
                        title: loc.info,
                        message: loc.no_games_created_yet,
                      ),
                    ),
                    child: Visibility(
                      visible: filteredGames.isNotEmpty,
                      replacement: Center(
                        child: TopCenteredMessage(
                          icon: Icons.info,
                          title: loc.info,
                          message: loc.there_is_no_game_matching_your_search,
                        ),
                      ),
                      child: ListView.builder(
                        padding: CustomTheme.listViewPadding(context),
                        itemCount: filteredGames.length,

                        itemBuilder: (BuildContext context, int index) {
                          return GameTile(
                            onTap: () async {
                              Navigator.push(
                                context,
                                adaptivePageRoute(
                                  builder: (context) => CreateGameView(
                                    gameToEdit: filteredGames[index],
                                    onGameChanged: loadGames,
                                    gameCount: getGameCount(
                                      filteredGames[index],
                                    ),
                                  ),
                                ),
                              );
                            },
                            game: filteredGames[index],
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
              text: loc.create_game,
              icon: GAME_ICON,
              showAddBadge: true,
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

  void filterGames(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGames = [...games];
      } else {
        final List<({Game game, int score})> scoredGames = [];

        for (final game in games) {
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
        filteredGames = scoredGames.map((e) => e.game).toList();
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

  /// Loads the games from the database and sorts them by creation date.
  void loadGames() {
    isLoading = true;
    Future.wait([
      db.gameDao.getAllGames(),
      db.gameDao.getAllGameCounts(),
      Future.delayed(MINIMUM_SKELETON_DURATION),
    ]).then((results) {
      if (mounted) {
        setState(() {
          final loadedGames = results[0] as List<Game>;
          gameCounts = results[1] as List<(Game, int)>;

          games = [...loadedGames]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (searchBarController.text.isEmpty) {
            filteredGames = [...games];
          } else {
            filterGames(searchBarController.text);
          }
          isLoading = false;
        });
      }
    });
  }

  /// Returns the number of matches that use the given [game].
  int getGameCount(Game game) => gameCounts
      .firstWhere((gc) => gc.$1.id == game.id, orElse: () => (game, 0))
      .$2;
}
