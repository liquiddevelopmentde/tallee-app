import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_groups_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/single_player_selection_widget.dart';
import 'package:tallee/presentation/widgets/tiles/associate_player_tile.dart';
import 'package:tallee/services/match_share_service.dart';
import 'package:tallee/services/share_exceptions.dart';

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
    final remainingCount = players
        .where((player) => associations[player.id] == null)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(loc.associate_players), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: CustomTheme.standardMargin,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: CustomTheme.standardBorderRadiusAll,
                ),
                child: Text(
                  remainingCount != 0
                      ? '$remainingCount ${loc.remaining}'
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
                  return AssociatePlayerTile(
                    player: player,
                    associatedPlayer: associatedPlayer,
                    borderColor: associatedPlayer != null
                        ? Colors.green.withAlpha(150)
                        : Colors.red.withAlpha(150),
                    onTap: () async {
                      final selectedPlayer = await showPlayerSelectionSheet(
                        associatedPlayer,
                      );
                      if (selectedPlayer != null) {
                        setState(() {
                          associations[player.id] = selectedPlayer;
                        });
                      }
                    },
                  );
                },
              ),
            ),
            BottomAnimatedButton(
              buttonText: widget.match.group == null
                  ? loc.save_match_button
                  : loc.confirm,
              sizeRelativeToWidth: 0.95,
              onPressed: remainingCount == 0
                  ? () async {
                      if (widget.match.group == null) {
                        await _saveMatch();
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

  Future<void> _saveMatch() async {
    final db = Provider.of<AppDatabase>(context, listen: false);

    // Filter null values and cast to Map<String, Player>
    final playerAssociations = <String, Player>{};
    for (var entry in associations.entries) {
      if (entry.value != null) {
        playerAssociations[entry.key] = entry.value!;
      }
    }

    try {
      await MatchShareService().saveImportedMatch(
        db: db,
        importedMatch: widget.match,
        playerAssociations: playerAssociations,
        associatedGame: widget.associatedGame,
        associatedGroup: null,
      );
    } on MatchAlreadyExistsException {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar(message: loc.match_already_exists));
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar(message: e.toString()));
      return;
    }

    if (!mounted) return;

    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(CustomSnackBar(message: loc.data_successfully_imported));

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<Player?> showPlayerSelectionSheet(Player? currentSelection) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final allPlayers = await db.playerDao.getAllPlayers();
    final associatedPlayerIds = associations.values
        .where((p) => p != null && p.id != currentSelection?.id)
        .map((p) => p!.id)
        .toSet();

    final availablePlayers = allPlayers
        .where((p) => !associatedPlayerIds.contains(p.id))
        .toList();

    if (!mounted) return null;

    return showModalBottomSheet<Player>(
      context: context,
      backgroundColor: CustomTheme.backgroundColor,
      builder: (context) {
        return SinglePlayerSelectionWidget(
          onChanged: (player) async {
            await Future.delayed(const Duration(milliseconds: 400));
            if (!context.mounted) return;
            Navigator.of(context).pop(player);
          },
          onPlayerCreated: () {
            autoAssociatePlayers();
          },
          availablePlayers: availablePlayers,
          initialSelectedPlayer: currentSelection,
        );
      },
    );
  }

  Future<void> autoAssociatePlayers() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final allPlayers = await db.playerDao.getAllPlayers();

    if (!mounted) return;

    setState(() {
      final usedLocalPlayerIds = <String>{};

      for (var importedPlayer in playersToAssociate) {
        final match = allPlayers.where((localPlayer) {
          return !usedLocalPlayerIds.contains(localPlayer.id) &&
              localPlayer.name.toLowerCase() ==
                  importedPlayer.name.toLowerCase() &&
              localPlayer.nameCount == importedPlayer.nameCount;
        }).firstOrNull;

        if (match != null) {
          associations[importedPlayer.id] = match;
          usedLocalPlayerIds.add(match.id);
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
