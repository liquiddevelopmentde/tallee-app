import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class TextIconListTile extends StatelessWidget {
  /// A list tile widget that displays text with an optional icon button.
  /// - [text]: The text to display in the tile.
  /// - [onPressed]: The callback to be invoked when the icon is pressed.
  /// - [iconEnabled]: A boolean to determine if the icon should be displayed.
  const TextIconListTile({
    super.key,
    required this.text,
    this.iconEnabled = true,
    this.onPressed,
  });

  /// The text to display in the tile.
  final String text;

  /// A boolean to determine if the icon should be displayed.
  final bool iconEnabled;

  /// The callback to be invoked when the icon is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: CustomTheme.standardBoxDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (iconEnabled)
            GestureDetector(
              onTap: onPressed,
              child: const Icon(Icons.add, size: 20),
            ),
        ],
      ),
    );
  }
}
