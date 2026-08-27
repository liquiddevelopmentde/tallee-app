import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/custom_radio_list_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class SinglePlayerSelectionWidget extends StatefulWidget {
  const SinglePlayerSelectionWidget({
    this.availablePlayers,
    this.initialSelectedPlayer,
    required this.onChanged,
    this.onPlayerCreated,
    super.key,
  });

  /// An optional list of players to choose from. If null, all players from the database are used.
  final List<Player>? availablePlayers;

  /// An optional list of players that should be pre-selected.
  final Player? initialSelectedPlayer;

  /// A callback function that is invoked whenever the selection changes,
  final Function(Player player) onChanged;

  /// A callback function that is invoked when a player was created in this widget
  final VoidCallback? onPlayerCreated;

  @override
  State<SinglePlayerSelectionWidget> createState() =>
      _SinglePlayerSelectionWidgetState();
}

class _SinglePlayerSelectionWidgetState
    extends State<SinglePlayerSelectionWidget> {
  late final AppDatabase db;
  bool isLoading = true;

  /// Future that loads all players from the database.
  late Future<List<Player>> allPlayersFuture;

  /// The complete list of all available players.
  List<Player> allPlayers = [];

  /// The list of players suggested based on the search input.
  List<Player> suggestedPlayers = [];

  Player? selectedPlayer;

  /// Controller for the search bar input.
  late final TextEditingController _searchBarController =
      TextEditingController();

  /// Skeleton data used while loading players.
  late final List<Player> skeletonData = List.filled(
    5,
    Player(name: 'Player 0'),
  );

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    suggestedPlayers = skeletonData;

    if (widget.initialSelectedPlayer != null) {
      selectedPlayer = widget.initialSelectedPlayer;
    }

    loadPlayerList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomSearchBar(
            maxLength: Constants.MAX_PLAYER_NAME_LENGTH,
            controller: _searchBarController,
            constraints: const BoxConstraints(maxHeight: 45, minHeight: 45),
            hintText: loc.search_for_players,
            trailingButtonShown: true,
            trailingButtonicon: Icons.add_circle,
            trailingButtonEnabled: _searchBarController.text.trim().isNotEmpty,
            onTrailingButtonPressed: () async {
              addNewPlayerFromSearch(context: context);
            },
            onChanged: (value) {
              setState(() {
                // Filters the list of suggested players based on the search input.
                if (value.isEmpty) {
                  // If the search is empty, it shows all players.
                  suggestedPlayers = [...allPlayers];
                } else {
                  // If there is input, it filters by fuzzy match.
                  final List<({Player player, int score})> scoredPlayers = [];

                  for (final player in allPlayers) {
                    final score = weightedRatio(player.name, value);
                    if (score >= Constants.FUZZY_SEARCH_THRESHOLD) {
                      scoredPlayers.add((player: player, score: score));
                    }
                  }

                  // Sort by score descending
                  scoredPlayers.sort((a, b) => b.score.compareTo(a.score));
                  suggestedPlayers = scoredPlayers
                      .map((e) => e.player)
                      .toList();
                }
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: AppSkeleton(
              enabled: isLoading,
              child: Visibility(
                visible: suggestedPlayers.isNotEmpty,
                replacement: TopCenteredMessage(
                  icon: Icons.info,
                  title: loc.info,
                  message: _getInfoText(context),
                  fullscreen: false,
                ),
                child: RadioGroup<Player>(
                  groupValue: selectedPlayer,
                  onChanged: (value) {
                    if (value != null) {
                      widget.onChanged(value);
                    }
                  },
                  child: ListView.builder(
                    itemCount: suggestedPlayers.length,
                    itemBuilder: (context, index) {
                      final player = suggestedPlayers[index];
                      return CustomRadioListTile<Player>(
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: buildUnitNameWidget(
                            player,
                            mainStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            countStyle: TextStyle(
                              fontSize: 16,
                              color: CustomTheme.textColor.withAlpha(100),
                            ),
                          ),
                        ),
                        value: player,
                        onContainerTap: (value) async {
                          await HapticFeedback.selectionClick();
                          setState(() {
                            selectedPlayer = value;
                          });
                          widget.onChanged(value);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Loads the list of players from the database or uses the provided available players.
  /// Sets the loading state and updates the player lists accordingly.
  void loadPlayerList() {
    allPlayersFuture = Future.wait([
      db.playerDao.getAllPlayers(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]).then((results) => results[0] as List<Player>);

    allPlayersFuture.then((loadedPlayers) {
      if (!mounted) return;
      setState(() {
        // If a list of available players is provided (even if empty), use that list.
        if (widget.availablePlayers != null) {
          widget.availablePlayers!.sort((a, b) => a.name.compareTo(b.name));
          allPlayers = [...widget.availablePlayers!];
        } else {
          // Otherwise, use the loaded players from the database.
          loadedPlayers.sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
          allPlayers = [...loadedPlayers];
        }
        suggestedPlayers = [...allPlayers];
        isLoading = false;
      });
    });
  }

  /// Adds a new player to the database from the search bar input.
  /// Shows a snackbar indicating success or failure.
  /// [context] - BuildContext to show the snackbar.
  Future<void> addNewPlayerFromSearch({required BuildContext context}) async {
    final loc = AppLocalizations.of(context);
    final playerName = _searchBarController.text.trim();

    int nameCount = _calculateNameCount(playerName);
    final createdPlayer = Player(name: playerName, nameCount: nameCount);
    final success = await db.playerDao.addPlayer(player: createdPlayer);

    if (!context.mounted) return;

    if (success) {
      _handleSuccessfulPlayerCreation(createdPlayer);
      await HapticFeedback.successNotification();
      showSnackBarMessage(loc.successfully_added_player(playerName));
    } else {
      await HapticFeedback.errorNotification();
      showSnackBarMessage(loc.could_not_add_player(playerName));
    }
  }

  int _calculateNameCount(String playerName) {
    final playersWithSameName =
        allPlayers.where((player) => player.name == playerName).toList()
          ..sort((a, b) => a.nameCount.compareTo(b.nameCount));

    if (playersWithSameName.isEmpty) {
      return 0;
    } else if (playersWithSameName.length == 1) {
      // Initialize nameCount
      playersWithSameName[0].nameCount = 1;
    }

    // Return following count
    return playersWithSameName.length + 1;
  }

  /// Updates the state after successfully adding a new player.
  void _handleSuccessfulPlayerCreation(Player player) {
    widget.onPlayerCreated?.call();
    selectedPlayer = player;
    widget.onChanged(player);
    allPlayers.add(player);

    setState(() {
      _searchBarController.clear();
      suggestedPlayers = [...allPlayers];
    });
  }

  /// Displays a snackbar message at the bottom of the screen.
  /// [message] - The message to display in the snackbar.
  void showSnackBarMessage(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(CustomSnackBar(message: message));
  }

  /// Determines the appropriate info text to display when no players
  /// are available in the suggested players list.
  String _getInfoText(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (allPlayers.isEmpty) {
      // No players exist in the database
      return loc.no_players_created_yet;
    } else if (widget.availablePlayers?.isEmpty == true) {
      // available players list is provided but empty
      return loc.all_players_selected;
    } else {
      // No players match the search query
      return loc.no_players_found_with_that_name;
    }
  }
}
