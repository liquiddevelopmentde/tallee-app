import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';

export 'pair_tile.dart';
export 'player_tile.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - [content]: A content widget to display.
  /// - [backgroundColor]: Optional background color for the tile. Defaults to [CustomTheme.onBoxColor].
  /// - [icon]: Optional custom icon. Defaults to [Icons.close].
  /// - [onIconTap]: The callback to be invoked when the icon is tapped.
  /// - [onTileTap]: The callback to be invoked when the tile is tapped.
  /// - [highlighted]: Whether the tile is highlighted.
  const TextIconTile({
    super.key,
    required this.content,
    this.backgroundColor,
    this.icon = Icons.close,
    this.onIconTap,
    this.onTileTap,
    this.highlighted = false,
  });

  final Widget content;
  final Color? backgroundColor;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null && icon != null;
    final effectiveBgColor = backgroundColor ?? CustomTheme.onBoxColor;
    final tileBgColor = highlighted
        ? effectiveBgColor.withAlpha((140).round())
        : effectiveBgColor;

    return GestureDetector(
      onTap: onTileTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: tileBgColor,
          borderRadius: BorderRadius.circular(12),
          border: effectiveBgColor == Colors.transparent
              ? Border.all(color: CustomTheme.boxBorderColor)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconEnabled) const SizedBox(width: 3),
            Flexible(child: content),
            if (iconEnabled) ...<Widget>[
              const SizedBox(width: 3),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onIconTap?.call();
                },
                child: Icon(icon!, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
