// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/name_display.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/group_view/group_detail_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/dialog/custom_dialog_action.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/player_profile_list_tile.dart';

class PlayerDetailView extends StatefulWidget {
  const PlayerDetailView({
    super.key,
    required this.player,
    required this.callback,
  });

  /// The player to display
  final Player player;

  final VoidCallback callback;

  @override
  State<PlayerDetailView> createState() => _PlayerDetailViewState();
}

class _PlayerDetailViewState extends State<PlayerDetailView> {
  late final AppDatabase db;
  late Player player;
  bool isLoading = true;

  /// Total matches played by this player
  int totalMatches = 0;

  /// Total matches won by this player
  int matchesWon = 0;

  /// Total groups this player belongs to
  int totalGroups = 0;

  /// Full list of groups this player belongs to
  List<Group> playerGroups = List.filled(
    4,
    Group(name: 'Skeleton group', members: []),
  );

  /// Full list of matches this player played in
  List<Match> playerMatches = List.filled(
    4,
    Match(
      name: 'Skeleton match',
      game: Game(name: 'Game name', ruleset: Ruleset.singleWinner),
      players: [],
    ),
  );

  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    player = widget.player;
    db = Provider.of<AppDatabase>(context, listen: false);
    _loadData();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.player_profile),
        actions: [
          if (!widget.player.deleted)
            HapticIconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                showDialog<bool>(
                  context: context,
                  builder: (context) => CustomAlertDialog(
                    title: loc.delete_player,
                    content: Text(loc.delete_player_warning_details),
                    actions: [
                      CustomDialogAction(
                        onPressed: () => Navigator.of(context).pop(true),
                        text: loc.delete,
                      ),
                      CustomDialogAction(
                        onPressed: () => Navigator.of(context).pop(false),
                        buttonType: ButtonType.secondary,
                        text: loc.cancel,
                      ),
                    ],
                  ),
                ).then((confirmed) async {
                  if (confirmed! && context.mounted) {
                    await db.playerDao.deletePlayer(playerId: widget.player.id);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    widget.callback();
                  }
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 20,
                bottom: 100,
              ),
              children: [
                // Icon
                const Center(
                  child: ColoredIconContainer(
                    icon: Icons.person,
                    containerSize: 55,
                    iconSize: 38,
                  ),
                ),
                const SizedBox(height: 10),

                // Playername + Playercount
                Center(
                  child: buildUnitNameWidget(
                    player,
                    mainStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.textColor,
                    ),
                  ),
                ),

                // Deleted state
                if (widget.player.deleted) ...[
                  Text(
                    loc.deleted,
                    style: const TextStyle(fontSize: 13, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 5),

                // Created at date
                Text(
                  '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(player.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Groups
                if (!widget.player.deleted) ...[
                  InfoTile(
                    title: '${loc.groups} ($totalGroups)',
                    icon: Icons.people,
                    horizontalAlignment: CrossAxisAlignment.start,
                    content: AppSkeleton(
                      enabled: isLoading,
                      fixLayoutBuilder: true,
                      alignment: Alignment.topLeft,
                      child: playerGroups.isNotEmpty
                          ? Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              spacing: 12,
                              runSpacing: 8,
                              children: playerGroups.map((group) {
                                return PlayerProfileListTile(
                                  title: group.name,
                                  count: group.members.length,
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      adaptivePageRoute(
                                        builder: (context) => GroupDetailView(
                                          group: group,
                                          callback: widget.callback,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            )
                          : Text(
                              loc.not_part_of_any_group,
                              style: const TextStyle(
                                fontSize: 14,
                                color: CustomTheme.textColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                // Matches
                InfoTile(
                  title: '${loc.matches} ($totalMatches)',
                  icon: Icons.sports_esports,
                  horizontalAlignment: CrossAxisAlignment.start,
                  content: AppSkeleton(
                    enabled: isLoading,
                    fixLayoutBuilder: true,
                    alignment: Alignment.topLeft,
                    child: playerMatches.isNotEmpty
                        ? Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            spacing: 12,
                            runSpacing: 8,
                            children: playerMatches.map((match) {
                              return PlayerProfileListTile(
                                title: match.name,
                                count: match.players.length,
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    adaptivePageRoute(
                                      builder: (context) => MatchDetailView(
                                        match: match,
                                        onMatchUpdate: widget.callback,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          )
                        : Text(
                            loc.no_matches_played_yet,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CustomTheme.textColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 15),

                // Statistics
                InfoTile(
                  title: loc.statistics,
                  icon: Icons.bar_chart,
                  content: AppSkeleton(
                    enabled: isLoading,
                    fixLayoutBuilder: true,
                    child: Column(
                      children: [
                        _buildStatRow(
                          loc.matches_played,
                          totalMatches.toString(),
                        ),
                        _buildStatRow(loc.matches_won, matchesWon.toString()),
                        _buildStatRow(
                          loc.winrate,
                          '${totalMatches == 0 ? 0 : ((matchesWon / totalMatches) * 100).round()}%',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Edit player button
            if (!widget.player.deleted)
              Positioned(
                bottom: MediaQuery.paddingOf(context).bottom,
                child: FloatingAnimatedButton(
                  text: loc.edit_player,
                  icon: Icons.edit,
                  onPressed: () async {
                    nameController.text = player.name;
                    showDialog<bool>(
                      context: context,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setDialogState) {
                          return CustomAlertDialog(
                            title: loc.edit_name,
                            content: TextInputField(
                              controller: nameController,
                              hintText: loc.set_name,
                              onChanged: (_) => setDialogState(() {}),
                            ),
                            actions: [
                              CustomDialogAction(
                                onPressed: isConfirmButtonEnabled()
                                    ? () => Navigator.of(context).pop(true)
                                    : null,
                                text: loc.confirm,
                              ),
                              CustomDialogAction(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                buttonType: ButtonType.secondary,
                                text: loc.cancel,
                              ),
                            ],
                          );
                        },
                      ),
                    ).then((confirmed) async {
                      if (confirmed! && context.mounted) {
                        final newName = nameController.text.trim();

                        if (newName != player.name) {
                          final fetchedPlayerNameCount = await db.playerDao
                              .getNameCount(name: newName);
                          await db.playerDao.updatePlayerName(
                            playerId: player.id,
                            name: newName,
                          );
                          widget.callback.call();
                          setState(() {
                            player = player.copyWith(
                              name: newName,
                              // If there is already a player with the same name,
                              // the count of that player is 0, so we start counting from 2 to get the correct count for this player. If there are no players with the same name, we just show the name without a count.
                              nameCount: fetchedPlayerNameCount == 0
                                  ? 0
                                  : fetchedPlayerNameCount + 1,
                            );
                          });
                        }
                      }
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Loads statistics for this player
  Future<void> _loadData() async {
    isLoading = true;
    final fetchedMatches = await db.matchDao.getMatchesByPlayer(
      playerId: player.id,
    );
    final fetchedGroups = await db.groupDao.getGroupsByPlayer(
      playerId: player.id,
    );

    if (!mounted) return;

    setState(() {
      playerMatches = fetchedMatches;
      totalMatches = fetchedMatches.length;
      matchesWon = fetchedMatches
          .where((match) => match.mvp.any((mvp) => mvp.id == player.id))
          .length;
      playerGroups = fetchedGroups;
      totalGroups = fetchedGroups.length;
      isLoading = false;
    });
  }

  /// Builds a single statistic row with a label and value
  /// - [label]: The label of the statistic
  /// - [value]: The value of the statistic
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: CustomTheme.textColor,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  bool isConfirmButtonEnabled() {
    return nameController.text.trim().isNotEmpty;
  }
}
