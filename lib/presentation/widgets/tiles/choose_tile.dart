import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class ChooseTile extends StatefulWidget {
  /// A tile widget that allows users to choose an option by tapping on it.
  /// - [title]: The title text displayed on the tile.
  /// - [trailingText]: Optional trailing text displayed on the tile.
  /// - [onPressed]: The callback invoked when the tile is tapped.
  const ChooseTile({
    super.key,
    required this.title,
    this.trailingText,
    this.onPressed,
  });

  /// The title text displayed on the tile.
  final String title;

  /// The callback invoked when the tile is tapped.
  final VoidCallback? onPressed;

  /// Optional trailing text displayed on the tile.
  final String? trailingText;

  @override
  State<ChooseTile> createState() => _ChooseTileState();
}

class _ChooseTileState extends State<ChooseTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        margin: CustomTheme.tileMargin,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: CustomTheme.standardBoxDecoration,
        child: Row(
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (widget.trailingText != null) Text(widget.trailingText!),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
