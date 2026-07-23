import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/player_detail_view.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

class GroupTile extends StatefulWidget {
  /// A tile widget that displays information about a group, including its name and members.
  /// - [group]: The group data to be displayed.
  /// - [isHighlighted]: Whether the tile should be highlighted.
  /// - [onTap]: Callback function to be executed when the tile is tapped.
  const GroupTile({
    super.key,
    required this.group,
    this.isHighlighted = false,
    this.onTap,
    this.onPlayerChanged,
    this.borderColor,
    this.playersClickable = true,
  });

  /// The group data to be displayed.
  final Group group;

  /// Whether the tile should be highlighted.
  final bool isHighlighted;

  /// Callback function to be executed when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback function to be executed when the players in the group are changed.
  final VoidCallback? onPlayerChanged;

  /// Optional border color for the tile.
  final Color? borderColor;

  /// Whether the players in the group should be clickable.
  final bool playersClickable;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.selectionClick();
        if (widget.onTap != null) {
          widget.onTap!.call();
        }
      },
      child: AnimatedContainer(
        margin: CustomTheme.tileMargin,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: widget.isHighlighted
            ? CustomTheme.highlightedBoxDecoration
            : CustomTheme.standardBoxDecoration.copyWith(
                border: widget.borderColor != null
                    ? Border.all(color: widget.borderColor!)
                    : null,
              ),
        duration: const Duration(milliseconds: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                Flexible(
                  child: Text(
                    widget.group.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${widget.group.members.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(Icons.group, size: 22),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 12.0,
              runSpacing: 8.0,
              children: <Widget>[
                for (var member in [
                  ...widget.group.members,
                ]..sort((a, b) => a.name.compareIgnoringCaseTo(b.name)))
                  PlayerTile(
                    player: member,
                    onTileTap: widget.playersClickable
                        ? () {
                            Navigator.push(
                              context,
                              adaptivePageRoute(
                                builder: (context) => PlayerDetailView(
                                  player: member,
                                  onPlayerNameUpdated: () {
                                    widget.onPlayerChanged?.call();
                                  },
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 2.5),
          ],
        ),
      ),
    );
  }
}
