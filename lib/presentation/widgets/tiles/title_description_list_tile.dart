import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class TitleDescriptionListTile extends StatelessWidget {
  /// A list tile widget that displays a title and description, with optional highlighting and badge.
  /// - [title]: The title text displayed on the tile.
  /// - [description]: The description text displayed below the title.
  /// - [onPressed]: The callback invoked when the tile is tapped.
  /// - [isHighlighted]: A boolean to determine if the tile should be highlighted.
  /// - [badgeText]: Optional text to display in a badge on the right side of the title.
  /// - [badgeColor]: Optional color for the badge background.
  const TitleDescriptionListTile({
    super.key,
    required this.title,
    required this.description,
    this.onPressed,
    this.isHighlighted = false,
    this.badgeText,
    this.badgeColor,
  });

  /// The title text displayed on the tile.
  final String title;

  /// The description text displayed below the title.
  final String description;

  /// The callback invoked when the tile is tapped.
  final VoidCallback? onPressed;

  /// A boolean to determine if the tile should be highlighted.
  final bool isHighlighted;

  /// Optional text to display in a badge on the right side of the title.
  final String? badgeText;

  /// Optional color for the badge background.
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: isHighlighted
            ? CustomTheme.highlightedBoxDecoration
            : CustomTheme.standardBoxDecoration,
        duration: const Duration(milliseconds: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 230,
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (badgeText != null) ...[
                  const Spacer(),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 115),
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? CustomTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2.5),
            ],
          ],
        ),
      ),
    );
  }
}
