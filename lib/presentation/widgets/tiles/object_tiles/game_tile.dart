import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';

class GameTile extends StatelessWidget {
  /// A list tile widget that displays a title and description, with optional highlighting and badge.
  /// - [title]: The title text displayed on the tile.
  /// - [subtitle]: An optional subtitle displayed under the title.
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
    this.subtitle,
    this.onTap,
    this.onLongPress,
    this.isHighlighted = false,
    this.badgeText,
    this.badgeColor,
  });

  final String title;

  final String? subtitle;

  final String description;

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  final bool isHighlighted;

  final String? badgeText;

  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final badgeTextColor = badgeColor != null
        ? (badgeColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white)
        : Colors.white;

    final gameColor = badgeColor ?? getColorFromAppColor(AppColor.orange);

    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        if (onTap != null) {
          onTap!.call();
        }
      },
      onLongPress: () async {
        HapticFeedback.heavyImpact();
        if (onLongPress != null) {
          onLongPress!.call();
        }
      },
      child: AnimatedContainer(
        margin: CustomTheme.tileMargin,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              spacing: 8,
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gameColor,
                  ),
                ),
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
              ],
            ),

            // Title
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 14,
                  color: CustomTheme.hintColor,
                ),
              ),
            ],

            // Badge
            if (badgeText != null) ...[
              const SizedBox(height: 5),
              Container(
                constraints: const BoxConstraints(maxWidth: 250),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
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
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2.5),
            ],
          ],
        ),
      ),
    );
  }
}
