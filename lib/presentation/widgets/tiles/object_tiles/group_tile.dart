import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/player_view/player_detail_view.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
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
  });

  final Group group;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onPlayerChanged;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (widget.onTap != null) {
          widget.onTap!.call();
        }
      },
      child: AnimatedContainer(
        margin: CustomTheme.tileMargin,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: widget.isHighlighted
            ? CustomTheme.highlightedBoxDecoration
            : CustomTheme.standardBoxDecoration,
        duration: const Duration(milliseconds: 150),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group icon
                const ColoredIconContainer(
                  icon: Icons.group,
                  containerSize: 50,
                ),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 3,
                    children: [
                      // Name row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Name
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

                          // Member amount
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 6,
                            children: [
                              Text(
                                '${widget.group.members.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const Icon(Icons.group, size: 22),
                            ],
                          ),
                        ],
                      ),

                      // Description
                      Text(
                        widget.group.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CustomTheme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Player
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
                    onTileTap: () {
                      Navigator.push(
                        context,
                        adaptivePageRoute(
                          builder: (context) => PlayerDetailView(
                            player: member,
                            onPlayerUpdated: () {
                              widget.onPlayerChanged?.call();
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
