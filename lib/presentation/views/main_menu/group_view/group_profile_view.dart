import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/animated_dialog_button.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile.dart';

class GroupProfileView extends StatefulWidget {
  /// A view that displays the profile of a group
  /// - [group]: The group to display
  const GroupProfileView({
    super.key,
    required this.group,
    required this.callback,
  });

  /// The group to display
  final Group group;

  final VoidCallback callback;

  @override
  State<GroupProfileView> createState() => _GroupProfileViewState();
}

class _GroupProfileViewState extends State<GroupProfileView> {
  late final AppDatabase db;
  bool isLoading = true;

  /// Total matches played in this group
  int totalMatches = 0;

  String bestPlayer = '';

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.group_profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              showDialog<bool>(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: '${loc.delete_group}?',
                  content: loc.this_cannot_be_undone,
                  actions: [
                    AnimatedDialogButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        loc.cancel,
                        style: const TextStyle(color: CustomTheme.textColor),
                      ),
                    ),
                    AnimatedDialogButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        loc.delete,
                        style: const TextStyle(
                          color: CustomTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ).then((confirmed) async {
                if (confirmed! && context.mounted) {
                  await db.groupDao.deleteGroup(groupId: widget.group.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  widget.callback.call();
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
                    icon: Icons.group,
                    containerSize: 55,
                    iconSize: 38,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.group.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(widget.group.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                InfoTile(
                  title: loc.members,
                  icon: Icons.people,
                  horizontalAlignment: CrossAxisAlignment.start,
                  content: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 12,
                    runSpacing: 8,
                    children: widget.group.members.map((member) {
                      return TextIconTile(
                        text: member.name,
                        iconEnabled: false,
                      );
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
                          loc.members,
                          widget.group.members.length.toString(),
                        ),
                        _buildStatRow(
                          loc.played_matches,
                          totalMatches.toString(),
                        ),
                        _buildStatRow(loc.best_player, bestPlayer),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom,
              child: MainMenuButton(
                text: loc.edit_group,
                icon: Icons.edit,
                onPressed: () {
                  // TODO: Uncomment when GroupDetailView is implemented
                  /*
                  await Navigator.push(
                    context,
                    adaptivePageRoute(
                      builder: (context) {

                        return const GroupDetailView();
                      },
                    ),
                  );*/
                  print('Edit Group pressed');
                },
              ),
            ),
          ],
        ),
      ),
    );
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

  /// Loads statistics for this group
  Future<void> _loadStatistics() async {
    final matches = await db.matchDao.getAllMatches();
    final groupMatches = matches
        .where((match) => match.group?.id == widget.group.id)
        .toList();

    setState(() {
      totalMatches = groupMatches.length;
      bestPlayer = _getBestPlayer(groupMatches);
      isLoading = false;
    });
  }

  /// Determines the best player in the group based on match wins
  String _getBestPlayer(List<Match> matches) {
    final bestPlayerCounts = <Player, int>{};

    // Count wins for each player
    for (var match in matches) {
      if (match.winner != null) {
        bestPlayerCounts.update(
          match.winner!,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    // Sort players by win count
    final sortedPlayers = bestPlayerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get the best player
    bestPlayer = sortedPlayers.isNotEmpty ? sortedPlayers.first.key.name : '-';

    return bestPlayer;
  }
}
