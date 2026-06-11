import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/text_icon_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class PlayerSelection extends StatefulWidget {
  /// A widget that allows users to select players from a list,
  /// with search functionality and the ability to add new players.
  /// - [availablePlayers]: An optional list of players to choose from. If null,
  ///   all players from the database are used.
  /// - [initialSelectedPlayers]: An optional list of players that should be pre-selected.
  /// - [initialSelectedUnits]: An optional list of units (teams) that should be pre-selected.
  /// - [onChanged]: A callback function that is invoked whenever the selection
  ///   changes, providing the updated list of selected players and units.
  const PlayerSelection({
    super.key,
    this.availablePlayers,
    this.initialSelectedPlayers,
    this.initialSelectedUnits,
    this.pairingEnabled = true,
    required this.onChanged,
    this.onPlayerCreated,
  });

  /// An optional list of players to choose from. If null, all players from the database are used.
  final List<Player>? availablePlayers;

  /// An optional list of players that should be pre-selected.
  final List<Player>? initialSelectedPlayers;

  /// An optional list of units that should be pre-selected.
  final List<Team>? initialSelectedUnits;

  /// Whether pairing mode is enabled for this widget
  final bool pairingEnabled;

  /// A callback function that is invoked whenever the selection changes,
  final Function(List<Player> players, List<Team> units) onChanged;

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

  /// The list of currently selected units (each unit can be a single player or a pair).
  List<Team> selectedUnits = [];

  /// Helper to get all players from selected units
  List<Player> get selectedPlayers =>
      selectedUnits.expand((u) => u.members).toList();

  /// Whether we are currently in pairing mode
  bool isPairingMode = false;

  /// Set of unit IDs currently selected for pairing
  final Set<String> pairingSelection = {};

  /// Track which unit is currently being pressed (for visual feedback)
  String? pressingId;

  /// Controller for the search bar input.
  late final TextEditingController _searchBarController =
      TextEditingController();

  /// Skeleton data used while loading players.
  late final List<Player> skeletonData = List.filled(
    7,
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

    if (widget.initialSelectedUnits != null) {
      selectedUnits = [...widget.initialSelectedUnits!];
    } else if (widget.initialSelectedPlayers != null) {
      selectedUnits = widget.initialSelectedPlayers!
          .map((p) => Team(name: '', members: [p]))
          .toList();
    }

    loadPlayerList();
  }

  @override
  void didUpdateWidget(PlayerSelection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the units were reset or changed from the parent view,
    // update the internal state accordingly.
    if (widget.initialSelectedUnits != oldWidget.initialSelectedUnits &&
        widget.initialSelectedUnits != null) {
      setState(() {
        selectedUnits = [...widget.initialSelectedUnits!];
        _updateSuggestedPlayers();
      });
    }

    // If pairing was disabled, ensure we are not in pairing mode
    if (oldWidget.pairingEnabled && !widget.pairingEnabled) {
      setState(() {
        isPairingMode = false;
        pairingSelection.clear();
      });
    }
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
                  // If there is input, it filters by fuzzy match and ensures
                  // that already selected players are excluded from the results.
                  final List<({Player player, int score})> scoredPlayers = [];

                  for (final player in allPlayers) {
                    final bool isNotSelected = !selectedPlayers.any(
                      (p) => p.id == player.id,
                    );

                    if (isNotSelected) {
                      final score = weightedRatio(player.name, value);
                      if (score >= Constants.FUZZY_SEARCH_THRESHOLD) {
                        scoredPlayers.add((player: player, score: score));
                      }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isPairingMode
                      ? loc.click_another_player_to_create_a_pair
                      : loc.selected_players,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPairingMode ? CustomTheme.primaryColor : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: AppSkeleton(
              enabled: isLoading,
              child: selectedUnits.isEmpty
                  ? Center(child: Text(loc.no_players_selected))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var unit in selectedUnits)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: buildUnitTile(unit),
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
                    final player = suggestedPlayers[index];
                    return TextIconListTile(
                      player: player,
                      icon: Icons.add,
                      onPressed: () async {
                        await HapticFeedback.selectionClick();
                        setState(() {
                          // If the player is not already selected
                          if (!selectedPlayers.contains(player)) {
                            // Add player as a new unit
                            selectedUnits.insert(
                              0,
                              Team(name: '', members: [player]),
                            );
                            // Remove the player from the suggestedPlayers
                            suggestedPlayers.remove(player);
                            // Notify parent
                            widget.onChanged(selectedPlayers, selectedUnits);
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

  Widget buildUnitTile(Team unit) {
    final isPaired = unit.members.length > 1;
    final isSelectedForPairing = pairingSelection.contains(unit.id);

    return Opacity(
      opacity: 1.0,
      child: GestureDetector(
        onLongPressDown: !isPaired && widget.pairingEnabled
            ? (_) => setState(() => pressingId = unit.id)
            : null,
        onLongPressCancel: () => setState(() => pressingId = null),
        onLongPressEnd: (_) => setState(() => pressingId = null),
        onLongPress: !isPaired && widget.pairingEnabled
            ? () async {
                await HapticFeedback.selectionClick();
                setState(() {
                  pressingId = null;
                  if (isSelectedForPairing) {
                    pairingSelection.remove(unit.id);
                  } else {
                    pairingSelection.add(unit.id);
                  }
                  isPairingMode = pairingSelection.isNotEmpty;
                  widget.onChanged(selectedPlayers, selectedUnits);
                });
              }
            : null,
        child: Container(
          decoration: isSelectedForPairing
              ? BoxDecoration(
                  border: Border.all(color: CustomTheme.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: TextIconTile(
            player: unit.members.first,
            pair: isPaired ? unit : null,
            icon: isPairingMode ? null : Icons.close,
            backgroundColor: pressingId == unit.id
                ? Colors.grey.shade800
                : null,
            pairIconLeft: true,
            onTileTap:
                !isPaired &&
                    widget.pairingEnabled &&
                    pairingSelection.isNotEmpty &&
                    !isSelectedForPairing
                ? () async {
                    await HapticFeedback.selectionClick();
                    setState(() {
                      pairingSelection.add(unit.id);
                      // Enter pairing mode as soon as we add a selection
                      isPairingMode = pairingSelection.isNotEmpty;
                      // Auto-merge if we have exactly 2 units selected
                      if (pairingSelection.length == 2) {
                        _autoMergePairingSelection();
                        // _autoMergePairingSelection clears pairingSelection; ensure mode is off
                        isPairingMode = pairingSelection.isNotEmpty;
                      }
                      widget.onChanged(selectedPlayers, selectedUnits);
                    });
                  }
                : null,
            onIconTap: () async {
              await HapticFeedback.selectionClick();

              if (isPaired) {
                // Unlink pair
                unmergeUnit(unit);
              } else {
                // Remove single player unit
                setState(() {
                  selectedUnits.remove(unit);
                  pairingSelection.remove(unit.id);
                  isPairingMode = pairingSelection.isNotEmpty;
                  widget.onChanged(selectedPlayers, selectedUnits);

                  final player = unit.members.first;
                  final currentSearch = _searchBarController.text.toLowerCase();
                  if (currentSearch.isEmpty ||
                      player.name.toLowerCase().contains(currentSearch)) {
                    suggestedPlayers.add(player);
                    suggestedPlayers.sort((a, b) => a.name.compareTo(b.name));
                  }
                });
              }
            },
          ),
        ),
      ),
    );
  }

  void mergeSelectedUnits() {
    setState(() {
      final unitsToMerge = selectedUnits
          .where((u) => pairingSelection.contains(u.id))
          .toList();
      final allMembers = unitsToMerge.expand((u) => u.members).toList();

      // Remove old units
      selectedUnits.removeWhere((u) => pairingSelection.contains(u.id));

      // Add new merged unit
      selectedUnits.insert(0, Team(name: '', members: allMembers));

      pairingSelection.clear();
      isPairingMode = false;
      widget.onChanged(selectedPlayers, selectedUnits);
    });
  }

  /// Automatically merges 2 units when they are selected via long tap.
  /// This creates a pair of exactly 2 players.
  void _autoMergePairingSelection() {
    if (pairingSelection.length != 2) return;

    final unitsToMerge = selectedUnits
        .where((u) => pairingSelection.contains(u.id))
        .toList();

    if (unitsToMerge.length != 2) return;

    final allMembers = unitsToMerge.expand((u) => u.members).toList();

    // Remove old units
    selectedUnits.removeWhere((u) => pairingSelection.contains(u.id));

    // Add new merged unit (max 2 players)
    selectedUnits.insert(
      0,
      Team(name: '', members: allMembers.take(2).toList()),
    );

    pairingSelection.clear();
    // Ensure pairing mode is disabled after an automatic merge
    isPairingMode = pairingSelection.isNotEmpty;
    // Notify parent about the change in units
    widget.onChanged(selectedPlayers, selectedUnits);
  }

  void unmergeUnit(Team unit) {
    setState(() {
      final index = selectedUnits.indexOf(unit);
      if (index == -1) return;

      selectedUnits.removeAt(index);
      final newUnits = unit.members.map((p) => Team(name: '', members: [p]));
      selectedUnits.insertAll(index, newUnits);
      // Ensure any pairing selection referencing the old unit is removed
      pairingSelection.remove(unit.id);
      isPairingMode = pairingSelection.isNotEmpty;

      widget.onChanged(selectedPlayers, selectedUnits);
    });
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

          if (widget.initialSelectedUnits != null ||
              widget.initialSelectedPlayers != null) {
            // Ensures that only players available for selection are pre-selected.
            final validInitialPlayers =
                (widget.initialSelectedUnits?.expand((u) => u.members) ??
                        widget.initialSelectedPlayers!)
                    .where(
                      (p) => widget.availablePlayers!.any(
                        (available) => available.id == p.id,
                      ),
                    )
                    .toList();

            if (widget.initialSelectedUnits != null) {
              selectedUnits = widget.initialSelectedUnits!
                  .where(
                    (u) => u.members.every(
                      (m) => widget.availablePlayers!.any(
                        (available) => available.id == m.id,
                      ),
                    ),
                  )
                  .toList();
            } else {
              selectedUnits = validInitialPlayers
                  .map((p) => Team(name: '', members: [p]))
                  .toList();
            }

            suggestedPlayers = suggestedPlayers
                .where((p) => !selectedPlayers.any((sp) => sp.id == p.id))
                .toList();
          }
        } else {
          // Otherwise, use the loaded players from the database.
          loadedPlayers.sort((a, b) => a.name.compareTo(b.name));
          allPlayers = [...loadedPlayers];
          if (widget.initialSelectedUnits != null ||
              widget.initialSelectedPlayers != null) {
            final initialPlayers =
                widget.initialSelectedUnits
                    ?.expand((u) => u.members)
                    .toList() ??
                widget.initialSelectedPlayers!;

            // Excludes already selected players from the suggested players list.
            suggestedPlayers = loadedPlayers
                .where((p) => !initialPlayers.any((ip) => ip.id == p.id))
                .toList();

            if (widget.initialSelectedUnits != null) {
              selectedUnits = widget.initialSelectedUnits!;
            } else {
              selectedUnits = initialPlayers
                  .map((p) => Team(name: '', members: [p]))
                  .toList();
            }
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
    selectedUnits.insert(0, Team(name: '', members: [player]));
    widget.onChanged(selectedPlayers, selectedUnits);
    allPlayers.add(player);

    setState(() {
      _searchBarController.clear();
      _updateSuggestedPlayers();
    });
  }

  /// Updates the suggested players list based on current selection.
  void _updateSuggestedPlayers() {
    suggestedPlayers = allPlayers
        .where((player) => !selectedPlayers.any((p) => p.id == player.id))
        .toList();
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
