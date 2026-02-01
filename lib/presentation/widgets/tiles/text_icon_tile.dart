import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - [text]: The text to display in the tile.
  /// - [iconEnabled]: A boolean to determine if the icon should be displayed.
  /// - [onIconTap]: The callback to be invoked when the icon is tapped.
  const TextIconTile({
    super.key,
    required this.text,
    this.iconEnabled = true,
    this.onIconTap,
  });

  /// The text to display in the tile.
  final String text;

  /// A boolean to determine if the icon should be displayed.
  final bool iconEnabled;

  /// The callback to be invoked when the icon is tapped.
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: CustomTheme.onBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconEnabled) const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (iconEnabled) ...<Widget>[
            const SizedBox(width: 3),
            GestureDetector(
              onTap: onIconTap,
              child: const Icon(Icons.close, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
