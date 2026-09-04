import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_groups_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
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
  final Map<String, Player?> associations = {};
  List<Player>? cachedAllPlayers;

  @override
  void initState() {
    super.initState();
    for (var player in playersToAssociate) {
      associations[player.id] = null;
    }
    autoAssociatePlayers();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final players = playersToAssociate;
    final allPlayers = cachedAllPlayers ?? [];

    final unassignedCount = players
        .where((player) => associations[player.id] == null)
        .length;

    final newPlayersCount = players.where((player) {
      final assoc = associations[player.id];
      if (assoc == null) return false;
      return !allPlayers.any((lp) => lp.id == assoc.id);
    }).length;

    return Scaffold(
      appBar: AppBar(title: Text(loc.associate_players), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: CustomTheme.standardMargin,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: unassignedCount == 0
                      ? (newPlayersCount > 0 ? Colors.orange : Colors.green)
                      : unassignedCount == players.length
                      ? Colors.red
                      : Colors.redAccent,
                  borderRadius: CustomTheme.standardBorderRadiusAll,
                ),
                child: Text(
                  unassignedCount != 0
                      ? '$unassignedCount ${loc.remaining}'
                      : newPlayersCount > 0
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
                  final associatedPlayer = associations[player.id];
                  final isNew =
                      associatedPlayer != null &&
                      !allPlayers.any((lp) => lp.id == associatedPlayer.id);

                  return AssociatePlayerTile(
                    player: player,
                    associatedPlayer: associatedPlayer,
                    isNew: isNew,
                    borderColor: associatedPlayer != null
                        ? (isNew ? Colors.orange : Colors.green).withAlpha(150)
                        : Colors.red.withAlpha(150),
                    onTap: () async {
                      final selectedPlayer = await showPlayerSelectionSheet(
                        associatedPlayer,
                      );
                      setState(() {
                        associations[player.id] = selectedPlayer ?? player;
                      });
                    },
                  );
                },
              ),
            ),
            BottomAnimatedButton(
              buttonText: widget.match.group == null
                  ? loc.save_match
                  : loc.confirm,
              sizeRelativeToWidth: 0.95,
              onPressed: unassignedCount == 0
                  ? () async {
                      if (widget.match.group == null) {
                        await saveMatch();
                      } else {
                        await Navigator.of(context).push(
                          adaptivePageRoute(
                            builder: (context) => AssociateGroupsView(
                              match: widget.match,
                              associations: associations,
                              associatedGame: widget.associatedGame,
                            ),
                          ),
                        );
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveMatch() async {
    final db = Provider.of<AppDatabase>(context, listen: false);

    // Filter null values and cast to Map<String, Player>
    final playerAssociations = <String, Player>{};
    for (var entry in associations.entries) {
      if (entry.value != null) {
        playerAssociations[entry.key] = entry.value!;
      }
    }

    try {
      await RemoteShareService().saveImportedMatch(
        db: db,
        importedMatch: widget.match,
        playerAssociations: playerAssociations,
        associatedGame: widget.associatedGame,
        associatedGroup: null,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(CustomSnackBar(message: e.toString()));
      return;
    }

    if (!mounted) return;

    Provider.of<DataRefreshProvider>(context, listen: false).refresh();

    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(CustomSnackBar(message: loc.data_successfully_imported));

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<Player?> showPlayerSelectionSheet(Player? currentSelection) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    cachedAllPlayers ??= await db.playerDao.getAllPlayers();
    final allPlayers = cachedAllPlayers!;

    final isCreateAsNew =
        currentSelection != null &&
        !allPlayers.any((p) => p.id == currentSelection.id);

    final associatedPlayerIds = associations.values
        .where(
          (p) =>
              p != null &&
              p.id != currentSelection?.id &&
              allPlayers.any((lp) => lp.id == p.id),
        )
        .map((p) => p!.id)
        .toSet();

    final availablePlayers = allPlayers
        .where((p) => !associatedPlayerIds.contains(p.id))
        .toList();

    if (!mounted) return null;

    return showModalBottomSheet<Player?>(
      context: context,
      backgroundColor: CustomTheme.backgroundColor,
      builder: (context) {
        return PlayerSelectionWidget.single(
          onSingleChanged: (player) async {
            await Future.delayed(const Duration(milliseconds: 200));
            if (!context.mounted) return;
            Navigator.of(context).pop(player);
          },
          onPlayerCreated: () {
            setState(() {
              cachedAllPlayers = null;
            });
            autoAssociatePlayers();
          },
          availablePlayers: availablePlayers,
          initialSelectedPlayer: isCreateAsNew ? null : currentSelection,
        );
      },
    );
  }

  Future<void> autoAssociatePlayers() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    cachedAllPlayers = await db.playerDao.getAllPlayers();
    final allPlayers = cachedAllPlayers!;

    if (!mounted) return;

    setState(() {
      final usedLocalPlayerIds = <String>{};

      for (var importedPlayer in playersToAssociate) {
        // 1. Try exact ID match first
        Player? match = allPlayers.where((localPlayer) {
          return !usedLocalPlayerIds.contains(localPlayer.id) &&
              localPlayer.id == importedPlayer.id;
        }).firstOrNull;

        // 2. Try Name + NameCount match
        match ??= allPlayers.where((localPlayer) {
          return !usedLocalPlayerIds.contains(localPlayer.id) &&
              localPlayer.name.trim().compareIgnoringCaseTo(
                    importedPlayer.name.trim(),
                  ) ==
                  0 &&
              localPlayer.nameCount == importedPlayer.nameCount;
        }).firstOrNull;

        // 3. Fall back to Name-only match (ignoring case and whitespace)
        match ??= allPlayers.where((localPlayer) {
          return !usedLocalPlayerIds.contains(localPlayer.id) &&
              localPlayer.name.trim().compareIgnoringCaseTo(
                    importedPlayer.name.trim(),
                  ) ==
                  0;
        }).firstOrNull;

        if (match != null) {
          associations[importedPlayer.id] = match;
          usedLocalPlayerIds.add(match.id);
        } else {
          // Default to Create as New if no match found
          associations[importedPlayer.id] = importedPlayer;
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
