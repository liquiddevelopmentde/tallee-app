import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class PlayerSelection extends StatefulWidget {
  /// A widget that allows users to select players from a list,
  /// with search functionality and the ability to add new players.
  /// - [availablePlayers]: An optional list of players to choose from. If null,
  ///   all players from the database are used.
  /// - [initialSelectedPlayers]: An optional list of players that should be pre-selected.
  /// - [onChanged]: A callback function that is invoked whenever the selection
  ///   changes, providing the updated list of selected players.
  const PlayerSelection({
    super.key,
    this.availablePlayers,
    this.initialSelectedPlayers,
    required this.onChanged,
    this.onPlayerCreated,
  });

  /// An optional list of players to choose from. If null, all players from the database are used.
  final List<Player>? availablePlayers;

  /// An optional list of players that should be pre-selected.
  final List<Player>? initialSelectedPlayers;

  /// A callback function that is invoked whenever the selection changes,
  final Function(List<Player> value) onChanged;

  /// A callback function that is invoked when a player was created in this widget
  final VoidCallback? onPlayerCreated;

  @override
  State<PlayerSelection> createState() => _PlayerSelectionState();
}

class _PlayerSelectionState extends State<PlayerSelection> {
  late final AppDatabase db;
  bool isLoading = true;

  /// Future that loads all players from the database.
  late Future<List<Player>> _allPlayersFuture;

  /// The complete list of all available players.
  List<Player> allPlayers = [];

  /// The list of players suggested based on the search input.
  List<Player> suggestedPlayers = [];

  /// The list of currently selected players.
  List<Player> selectedPlayers = [];

  /// Controller for the search bar input.
  late final TextEditingController _searchBarController =
      TextEditingController();

  /// Skeleton data used while loading players.
  late final List<Player> skeletonData = List.filled(
    7,
    Player(name: 'Player 0'),
  );

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    suggestedPlayers = skeletonData;
    selectedPlayers = widget.initialSelectedPlayers ?? [];
    loadPlayerList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: CustomTheme.standardMargin,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  // If the search is empty, it shows all unselected players.
                  suggestedPlayers = allPlayers.where((player) {
                    return !selectedPlayers.any((p) => p.id == player.id);
                  }).toList();
                } else {
                  // If there is input, it filters by name match (case-insensitive) and ensures
                  // that already selected players are excluded from the results.
                  suggestedPlayers = allPlayers.where((player) {
                    final bool nameMatches = player.name.toLowerCase().contains(
                      value.toLowerCase(),
                    );
                    final bool isNotSelected = !selectedPlayers.any(
                      (p) => p.id == player.id,
                    );
                    return nameMatches && isNotSelected;
                  }).toList();
                }
              });
            },
          ),
          const SizedBox(height: 10),
          Text(
            loc.selected_players,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: AppSkeleton(
              enabled: isLoading,
              child: selectedPlayers.isEmpty
                  ? Center(child: Text(loc.no_players_selected))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var player in selectedPlayers)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextIconTile(
                                text: player.name,
                                suffixText: getNameCountText(player),
                                onIconTap: () {
                                  setState(() async {
                                    await HapticFeedback.selectionClick();
                                    // Removes the player from the selection and notifies the parent.
                                    selectedPlayers.remove(player);
                                    widget.onChanged([...selectedPlayers]);

                                    // Get the current search query
                                    final currentSearch = _searchBarController
                                        .text
                                        .toLowerCase();

                                    // If the player matches the current search query (or search is empty),
                                    // they are added back to the `suggestedPlayers` and the list is re-sorted.
                                    if (currentSearch.isEmpty ||
                                        player.name.toLowerCase().contains(
                                          currentSearch,
                                        )) {
                                      suggestedPlayers.add(player);
                                      suggestedPlayers.sort(
                                        (a, b) => a.name.compareTo(b.name),
                                      );
                                    }
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            loc.all_players,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                child: ListView.builder(
                  itemCount: suggestedPlayers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TextIconListTile(
                      text: suggestedPlayers[index].name,
                      suffixText: getNameCountText(suggestedPlayers[index]),
                      icon: Icons.add,
                      onPressed: () async {
                        await HapticFeedback.selectionClick();
                        setState(() {
                          // If the player is not already selected
                          if (!selectedPlayers.contains(
                            suggestedPlayers[index],
                          )) {
                            // Add to player to the front of the selectedPlayers
                            selectedPlayers.insert(0, suggestedPlayers[index]);
                            // Notify the parent widget of the change
                            widget.onChanged([...selectedPlayers]);
                            // Remove the player from the suggestedPlayers
                            suggestedPlayers.remove(suggestedPlayers[index]);
                          }
                        });
                      },
                    );
                  },
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
    _allPlayersFuture = Future.wait([
      db.playerDao.getAllPlayers(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]).then((results) => results[0] as List<Player>);

    _allPlayersFuture.then((loadedPlayers) {
      if (!mounted) return;
      setState(() {
        // If a list of available players is provided (even if empty), use that list.
        if (widget.availablePlayers != null) {
          widget.availablePlayers!.sort((a, b) => a.name.compareTo(b.name));
          allPlayers = [...widget.availablePlayers!];
          suggestedPlayers = [...allPlayers];

          if (widget.initialSelectedPlayers != null) {
            // Ensures that only players available for selection are pre-selected.
            selectedPlayers = widget.initialSelectedPlayers!
                .where(
                  (p) => widget.availablePlayers!.any(
                    (available) => available.id == p.id,
                  ),
                )
                .toList();
          }
        } else {
          // Otherwise, use the loaded players from the database.
          loadedPlayers.sort((a, b) => a.name.compareTo(b.name));
          allPlayers = [...loadedPlayers];
          if (widget.initialSelectedPlayers != null) {
            // Excludes already selected players from the suggested players list.
            suggestedPlayers = loadedPlayers
                .where(
                  (p) => !widget.initialSelectedPlayers!.any(
                    (ip) => ip.id == p.id,
                  ),
                )
                .toList();
            // Ensures that only players available for selection are pre-selected.
            selectedPlayers = widget.initialSelectedPlayers!
                .where(
                  (p) => allPlayers.any((available) => available.id == p.id),
                )
                .toList();
          } else {
            // If no initial selection, all loaded players are suggested.
            suggestedPlayers = [...loadedPlayers];
          }
        }
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
    selectedPlayers.insert(0, player);
    widget.onChanged([...selectedPlayers]);
    allPlayers.add(player);

    setState(() {
      _searchBarController.clear();
      _updateSuggestedPlayers();
    });
  }

  /// Updates the suggested players list based on current selection.
  void _updateSuggestedPlayers() {
    suggestedPlayers = allPlayers
        .where((player) => !selectedPlayers.contains(player))
        .toList();
  }

  /// Displays a snackbar message at the bottom of the screen.
  /// [message] - The message to display in the snackbar.
  void showSnackBarMessage(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CustomTheme.boxColor,
        content: Center(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  /// Determines the appropriate info text to display when no players
  /// are available in the suggested players list.
  String _getInfoText(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (allPlayers.isEmpty) {
      // No players exist in the database
      return loc.no_players_created_yet;
    } else if (selectedPlayers.length == allPlayers.length ||
        widget.availablePlayers?.isEmpty == true) {
      // All players have been selected or
      // available players list is provided but empty
      return loc.all_players_selected;
    } else {
      // No players match the search query
      return loc.no_players_found_with_that_name;
    }
  }
}
