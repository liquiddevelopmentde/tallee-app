import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/custom_radio_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_list_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/pair_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

enum SelectionMode { single, multiple }

class PlayerSelectionWidget extends StatefulWidget {
  const PlayerSelectionWidget.single({
    super.key,
    this.availablePlayers,
    this.initialSelectedPlayer,
    required this.onSingleChanged,
    this.onPlayerCreated,
  }) : mode = SelectionMode.single,
       initialSelectedPlayers = null,
       initialSelectedUnits = null,
       pairingEnabled = false,
       onMultipleChanged = null;

  const PlayerSelectionWidget.multiple({
    super.key,
    this.availablePlayers,
    this.initialSelectedPlayers,
    this.initialSelectedUnits,
    this.pairingEnabled = true,
    required this.onMultipleChanged,
    this.onPlayerCreated,
  }) : mode = SelectionMode.multiple,
       onSingleChanged = null,
       initialSelectedPlayer = null;

  final SelectionMode mode;

  /// An optional list of players to choose from. If null, all players from the database are used.
  final List<Player>? availablePlayers;

  /// [Single] An optional player that should be pre-selected.
  final Player? initialSelectedPlayer;

  /// [Single] A callback function that is invoked whenever the selection changes.
  final Function(Player player)? onSingleChanged;

  /// [Multiple] An optional list of players that should be pre-selected.
  final List<Player>? initialSelectedPlayers;

  /// [Multiple] An optional list of units that should be pre-selected.
  final List<Team>? initialSelectedUnits;

  /// [Multiple] Whether pairing mode is enabled for this widget
  final bool pairingEnabled;

  /// [Multiple] A callback function that is invoked whenever the selection changes.
  final Function(List<Player> players, List<Team> units)? onMultipleChanged;

  /// A callback function that is invoked when a player was created in this widget
  final VoidCallback? onPlayerCreated;

  @override
  State<PlayerSelectionWidget> createState() => _PlayerSelectionWidgetState();
}

class _PlayerSelectionWidgetState extends State<PlayerSelectionWidget> {
  late final AppDatabase db;
  bool isLoading = true;

  /// Future that loads all players from the database.
  late Future<List<Player>> allPlayersFuture;

  /// The complete list of all available players.
  List<Player> allPlayers = [];

  /// The list of players suggested based on the search input.
  List<Player> suggestedPlayers = [];

  // --- Single Selection State ---
  Player? selectedPlayer;

  // --- Multiple Selection State ---
  List<Team> selectedUnits = [];
  List<Player> get selectedPlayers =>
      selectedUnits.expand((u) => u.members).toList();
  bool isPairingMode = false;
  final Set<String> pairingSelection = {};
  String? pressingId;

  /// Controller for the search bar input.
  late final TextEditingController searchBarController =
      TextEditingController();

  /// Skeleton data used while loading players.
  late final List<Player> skeletonData = List.filled(
    widget.mode == SelectionMode.single ? 5 : 7,
    Player(name: 'Player 0'),
  );

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    suggestedPlayers = skeletonData;

    if (widget.mode == SelectionMode.single) {
      selectedPlayer = widget.initialSelectedPlayer;
    } else {
      if (widget.initialSelectedUnits != null) {
        selectedUnits = [...widget.initialSelectedUnits!];
      } else if (widget.initialSelectedPlayers != null) {
        selectedUnits = widget.initialSelectedPlayers!
            .map((p) => Team(name: '', members: [p]))
            .toList();
      }
    }

    if (widget.availablePlayers != null) {
      initializeWithAvailablePlayers();
    } else {
      suggestedPlayers = skeletonData;
      loadPlayerList();
    }
  }

  void initializeWithAvailablePlayers() {
    allPlayers = [...widget.availablePlayers!];
    allPlayers.sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

    if (widget.mode == SelectionMode.single) {
      suggestedPlayers = [...allPlayers];
    } else {
      initializeMultipleSelection(allPlayers);
    }
    isLoading = false;
  }

  @override
  void didUpdateWidget(PlayerSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.mode == SelectionMode.multiple) {
      // If the units were reset or changed from the parent view,
      // update the internal state accordingly.
      if (widget.initialSelectedUnits != oldWidget.initialSelectedUnits &&
          widget.initialSelectedUnits != null) {
        setState(() {
          selectedUnits = [...widget.initialSelectedUnits!];
          updateSuggestedPlayers();
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
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: widget.mode == SelectionMode.multiple
          ? CustomTheme.tileMargin
          : null,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        crossAxisAlignment: widget.mode == SelectionMode.single
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          buildSearchBar(loc),
          const SizedBox(height: 10),
          if (widget.mode == SelectionMode.multiple) ...[
            buildSelectedPlayersHeader(loc),
            const SizedBox(height: 10),
            buildSelectedPlayersBar(),
            const SizedBox(height: 10),
            Text(
              loc.all_players,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: AppSkeleton(
              enabled: isLoading,
              child: Visibility(
                visible: suggestedPlayers.isNotEmpty,
                replacement: TopCenteredMessage(
                  icon: Icons.info,
                  title: loc.info,
                  message: getInfoText(context),
                  fullscreen: false,
                ),
                child: widget.mode == SelectionMode.single
                    ? buildSingleSelectionList()
                    : buildMultipleSelectionList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar(AppLocalizations loc) {
    return CustomSearchBar(
      maxLength: Constants.MAX_PLAYER_NAME_LENGTH,
      controller: searchBarController,
      constraints: const BoxConstraints(maxHeight: 45, minHeight: 45),
      hintText: loc.search_for_players,
      trailingButtonShown: true,
      trailingButtonicon: Icons.add_circle,
      trailingButtonEnabled: searchBarController.text.trim().isNotEmpty,
      onTrailingButtonPressed: () async {
        addNewPlayerFromSearch(context: context);
      },
      onChanged: (value) {
        setState(() {
          if (value.isEmpty) {
            updateSuggestedPlayers();
          } else {
            final List<({Player player, int score})> scoredPlayers = [];

            for (final player in allPlayers) {
              final bool isNotSelected =
                  widget.mode == SelectionMode.single ||
                  !selectedPlayers.any((p) => p.id == player.id);

              if (isNotSelected) {
                final score = weightedRatio(player.name, value);
                if (score >= Constants.FUZZY_SEARCH_THRESHOLD) {
                  scoredPlayers.add((player: player, score: score));
                }
              }
            }

            scoredPlayers.sort((a, b) => b.score.compareTo(a.score));
            suggestedPlayers = scoredPlayers.map((e) => e.player).toList();
          }
        });
      },
    );
  }

  Widget buildSelectedPlayersHeader(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            isPairingMode
                ? loc.click_another_player_to_create_a_pair
                : loc.selected_players,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPairingMode ? CustomTheme.primaryColor : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSelectedPlayersBar() {
    final loc = AppLocalizations.of(context);
    return SizedBox(
      height: 50,
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
    );
  }

  Widget buildSingleSelectionList() {
    return RadioGroup<Player>(
      groupValue: selectedPlayer,
      onChanged: (value) {
        if (value != null) {
          widget.onSingleChanged?.call(value);
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
              widget.onSingleChanged?.call(value);
            },
          );
        },
      ),
    );
  }

  Widget buildMultipleSelectionList() {
    return ListView.separated(
      itemCount: suggestedPlayers.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final player = suggestedPlayers[index];
        return TextIconListTile(
          player: player,
          icon: Icons.add,
          onPressed: () async {
            await HapticFeedback.selectionClick();
            setState(() {
              if (!selectedPlayers.any((p) => p.id == player.id)) {
                selectedUnits.insert(0, Team(name: '', members: [player]));
                suggestedPlayers.remove(player);
                widget.onMultipleChanged?.call(selectedPlayers, selectedUnits);
              }
            });
          },
        );
      },
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
                  widget.onMultipleChanged?.call(
                    selectedPlayers,
                    selectedUnits,
                  );
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
          child: isPaired
              ? PairTile(
                  pair: unit,
                  pairIconLeft: true,
                  onIconTap: () => unmergeUnit(unit),
                )
              : PlayerTile(
                  player: unit.members.first,
                  icon: isPairingMode ? null : Icons.close,
                  backgroundColor: pressingId == unit.id
                      ? Colors.grey.shade800
                      : null,
                  onTileTap:
                      !isPaired &&
                          widget.pairingEnabled &&
                          pairingSelection.isNotEmpty &&
                          !isSelectedForPairing
                      ? () async {
                          await HapticFeedback.selectionClick();
                          setState(() {
                            pairingSelection.add(unit.id);
                            isPairingMode = pairingSelection.isNotEmpty;
                            if (pairingSelection.length == 2) {
                              autoMergePairingSelection();
                              isPairingMode = pairingSelection.isNotEmpty;
                            }
                            widget.onMultipleChanged?.call(
                              selectedPlayers,
                              selectedUnits,
                            );
                          });
                        }
                      : null,
                  onIconTap: () => setState(() {
                    selectedUnits.remove(unit);
                    pairingSelection.remove(unit.id);
                    isPairingMode = pairingSelection.isNotEmpty;
                    widget.onMultipleChanged?.call(
                      selectedPlayers,
                      selectedUnits,
                    );

                    final player = unit.members.first;
                    final currentSearch = searchBarController.text
                        .toLowerCase();
                    if (currentSearch.isEmpty ||
                        player.name.toLowerCase().contains(currentSearch)) {
                      suggestedPlayers.add(player);
                      suggestedPlayers.sort((a, b) => a.name.compareTo(b.name));
                    }
                  }),
                ),
        ),
      ),
    );
  }

  void autoMergePairingSelection() {
    if (pairingSelection.length != 2) return;

    final unitsToMerge = selectedUnits
        .where((u) => pairingSelection.contains(u.id))
        .toList();

    if (unitsToMerge.length != 2) return;

    final allMembers = unitsToMerge.expand((u) => u.members).toList();

    selectedUnits.removeWhere((u) => pairingSelection.contains(u.id));

    selectedUnits.insert(
      0,
      Team(
        name: allMembers.take(2).map((m) => m.name).join(' & '),
        members: allMembers.take(2).toList(),
      ),
    );

    pairingSelection.clear();
    isPairingMode = pairingSelection.isNotEmpty;
    widget.onMultipleChanged?.call(selectedPlayers, selectedUnits);
  }

  void unmergeUnit(Team unit) {
    setState(() {
      final index = selectedUnits.indexOf(unit);
      if (index == -1) return;

      selectedUnits.removeAt(index);
      final newUnits = unit.members.map((p) => Team(name: '', members: [p]));
      selectedUnits.insertAll(index, newUnits);
      pairingSelection.remove(unit.id);
      isPairingMode = pairingSelection.isNotEmpty;

      widget.onMultipleChanged?.call(selectedPlayers, selectedUnits);
    });
  }

  void loadPlayerList() {
    allPlayersFuture = Future.wait([
      db.playerDao.getAllPlayers(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]).then((results) => results[0] as List<Player>);

    allPlayersFuture.then((loadedPlayers) {
      if (!mounted) return;
      setState(() {
        if (widget.availablePlayers != null) {
          widget.availablePlayers!.sort((a, b) => a.name.compareTo(b.name));
          allPlayers = [...widget.availablePlayers!];
        } else {
          loadedPlayers.sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
          allPlayers = [...loadedPlayers];
        }

        if (widget.mode == SelectionMode.single) {
          suggestedPlayers = [...allPlayers];
        } else {
          initializeMultipleSelection(allPlayers);
        }
        isLoading = false;
      });
    });
  }

  void initializeMultipleSelection(List<Player> players) {
    if (widget.initialSelectedUnits != null ||
        widget.initialSelectedPlayers != null) {
      final initialPlayers =
          widget.initialSelectedUnits?.expand((u) => u.members).toList() ??
          widget.initialSelectedPlayers!;

      if (widget.availablePlayers != null) {
        final validInitialPlayers = initialPlayers
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
      } else {
        if (widget.initialSelectedUnits != null) {
          selectedUnits = widget.initialSelectedUnits!;
        } else {
          selectedUnits = initialPlayers
              .map((p) => Team(name: '', members: [p]))
              .toList();
        }
      }
    }
    updateSuggestedPlayers();
  }

  Future<void> addNewPlayerFromSearch({required BuildContext context}) async {
    final loc = AppLocalizations.of(context);
    final playerName = searchBarController.text.trim();

    int nameCount = calculateNameCount(playerName);
    final createdPlayer = Player(name: playerName, nameCount: nameCount);
    final success = await db.playerDao.addPlayer(player: createdPlayer);

    if (!context.mounted) return;

    if (success) {
      handleSuccessfulPlayerCreation(createdPlayer);
      await HapticFeedback.successNotification();
      showSnackBarMessage(loc.successfully_added_player(playerName));
    } else {
      await HapticFeedback.errorNotification();
      showSnackBarMessage(loc.could_not_add_player(playerName));
    }
  }

  int calculateNameCount(String playerName) {
    final playersWithSameName =
        allPlayers.where((player) => player.name == playerName).toList()
          ..sort((a, b) => a.nameCount.compareTo(b.nameCount));

    if (playersWithSameName.isEmpty) {
      return 0;
    } else if (playersWithSameName.length == 1) {
      playersWithSameName[0].nameCount = 1;
    }
    return playersWithSameName.length + 1;
  }

  void handleSuccessfulPlayerCreation(Player player) {
    widget.onPlayerCreated?.call();
    if (widget.mode == SelectionMode.single) {
      selectedPlayer = player;
      widget.onSingleChanged?.call(player);
    } else {
      selectedUnits.insert(0, Team(name: '', members: [player]));
      widget.onMultipleChanged?.call(selectedPlayers, selectedUnits);
    }
    allPlayers.add(player);

    setState(() {
      searchBarController.clear();
      updateSuggestedPlayers();
    });
  }

  void updateSuggestedPlayers() {
    if (widget.mode == SelectionMode.single) {
      suggestedPlayers = [...allPlayers];
    } else {
      suggestedPlayers = allPlayers
          .where((player) => !selectedPlayers.any((p) => p.id == player.id))
          .toList();
    }
  }

  void showSnackBarMessage(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(CustomSnackBar(message: message));
  }

  String getInfoText(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (allPlayers.isEmpty) {
      return loc.no_players_created_yet;
    } else if (widget.mode == SelectionMode.multiple &&
        (selectedPlayers.length == allPlayers.length ||
            widget.availablePlayers?.isEmpty == true)) {
      return loc.all_players_selected;
    } else if (widget.mode == SelectionMode.single &&
        widget.availablePlayers?.isEmpty == true) {
      return loc.all_players_selected;
    } else {
      return loc.no_players_found_with_that_name;
    }
  }
}
