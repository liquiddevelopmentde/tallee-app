import 'dart:core' hide Match;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/app_spacing.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_group_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/player_selection_widget.dart';
import 'package:tallee/presentation/widgets/tiles/associate_player_tile.dart';
import 'package:tallee/services/remote_share_service.dart';
import 'package:tallee/state/data_refresh_provider.dart';

class AssociatePlayersView extends StatefulWidget {
  const AssociatePlayersView({
    super.key,
    required this.match,
    this.associatedGame,
  });

  final Match match;

  final Game? associatedGame;

  @override
  State<AssociatePlayersView> createState() => _AssociatePlayersViewState();
}

class _AssociatePlayersViewState extends State<AssociatePlayersView> {
  /// Imported player ID -> the player stored locally for it.
  final Map<String, Player> associations = {};

  /// Imported players that are created as new instead of reused. Tracked
  /// separately because imported and local IDs can collide (same-device import).
  final Set<String> createAsNewIds = {};

  List<Player>? cachedAllPlayers;

  @override
  void initState() {
    super.initState();
    for (final player in playersToAssociate) {
      associations[player.id] = createNewPlayer(player);
      createAsNewIds.add(player.id);
    }
    autoAssociatePlayers();
  }

  /// Copy of [importedPlayer] with a new ID, so the import inserts it instead
  /// of skipping it as an already existing player.
  Player createNewPlayer(Player importedPlayer) => Player(
    name: importedPlayer.name,
    description: importedPlayer.description,
  );

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final players = playersToAssociate;
    final newPlayersCount = createAsNewIds.length;

    return Scaffold(
      appBar: AppBar(title: Text(loc.associate_players), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              child: Container(
                margin: AppSpacing.standardMargin,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: newPlayersCount > 0 ? Colors.orange : Colors.green,
                  borderRadius: AppColors.standardBorderRadiusAll,
                ),
                child: Text(
                  newPlayersCount > 0
                      ? loc.new_players_will_be_created(newPlayersCount)
                      : loc.all_players_associated,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    overflow: TextOverflow.visible,
                  ),
                  softWrap: true,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  final associatedPlayer = associations[player.id] ?? player;
                  final isNew =
                      createAsNewIds.contains(player.id) ||
                      !associations.containsKey(player.id);

                  return AssociatePlayerTile(
                    player: player,
                    associatedPlayer: associatedPlayer,
                    isNew: isNew,
                    borderColor: (isNew ? Colors.orange : Colors.green)
                        .withAlpha(150),
                    onTap: () async {
                      final result = await showPlayerSelectionSheet(
                        associatedPlayer,
                        isCreateAsNew: isNew,
                      );
                      // Dismissed: keep the current association.
                      if (!mounted || result == null) return;
                      setState(() {
                        // Deselected: create as new.
                        associations[player.id] =
                            result.player ?? createNewPlayer(player);
                        if (result.player == null) {
                          createAsNewIds.add(player.id);
                        } else {
                          createAsNewIds.remove(player.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: BottomAnimatedButton(
                text: widget.match.group == null ? loc.save_match : loc.confirm,
                onPressed: () async {
                  if (widget.match.group == null) {
                    await saveMatch();
                  } else {
                    await Navigator.of(context).push(
                      adaptivePageRoute(
                        settings: const RouteSettings(
                          name: RouteNames.associateGroupView,
                        ),
                        builder: (context) => AssociateGroupView(
                          match: widget.match,
                          associations: associations,
                          associatedGame: widget.associatedGame,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveMatch() async {
    final db = context.read<AppDatabase>();

    try {
      await RemoteShareService().saveImportedMatch(
        db: db,
        importedMatch: widget.match,
        playerAssociations: associations,
        associatedGame: widget.associatedGame,
        associatedGroup: null,
      );
    } catch (e) {
      if (!mounted) return;
      context.showSnackBar(message: e.toString());
      return;
    }

    if (!mounted) return;
    context.read<DataRefreshProvider>().refresh();

    final loc = AppLocalizations.of(context);
    context.showSnackBar(message: loc.data_successfully_imported);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Returns `(player: null)` if the selection was cleared (create as new) and
  /// `null` if the sheet was dismissed without a change.
  Future<({Player? player})?> showPlayerSelectionSheet(
    Player currentSelection, {
    required bool isCreateAsNew,
  }) async {
    final db = context.read<AppDatabase>();
    cachedAllPlayers ??= await db.playerDao.getAllPlayers();
    final allPlayers = cachedAllPlayers!;

    final associatedPlayerIds = {
      for (final entry in associations.entries)
        if (!createAsNewIds.contains(entry.key) &&
            entry.value.id != currentSelection.id)
          entry.value.id,
    };

    final availablePlayers = allPlayers
        .where((p) => !associatedPlayerIds.contains(p.id))
        .toList();

    if (!mounted) return null;

    return showModalBottomSheet<({Player? player})>(
      context: context,
      backgroundColor: context.talleeColors.backgroundColor,
      builder: (context) => PlayerSelectionWidget.single(
        onSingleChanged: (player) async {
          await Future.delayed(const Duration(milliseconds: 200));
          if (!context.mounted) return;
          Navigator.of(context).pop((player: player));
        },
        onPlayerCreated: () {
          // New player is in the DB now, don't re-run auto-associations
          setState(() {
            cachedAllPlayers = null;
          });
        },
        availablePlayers: availablePlayers,
        initialSelectedPlayer: isCreateAsNew ? null : currentSelection,
      ),
    );
  }

  Future<void> autoAssociatePlayers() async {
    final db = context.read<AppDatabase>();
    cachedAllPlayers = await db.playerDao.getAllPlayers();
    final allPlayers = cachedAllPlayers!;

    if (!mounted) return;

    setState(() {
      final usedLocalPlayerIds = <String>{};
      createAsNewIds.clear();

      for (final importedPlayer in playersToAssociate) {
        // 1. Try exact ID match first
        Player? match = allPlayers
            .where(
              (localPlayer) =>
                  !usedLocalPlayerIds.contains(localPlayer.id) &&
                  localPlayer.id == importedPlayer.id,
            )
            .firstOrNull;

        // 2. Try Name + NameCount match
        match ??= allPlayers
            .where(
              (localPlayer) =>
                  !usedLocalPlayerIds.contains(localPlayer.id) &&
                  localPlayer.name.trim().compareIgnoringCaseTo(
                        importedPlayer.name.trim(),
                      ) ==
                      0 &&
                  localPlayer.nameCount == importedPlayer.nameCount,
            )
            .firstOrNull;

        // 3. Fall back to Name-only match (ignoring case and whitespace)
        match ??= allPlayers
            .where(
              (localPlayer) =>
                  !usedLocalPlayerIds.contains(localPlayer.id) &&
                  localPlayer.name.trim().compareIgnoringCaseTo(
                        importedPlayer.name.trim(),
                      ) ==
                      0,
            )
            .firstOrNull;

        if (match != null) {
          associations[importedPlayer.id] = match;
          usedLocalPlayerIds.add(match.id);
        } else {
          // No match: default to create as new.
          associations[importedPlayer.id] = createNewPlayer(importedPlayer);
          createAsNewIds.add(importedPlayer.id);
        }
      }
    });
  }

  List<Player> get playersToAssociate {
    final Map<String, Player> allUniquePlayers = {};

    // Add all players who played the match
    for (final player in widget.match.players) {
      allUniquePlayers[player.id] = player;
    }

    // Add all members of the associated group
    if (widget.match.group != null) {
      for (final player in widget.match.group!.members) {
        allUniquePlayers[player.id] = player;
      }
    }

    // Add all members of teams
    if (widget.match.teams != null) {
      for (final team in widget.match.teams!) {
        for (final player in team.members) {
          allUniquePlayers[player.id] = player;
        }
      }
    }

    return allUniquePlayers.values.toList();
  }
}
