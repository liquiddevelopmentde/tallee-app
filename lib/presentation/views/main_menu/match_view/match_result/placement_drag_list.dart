import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/edge_blocked_bouncing_scroll_physics.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_list_tile.dart';

class PlacementDragList extends StatefulWidget {
  const PlacementDragList({
    super.key,
    required this.match,
    this.onPlayerOrderChanged,
    this.onTeamOrderChanged,
  });

  final Match match;
  final void Function(List<Player>)? onPlayerOrderChanged;
  final void Function(List<Team>)? onTeamOrderChanged;

  @override
  State<PlacementDragList> createState() => _PlacementDragListState();
}

class _PlacementDragListState extends State<PlacementDragList> {
  late List<Player> allPlayers;
  late List<Team> allTeams;

  /// Controller for scroll synchronizing
  late final ScrollController placementController;
  late final ScrollController valueController;
  bool isSyncingScroll = false;

  @override
  initState() {
    allTeams = widget.match.teams ?? [];
    allPlayers = widget.match.players;

    placementController = ScrollController();
    valueController = ScrollController();
    placementController.addListener(onPlacementScroll);
    valueController.addListener(onValueScroll);
    super.initState();
  }

  bool get useTeamLogic => widget.match.useTeamLogic;
  bool get isTeamMatch => widget.match.isTeamMatch;
  int get itemCount => useTeamLogic ? allTeams.length : allPlayers.length;

  @override
  Widget build(BuildContext context) {
    final double rowHeight = isTeamMatch ? 85 : 60;
    final double badgeSize = rowHeight - 7;

    return Expanded(
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: ListView.builder(
              controller: placementController,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: rowHeight,
                  child: Center(
                    child: placementBadge(index: index, badgeSize: badgeSize),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 4),
          useTeamLogic
              ? Expanded(
                  child: ReorderableListView.builder(
                    scrollController: valueController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: EdgeBlockedBouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.zero,
                    proxyDecorator: proxyDecorator,
                    onReorderItem: (int oldIndex, int newIndex) {
                      setState(() {
                        final Team team = allTeams.removeAt(oldIndex);
                        allTeams.insert(newIndex, team);
                      });
                    },
                    onReorderStart: (int index) async {
                      HapticFeedback.heavyImpact();
                    },
                    onReorderEnd: (int index) async {
                      HapticFeedback.selectionClick();
                    },
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        key: ValueKey(allTeams[index].id),
                        height: rowHeight,
                        child: isTeamMatch
                            ? TeamCard(
                                margin: const EdgeInsets.only(
                                  left: 4,
                                  right: 4,
                                  top: 4,
                                  bottom: 4,
                                ),
                                showDragHandle: true,
                                team: allTeams[index],
                                maxChars: 20,
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: TextIconListTile(
                                  player: allTeams[index].members.first,
                                  pair: allTeams[index].members.length > 1
                                      ? allTeams[index]
                                      : null,
                                  icon: Icons.drag_handle,
                                  pairIconLeft: true,
                                ),
                              ),
                      );
                    },
                  ),
                )
              : Expanded(
                  child: ReorderableListView.builder(
                    scrollController: valueController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: EdgeBlockedBouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.zero,
                    proxyDecorator: proxyDecorator,
                    onReorderItem: (int oldIndex, int newIndex) {
                      setState(() {
                        final Player item = allPlayers.removeAt(oldIndex);
                        allPlayers.insert(newIndex, item);
                      });
                    },
                    onReorderStart: (int index) async {
                      HapticFeedback.heavyImpact();
                    },
                    onReorderEnd: (int index) async {
                      HapticFeedback.selectionClick();
                    },
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        key: ValueKey(allPlayers[index].id),
                        height: rowHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TextIconListTile(
                            player: allPlayers[index],
                            icon: Icons.drag_handle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget placementBadge({required int index, required double badgeSize}) =>
      Container(
        alignment: Alignment.center,
        height: badgeSize,
        width: badgeSize,
        decoration: BoxDecoration(
          color: CustomTheme.boxBorderColor,
          borderRadius: CustomTheme.standardBorderRadiusAll,
        ),
        child: Text(
          ' #${index + 1} ',
          style: const TextStyle(
            color: CustomTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) =>
      AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(animation.value);
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                child!,
                Positioned.fill(
                  left: useTeamLogic ? 4 : 0,
                  right: useTeamLogic ? 4 : 0,
                  top: 4,
                  bottom: 4,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15 * t),
                        borderRadius: CustomTheme.standardBorderRadiusAll,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

  /// Handler for placement scrolling
  void onPlacementScroll() {
    syncScroll(placementController, valueController);
  }

  /// Handler for value scrolling
  void onValueScroll() {
    syncScroll(valueController, placementController);
  }

  /// Synchronizes the scroll position of the target controller to match the source controller.
  void syncScroll(ScrollController source, ScrollController target) {
    if (isSyncingScroll || !source.hasClients || !target.hasClients) {
      return;
    }

    isSyncingScroll = true;
    final minExtent = target.position.minScrollExtent;
    final maxExtent = target.position.maxScrollExtent;
    final targetOffset = source.offset.clamp(minExtent, maxExtent).toDouble();

    if ((target.offset - targetOffset).abs() > 0.5) {
      target.jumpTo(targetOffset);
    }

    isSyncingScroll = false;
  }
}
