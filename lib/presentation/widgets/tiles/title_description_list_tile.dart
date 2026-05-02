import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class TitleDescriptionListTile extends StatelessWidget {
  /// A list tile widget that displays a title and description
  /// - [title]: The title text displayed on the tile.
  /// - [description]: The description text displayed below the title.
  /// - [onTap]: The callback invoked when the tile is tapped.
  /// - [isHighlighted]: A boolean to determine if the tile should be highlighted.
  const TitleDescriptionListTile({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
    this.isHighlighted = false,
  });

  /// The title text displayed on the tile.
  final String title;

  /// The description text displayed below the title.
  final String description;

  /// The callback invoked when the tile is tapped.
  final VoidCallback? onTap;

  /// A boolean to determine if the tile should be highlighted.
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
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

            // Description
            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2.5),
            ],
          ],
        ),
      ),
    );
  }
}
