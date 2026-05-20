import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/dialog/custom_dialog_action.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile.dart';

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
    Group(name: "Skeleton group", members: []),
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

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile'),
        actions: [
          HapticIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              showDialog<bool>(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: 'Delete player?',
                  content: Text(loc.this_cannot_be_undone),
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
                  //TODO: implement player deletion in db
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
                const Center(
                  child: ColoredIconContainer(
                    icon: Icons.person,
                    containerSize: 55,
                    iconSize: 38,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.player.name + getNameCountText(widget.player),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(widget.player.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                InfoTile(
                  title: "Matches played in (${totalMatches})",
                  icon: Icons.people,
                  horizontalAlignment: CrossAxisAlignment.start,
                  content: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 12,
                    runSpacing: 8,
                    children: playerMatches.map((match) {
                      return TextIconTile(text: match.name, iconEnabled: false);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 15),
                InfoTile(
                  title: "Groups part of (${totalGroups})",
                  icon: Icons.people,
                  horizontalAlignment: CrossAxisAlignment.start,
                  content: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 12,
                    runSpacing: 8,
                    children: playerGroups.map((group) {
                      return TextIconTile(text: group.name, iconEnabled: false);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 15),
                InfoTile(
                  title: loc.statistics,
                  icon: Icons.bar_chart,
                  content: AppSkeleton(
                    enabled: isLoading,
                    child: Column(
                      children: [
                        _buildStatRow(
                          "Matches played",
                          totalMatches.toString(),
                        ),
                        _buildStatRow("Matches won", matchesWon.toString()),
                        _buildStatRow(
                          "Winrate",
                          '${totalMatches == 0 ? 0 : ((matchesWon / totalMatches) * 100).round()}%',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom,
              child: MainMenuButton(
                text: "Edit player",
                icon: Icons.edit,
                onPressed: () async {
                  //TODO: update player name in popup
                  widget.callback();
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
      playerId: widget.player.id,
    );
    final fetchedGroups = await db.groupDao.getGroupsByPlayer(
      playerId: widget.player.id,
    );

    setState(() {
      playerMatches = fetchedMatches;
      totalMatches = fetchedMatches.length;
      matchesWon = fetchedMatches
          .where((match) => match.mvp.any((mvp) => mvp.id == widget.player.id))
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
}
