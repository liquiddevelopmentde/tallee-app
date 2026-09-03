import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/group_view/create_group_view.dart';
import 'package:tallee/presentation/views/main_menu/player_view/player_detail_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/detail_tile.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

class GroupDetailView extends StatefulWidget {
  /// A view that displays the profile of a group
  /// - [group]: The group to display
  const GroupDetailView({
    super.key,
    required this.group,
    required this.callback,
  });

  /// The group to display
  final Group group;

  final VoidCallback callback;

  @override
  State<GroupDetailView> createState() => _GroupDetailViewState();
}

class _GroupDetailViewState extends State<GroupDetailView> {
  late final AppDatabase db;
  bool isLoading = true;
  late Group group;

  /// Total matches played in this group
  int totalMatches = 0;

  /// The best player in this group
  String bestPlayer = '';

  @override
  void initState() {
    super.initState();
    group = widget.group;
    db = Provider.of<AppDatabase>(context, listen: false);
    loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.group_profile),
        actions: [
          HapticIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              showDialog<bool>(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: '${loc.delete_group}?',
                  content: Text(
                    loc.delete_group_warning_details,
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
                  await db.groupDao.deleteGroup(groupId: group.id);
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
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (group.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      group.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CustomTheme.hintColor,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                const SizedBox(height: 5),
                Text(
                  '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(group.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                InfoTile(
                  title: loc.members,
                  leadingWidget: const Icon(Icons.people),
                  horizontalAlignment: CrossAxisAlignment.start,
                  content: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 12,
                    runSpacing: 8,
                    children: group.members.map((member) {
                      return PlayerTile(
                        player: member,
                        onTileTap: () {
                          Navigator.of(context).pushReplacement(
                            adaptivePageRoute(
                              builder: (context) => PlayerDetailView(
                                player: member,
                                onPlayerUpdated: widget.callback,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 15),

                // Statistics
                DetailTile(
                  rows: [
                    (loc.members, group.members.length.toString()),
                    (loc.played_matches, totalMatches.toString()),
                    (loc.best_player, bestPlayer),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
              child: FloatingAnimatedButton(
                text: loc.edit_group,
                icon: Icons.edit,
                onPressed: () async {
                  final updatedGroup = await Navigator.push<Group?>(
                    context,
                    adaptivePageRoute(
                      builder: (context) {
                        return CreateGroupView(
                          groupToEdit: group,
                          onMembersChanged: () {
                            loadStatistics();
                          },
                        );
                      },
                    ),
                  );
                  if (updatedGroup != null && mounted) {
                    setState(() {
                      group = updatedGroup;
                    });
                    loadStatistics();
                    widget.callback();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Loads statistics for this group
  Future<void> loadStatistics() async {
    isLoading = true;
    final groupMatches = await db.matchDao.getMatchesByGroup(groupId: group.id);

    setState(() {
      totalMatches = groupMatches.length;
      bestPlayer = getBestPlayer(groupMatches);
      isLoading = false;
    });
  }

  /// Determines the best player in the group based on match wins
  String getBestPlayer(List<Match> matches) {
    final mvpCounts = <Player, int>{};

    for (var match in matches) {
      final mvps = match.mvp;
      for (final mvpPlayer in mvps) {
        if (group.members.any((m) => m.id == mvpPlayer.id)) {
          mvpCounts.update(mvpPlayer, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }

    final sortedMvps = mvpCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedMvps.isEmpty) {
      return '-';
    }

    // Check if there are multiple players with the same value
    final highestMvpCount = sortedMvps.first.value;
    final topPlayers = sortedMvps
        .where((entry) => entry.value == highestMvpCount)
        .toList();
    switch (topPlayers.length) {
      case 0:
        return '-';
      case 1:
        return topPlayers.first.key.name;
      default:
        final loc = AppLocalizations.of(context);
        return loc.tie;
    }
  }
}
