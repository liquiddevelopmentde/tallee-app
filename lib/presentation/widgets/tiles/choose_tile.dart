import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';

class ChooseTile extends StatefulWidget {
  /// A tile widget that allows users to choose an option by tapping on it.
  /// - [title]: The title text displayed on the tile.
  /// - [trailing]: Optional trailing text displayed on the tile.
  /// - [onPressed]: The callback invoked when the tile is tapped.
  const ChooseTile({
    super.key,
    required this.title,
    this.trailing,
    this.onPressed,
  });

  /// The title text displayed on the tile.
  final String title;

  /// The callback invoked when the tile is tapped.
  final VoidCallback? onPressed;

  /// Optional trailing text displayed on the tile.
  final Widget? trailing;

  @override
  State<ChooseTile> createState() => _ChooseTileState();
}

class _ChooseTileState extends State<ChooseTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.vibrate();
        if (widget.onPressed != null) {
          widget.onPressed!.call();
        }
      },
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
            if (widget.trailing != null) widget.trailing!,
            if (widget.onPressed != null) ...[
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
