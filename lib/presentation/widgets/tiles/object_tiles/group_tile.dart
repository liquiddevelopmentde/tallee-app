import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/player_detail_view.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

class GroupTile extends StatelessWidget {
  /// A tile widget that displays a group with its name, member count and
  /// members, following the same card style as the match tile.
  /// - [group]: The group data to be displayed.
  /// - [isHighlighted]: Whether the tile should be highlighted.
  /// - [onTap]: Callback function to be executed when the tile is tapped.
  /// - [onPlayerChanged]: Callback when a member is renamed.
  const GroupTile({
    super.key,
    required this.group,
    this.isHighlighted = false,
    this.onTap,
    this.onPlayerChanged,
  });

  /// The group data to be displayed.
  final Group group;

  /// Whether the tile should be highlighted.
  final bool isHighlighted;

  /// Callback function to be executed when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback function to be executed when the players in the group are changed.
  final VoidCallback? onPlayerChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final members = [...group.members]
      ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
    final memberCountText = group.members.length == 1
        ? '${group.members.length} ${loc.member}'
        : '${group.members.length} ${loc.members}';

    return GestureDetector(
      onTap: () async {
        await HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: AnimatedContainer(
        margin: CustomTheme.tileMargin,
        padding: const EdgeInsets.all(12),
        decoration: isHighlighted
            ? CustomTheme.highlightedBoxDecoration
            : CustomTheme.standardBoxDecoration,
        duration: const Duration(milliseconds: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ColoredIconContainer(
                  icon: Icons.group,
                  containerSize: 44,
                  iconSize: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        memberCountText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CustomTheme.hintColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: CustomTheme.hintColor,
                ),
              ],
            ),

            if (members.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: members.map((member) {
                  return PlayerTile(
                    player: member,
                    onTileTap: () {
                      Navigator.push(
                        context,
                        adaptivePageRoute(
                          builder: (context) => PlayerDetailView(
                            player: member,
                            onPlayerNameUpdated: () {
                              onPlayerChanged?.call();
                            },
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}