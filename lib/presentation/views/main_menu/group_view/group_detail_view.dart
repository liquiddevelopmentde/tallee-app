import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/group_view/create_group_view.dart';
import 'package:tallee/presentation/views/main_menu/player_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/dialog/custom_dialog_action.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile.dart';
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
  late Group _group;

  /// Total matches played in this group
  int totalMatches = 0;

  /// The best player in this group
  String bestPlayer = '';

  @override
  void initState() {
    super.initState();
    _group = widget.group;
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
          HapticIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              showDialog<bool>(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: '${loc.delete_group}?',
                  content: Text(loc.delete_group_warning_details),
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
                  await db.groupDao.deleteGroup(groupId: _group.id);
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
                  _group.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_group.createdAt)}',
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
                    children: _group.members.map((member) {
                      return PlayerTile(
                        player: member,
                        onTileTap: () {
                          Navigator.of(context).pushReplacement(
                            adaptivePageRoute(
                              builder: (context) => PlayerDetailView(
                                player: member,
                                callback: widget.callback,
                              ),
                            ),
                          );
                        },
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
                          _group.members.length.toString(),
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
              child: FloatingAnimatedButton(
                text: loc.edit_group,
                icon: Icons.edit,
                onPressed: () async {
                  final updatedGroup = await Navigator.push<Group?>(
                    context,
                    adaptivePageRoute(
                      builder: (context) {
                        return CreateGroupView(
                          groupToEdit: _group,
                          onMembersChanged: () {
                            _loadStatistics();
                          },
                        );
                      },
                    ),
                  );
                  if (updatedGroup != null && mounted) {
                    setState(() {
                      _group = updatedGroup;
                    });
                    _loadStatistics();
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
    isLoading = true;
    final groupMatches = await db.matchDao.getMatchesByGroup(
      groupId: _group.id,
    );

    setState(() {
      totalMatches = groupMatches.length;
      bestPlayer = _getBestPlayer(groupMatches);
      isLoading = false;
    });
  }

  /// Determines the best player in the group based on match wins
  String _getBestPlayer(List<Match> matches) {
    final mvpCounts = <Player, int>{};

    for (var match in matches) {
      final mvps = match.mvp;
      for (final mvpPlayer in mvps) {
        if (_group.members.any((m) => m.id == mvpPlayer.id)) {
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
