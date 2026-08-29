import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_game_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/game_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class ChooseGameView extends StatefulWidget {
  /// A view that allows the user to choose a game from a list of available games
  /// - [games]: The list of available games
  /// - [initialGame]: The initially selected game
  /// - [onGamesUpdated]: Optional callback invoked when the games are updated
  /// - [statistic]: Optional statistic payload for choosing groups for a statistic
  const ChooseGameView({
    super.key,
    required this.games,
    this.initialGames,
    this.onGamesUpdated,
    this.statistic,
    this.enableMultiSelection = false,
  });

  final List<Game> games;
  final List<Game>? initialGames;
  final VoidCallback? onGamesUpdated;
  final Statistic? statistic;
  final bool enableMultiSelection;

  @override
  State<ChooseGameView> createState() => _ChooseGameViewState();
}

class _ChooseGameViewState extends State<ChooseGameView> {
  late final AppDatabase db;

  late List<(Game, int)> gameCounts = [];

  /// Controller for the search bar
  final TextEditingController searchBarController = TextEditingController();

  /// Currently selected game(s)
  List<Game> selectedGames = [];

  /// Games filtered according to the current search query
  late List<Game> filteredGames;
  List<Game> get games =>
      widget.games..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

  // If selecting multiple is possible
  late bool enableMultiSelection;

  @override
  void initState() {
    db = Provider.of<AppDatabase>(context, listen: false);
    fetchGameCounts();

    selectedGames = widget.initialGames ?? [];
    // Start with all games visible
    filteredGames = List<Game>.from(games);

    enableMultiSelection =
        widget.enableMultiSelection || widget.statistic != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          Visibility(
            visible: !enableMultiSelection,
            child: HapticIconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  adaptivePageRoute(
                    builder: (context) => CreateGameView(
                      onGameChanged: () {
                        widget.onGamesUpdated?.call();
                      },
                    ),
                  ),
                );
                if (result != null && result.game != null) {
                  setState(() {
                    games.insert(0, result.game);
                    games.sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
                  });
                  refreshFromSource();
                }
              },
            ),
          ),
        ],

        title: Text(loc.choose_game),
      ),
      body: PopScope(
        // This fixes that the Android Back Gesture didn't return the
        // selectedGameIndex and therefore the selected Game wasn't saved
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop(popResult);
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomSearchBar(
                controller: searchBarController,
                hintText: loc.search_for_games,
                onChanged: (value) {
                  applySearchFilter(value);
                },
              ),
            ),

            // Game list
            Expanded(
              child: Visibility(
                visible: filteredGames.isNotEmpty,
                replacement: Visibility(
                  visible: games.isNotEmpty,
                  replacement: TopCenteredMessage(
                    icon: Icons.info,
                    title: loc.info,
                    message: loc.no_games_created_yet,
                  ),
                  child: TopCenteredMessage(
                    icon: Icons.info,
                    title: loc.info,
                    message: AppLocalizations.of(
                      context,
                    ).there_are_no_games_matching_your_search,
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 85, top: 10),
                  itemCount: filteredGames.length,
                  itemBuilder: (BuildContext context, int index) {
                    final game = filteredGames[index];
                    return GameTile(
                      game: game,
                      isHighlighted: selectedGames.any(
                        (selected) => selected.id == game.id,
                      ),
                      onTap: () async {
                        setState(() {
                          if (selectedGames.contains(filteredGames[index])) {
                            selectedGames.removeWhere(
                              (group) => group.id == filteredGames[index].id,
                            );
                          } else {
                            // In single select mode only allow one group
                            if (!enableMultiSelection) {
                              selectedGames.clear();
                            }
                            selectedGames.add(filteredGames[index]);
                          }
                        });

                        // Navigate back to create match view instantly
                        if (!enableMultiSelection) {
                          await Future.delayed(
                            Constants.MINIMUM_SKELETON_DURATION,
                          ).then((_) {
                            if (!context.mounted) return;
                            Navigator.of(context).pop(
                              selectedGames.isEmpty
                                  ? null
                                  : selectedGames.first,
                            );
                          });
                        }
                      },
                      onLongPress: () async {
                        final result = await Navigator.push(
                          context,
                          adaptivePageRoute(
                            builder: (context) => CreateGameView(
                              gameToEdit: game,
                              matchCount: getMatchCount(game),
                              onGameChanged: () {
                                widget.onGamesUpdated?.call();
                              },
                            ),
                          ),
                        );
                        if (result != null && result.game != null) {
                          // Find the index in the original list to mutate
                          final originalIndex = games.indexWhere(
                            (g) => g.id == game.id,
                          );
                          if (originalIndex == -1) {
                            return;
                          }
                          if (result.delete) {
                            setState(() {
                              // deselect the game
                              if (selectedGames.any(
                                (selected) => selected.id == game.id,
                              )) {
                                selectedGames.clear();
                              }
                              games.removeAt(originalIndex);
                              widget.onGamesUpdated?.call();
                            });
                          } else {
                            setState(() {
                              games[originalIndex] = result.game;
                            });
                          }
                          refreshFromSource();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            if (widget.statistic != null)
              // Create statistic button
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                child: BottomAnimatedButton(
                  buttonConstraints: const BoxConstraints(minWidth: 390),
                  buttonText: loc.create_statistic,
                  onPressed: selectedGames.isNotEmpty
                      ? () => submitStatistic()
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Object? get popResult {
    if (widget.statistic != null) return null;
    if (enableMultiSelection) return selectedGames;
    return selectedGames.isEmpty ? null : selectedGames.first;
  }

  /// Fetches the usage count for all games and stores it in [gameCounts].
  Future<void> fetchGameCounts() async =>
      gameCounts = await db.gameDao.getGameUsage();

  /// Returns the number of matches that use the given [game].
  int getMatchCount(Game game) => gameCounts
      .firstWhere((gc) => gc.$1.id == game.id, orElse: () => (game, 0))
      .$2;

  /// Applies the search filter to the games list based on [query].
  void applySearchFilter(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredGames = List<Game>.from(games);
      });
      return;
    }

    setState(() {
      final List<({Game game, int score})> scoredGames = [];

      for (final game in games) {
        int maxScore = 0;

        // Check name
        maxScore = max(maxScore, weightedRatio(game.name, query));

        // Check description
        maxScore = max(maxScore, weightedRatio(game.description, query));

        if (maxScore >= Constants.FUZZY_SEARCH_THRESHOLD) {
          scoredGames.add((game: game, score: maxScore));
        }
      }

      // Sort by score descending
      scoredGames.sort((a, b) => b.score.compareTo(a.score));
      filteredGames = scoredGames.map((e) => e.game).toList();
    });
  }

  /// Re-applies the current filter after the underlying games list changed.
  void refreshFromSource() {
    applySearchFilter(searchBarController.text);
  }

  /// Updated the statistic with the selected games, adds it to the database
  /// and pops until the first route to update the statistic overview.
  Future<void> submitStatistic() async {
    final statistic = widget.statistic!.copyWith(selectedGames: selectedGames);
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.statisticDao.addStatistic(statistic: statistic);
    if (!mounted) return;
    Navigator.of(context).pop(statistic);
  }
}
