import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/views/main_menu/group_view/group_detail_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_detail_view.dart';
import 'package:tallee/presentation/views/main_menu/player_view/edit_player_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/detail_tile.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/player_profile_list_tile.dart';

class PlayerDetailView extends StatefulWidget {
  const PlayerDetailView({
    super.key,
    required this.player,
    required this.onPlayerUpdated,
  });

  final Player player;
  final VoidCallback onPlayerUpdated;

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
      game: Game(name: 'Game name', ruleset: Ruleset.winner),
      players: [],
    ),
  );

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    player = widget.player;
    db = Provider.of<AppDatabase>(context, listen: false);
    loadData();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    content: Text(
                      loc.delete_player_warning_details,
                      overflow: TextOverflow.visible,
                    ),
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
                    widget.onPlayerUpdated();
                  }
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
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
                    icon: PLAYER_ICON,
                    containerSize: 55,
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

                // Description
                if (player.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      player.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CustomTheme.hintColor,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
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
                    leadingWidget: const Icon(GROUP_ICON),
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
                                          callback: widget.onPlayerUpdated,
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
                  leadingWidget: const Icon(MATCH_ICON),
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
                                        onMatchUpdate: widget.onPlayerUpdated,
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
                DetailTile(
                  rows: [
                    (loc.matches_played, totalMatches.toString()),
                    (loc.matches_won, matchesWon.toString()),
                    (
                      loc.winrate,
                      '${totalMatches == 0 ? 0 : ((matchesWon / totalMatches) * 100).round()}%',
                    ),
                  ],
                ),
              ],
            ),

            // Edit player button
            if (!widget.player.deleted)
              Positioned(
                bottom: MediaQuery.viewPaddingOf(context).bottom,
                child: FloatingAnimatedButton(
                  text: loc.edit_player,
                  icon: Icons.edit,
                  onPressed: () async {
                    final updatedPlayer = await Navigator.of(context).push(
                      adaptivePageRoute(
                        builder: (context) => EditPlayerView(
                          playerToEdit: player,
                          onPlayerChanged: widget.onPlayerUpdated,
                        ),
                      ),
                    );
                    if (updatedPlayer != null) {
                      setState(() {
                        player = updatedPlayer;
                      });
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Loads statistics for this player
  Future<void> loadData() async {
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

  bool isConfirmButtonEnabled() => nameController.text.trim().isNotEmpty;
}
