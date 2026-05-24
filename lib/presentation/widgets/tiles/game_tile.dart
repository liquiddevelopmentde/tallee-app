import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';

class GameTile extends StatelessWidget {
  /// A list tile widget that displays a title and description, with optional highlighting and badge.
  /// - [title]: The title text displayed on the tile.
  /// - [description]: The description text displayed below the title.
  /// - [onTap]: The callback invoked when the tile is tapped.
  /// - [onLongPress]: The callback invoked when the tile is tapped.
  /// - [isHighlighted]: A boolean to determine if the tile should be highlighted.
  /// - [badgeText]: Optional text to display in a badge on the right side of the title.
  /// - [badgeColor]: Optional color for the badge background.
  const GameTile({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
    this.onLongPress,
    this.isHighlighted = false,
    this.badgeText,
    this.badgeColor,
  });

  /// The title text displayed on the tile.
  final String title;

  /// The description text displayed below the title.
  final String description;

  /// The callback invoked when the tile is tapped.
  final VoidCallback? onTap;

  /// The callback invoked when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// A boolean to determine if the tile should be highlighted.
  final bool isHighlighted;

  /// Optional text to display in a badge on the right side of the title.
  final String? badgeText;

  /// Optional color for the badge background.
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final badgeTextColor = badgeColor != null
        ? (badgeColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white)
        : Colors.white;

    final gameColor = badgeColor ?? getColorFromAppColor(AppColor.orange);

    return GestureDetector(
      onTap: () async {
        await HapticFeedback.selectionClick();
        if (onTap != null) {
          onTap!.call();
        }
      },
      onLongPress: () async {
        await HapticFeedback.heavyImpact();
        if (onLongPress != null) {
          onLongPress!.call();
        }
      },
      child: AnimatedContainer(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: !isHighlighted
            ? CustomTheme.standardBoxDecoration
            : CustomTheme.highlightedBoxDecoration.copyWith(
                border: Border.all(
                  color: gameColor.withValues(alpha: 0.9),
                  width: 2,
                ),
              ),
        duration: const Duration(milliseconds: 200),
        child: Stack(
          children: [
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gameColor.withValues(alpha: 0.08),
                      gameColor.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
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

                  // Badge
                  if (badgeText != null) ...[
                    const SizedBox(height: 5),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 250),
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: gameColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  // Description
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(description, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 2.5),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
