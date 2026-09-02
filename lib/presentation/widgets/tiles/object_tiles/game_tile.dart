import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';

class GameTile extends StatelessWidget {
  /// A list tile widget that displays a title and description, with optional highlighting and badge.
  /// - [game]: The game object displayed on the tile.
  /// - [onTap]: The callback invoked when the tile is tapped.
  /// - [onLongPress]: The callback invoked when the tile is tapped.
  /// - [isHighlighted]: A boolean to determine if the tile should be highlighted.
  const GameTile({
    super.key,
    required this.game,
    this.onTap,
    this.onLongPress,
    this.isHighlighted = false,
  });

  final Game game;

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final title = game.name;
    final description = game.description;
    final ruleset = translateRulesetToString(game.ruleset, context);
    final subtitle = ruleset;
    final gameColor = getColorFromAppColor(game.color);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (onTap != null) {
          onTap!.call();
        }
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        if (onLongPress != null) {
          onLongPress!.call();
        }
      },
      child: AnimatedContainer(
        margin: CustomTheme.tileMargin,
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 8),
        decoration: !isHighlighted
            ? CustomTheme.standardBoxDecoration
            : CustomTheme.highlightedBoxDecoration.copyWith(
                border: Border.all(
                  color: gameColor.withValues(alpha: 0.9),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              ),
        duration: const Duration(milliseconds: 200),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title row
                  Row(
                    spacing: 8,
                    children: [
                      // Colored Icon
                      ColoredIconContainer(
                        icon: getRulesetIcon(game.ruleset),
                        color: gameColor,
                        containerSize: 44,
                        iconSize: 24,
                        margin: EdgeInsets.zero,
                      ),

                      // Title & Subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            subtitle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CustomTheme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Description
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Padding(
                      // Padding to keep the visual start correct
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(height: 2.5),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: CustomTheme.hintColor),
          ],
        ),
      ),
    );
  }
}
