import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_game_view.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/game_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class ChooseGameView extends StatefulWidget {
  /// A view that allows the user to choose a game from a list of available games
  /// - [games]: The list of available games
  /// - [initialGameId]: The id of the initially selected game
  /// - [onGamesUpdated]: Optional callback invoked when the games are updated
  const ChooseGameView({
    super.key,
    required this.games,
    required this.initialGameId,
    this.onGamesUpdated,
  });

  /// A list of tuples containing the game name, description and ruleset
  final List<Game> games;

  /// The id of the initially selected game
  final String initialGameId;

  /// Optional callback invoked when the games are updated
  final VoidCallback? onGamesUpdated;

  @override
  State<ChooseGameView> createState() => _ChooseGameViewState();
}

class _ChooseGameViewState extends State<ChooseGameView> {
  late final AppDatabase db;

  late List<(Game, int)> gameCounts = [];

  /// Controller for the search bar
  final TextEditingController searchBarController = TextEditingController();

  /// Currently selected game index
  late String selectedGameId;

  /// Games filtered according to the current search query
  late List<Game> filteredGames;

  @override
  void initState() {
    db = Provider.of<AppDatabase>(context, listen: false);
    fetchGameCounts();

    selectedGameId = widget.initialGameId;

    // Start with all games visible
    filteredGames = List<Game>.from(widget.games);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop(
              selectedGameId == ''
                  ? null
                  : widget.games.firstWhere(
                      (game) => game.id == selectedGameId,
                    ),
            );
          },
        ),
        actions: [
          IconButton(
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
                  widget.games.insert(0, result.game);
                });
                _refreshFromSource();
              }
            },
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
          Navigator.of(context).pop(widget.initialGameId);
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomSearchBar(
                controller: searchBarController,
                hintText: loc.game_name,
                onChanged: (value) {
                  _applySearchFilter(value);
                },
              ),
            ),
            const SizedBox(height: 5),

            // Game list
            Expanded(
              child: Visibility(
                visible: filteredGames.isNotEmpty,
                replacement: Visibility(
                  visible: widget.games.isNotEmpty,
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
                  itemCount: filteredGames.length,
                  itemBuilder: (BuildContext context, int index) {
                    final game = filteredGames[index];
                    return GameTile(
                      title: game.name,
                      description: game.description,
                      badgeText: translateRulesetToString(
                        game.ruleset,
                        context,
                      ),
                      badgeColor: getColorFromGameColor(game.color),
                      isHighlighted: selectedGameId == game.id,
                      onTap: () async {
                        setState(() {
                          if (selectedGameId == game.id) {
                            selectedGameId = '';
                          } else {
                            selectedGameId = game.id;
                          }
                        });
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
                          final originalIndex = widget.games.indexWhere(
                            (g) => g.id == game.id,
                          );
                          if (originalIndex == -1) {
                            return;
                          }
                          if (result.delete) {
                            setState(() {
                              // deselect the game
                              if (selectedGameId == game.id) {
                                selectedGameId = '';
                              }
                              widget.games.removeAt(originalIndex);
                              widget.onGamesUpdated?.call();
                            });
                          } else {
                            setState(() {
                              widget.games[originalIndex] = result.game;
                            });
                          }
                          _refreshFromSource();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Applies the search filter to the games list based on [query].
  void _applySearchFilter(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      setState(() {
        filteredGames = List<Game>.from(widget.games);
      });
      return;
    }

    setState(() {
      filteredGames = widget.games.where((game) {
        final name = game.name.toLowerCase();
        final description = game.description.toLowerCase();
        return name.contains(q) || description.contains(q);
      }).toList();
    });
  }

  /// Re-applies the current filter after the underlying games list changed.
  void _refreshFromSource() {
    _applySearchFilter(searchBarController.text);
  }

  Future<void> fetchGameCounts() async {
    gameCounts = await db.gameDao.getGameUsage();
  }

  // Returns the number of matches that use the given [game].
  int getMatchCount(Game game) {
    return gameCounts
        .firstWhere((gc) => gc.$1.id == game.id, orElse: () => (game, 0))
        .$2;
  }
}
