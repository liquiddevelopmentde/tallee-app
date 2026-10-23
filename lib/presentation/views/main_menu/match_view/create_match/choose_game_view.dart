import 'dart:math';

import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/empty_message.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/game_tile.dart';

class ChooseGameView extends StatefulWidget {
  /// A view that allows the user to choose a game from a list of available games
  /// - [games]: The list of available games
  /// - [initialSelectedGames]: The initially selected games
  /// - [onGamesUpdated]: Optional callback invoked when the games are updated
  /// - [requiredRuleset]: An optional ruleset used to enforce a specific game type. This is used during match sharing to ensure the game is compatible with the shared data.
  const ChooseGameView({
    super.key,
    required this.games,
    this.initialSelectedGames,
    this.onGamesUpdated,
    this.enableMultiSelection = false,
  });

  final List<Game> games;
  final List<Game>? initialSelectedGames;
  final VoidCallback? onGamesUpdated;
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

  Ruleset? get requiredRuleset {
    if (games.isEmpty) return null;

    final firstRuleset = games.first.ruleset;
    return games.every((game) => game.ruleset == firstRuleset)
        ? firstRuleset
        : null;
  }

  @override
  void initState() {
    db = context.read<AppDatabase>();
    fetchGameCounts();

    selectedGames = widget.initialSelectedGames ?? [];
    // Start with all games visible
    filteredGames = List<Game>.from(games);

    enableMultiSelection = widget.enableMultiSelection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.talleeColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(loc.choose_game)),
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
            if (games.isEmpty)
              // No games created
              Expanded(
                child: EmptyViewMessage(
                  icon: GAME_ICON,
                  title: loc.no_games,
                  message: loc.no_games_created_yet,
                ),
              )
            else if (filteredGames.isEmpty)
              // No games matching search query
              Expanded(
                child: EmptyViewMessage(
                  icon: GAME_ICON,
                  title: loc.no_results,
                  message: loc.there_are_no_games_matching_your_search,
                ),
              )
            else
              Expanded(
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
                          await Future.delayed(MINIMUM_SKELETON_DURATION)
                              .then((_) {
                                if (!context.mounted) return;
                                Navigator.of(context).pop(
                                  selectedGames.isEmpty
                                      ? null
                                      : selectedGames.first,
                                );
                              });
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Object? get popResult {
    if (enableMultiSelection) return selectedGames;
    return selectedGames.isEmpty ? null : selectedGames.first;
  }

  /// Fetches the usage count for all games and stores it in [gameCounts].
  Future<void> fetchGameCounts() async =>
      gameCounts = await db.gameDao.getAllGameCounts();

  /// Returns the number of matches that use the given [game].
  int getGameCount(Game game) => gameCounts
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

        if (maxScore >= FUZZY_SEARCH_THRESHOLD) {
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
}
