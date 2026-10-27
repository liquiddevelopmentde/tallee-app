import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';

export 'pair_tile.dart';
export 'player_tile.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - [content]: A content widget to display.
  /// - [backgroundColor]: Optional background color for the tile. Defaults to [context.talleeColors.onBoxColor].
  /// - [icon]: Optional custom icon. Defaults to [Icons.close].
  /// - [onIconTap]: The callback to be invoked when the icon is tapped.
  /// - [onTileTap]: The callback to be invoked when the tile is tapped.
  /// - [muted]:  Whether to render the tile in a dimmed, outlined style.
  const TextIconTile({
    super.key,
    required this.content,
    this.backgroundColor,
    this.icon = Icons.close,
    this.onIconTap,
    this.onTileTap,
    this.muted = false,
  });

  final Widget content;
  final Color? backgroundColor;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null && icon != null;
    final bgColor = backgroundColor ?? context.talleeColors.onBoxColor;
    final effectiveBgColor = muted ? Colors.transparent : bgColor;
    final solidBorder = effectiveBgColor == Colors.transparent;

    return GestureDetector(
      onTap: onTileTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: solidBorder
                ? context.talleeColors.boxBorderColor
                : Colors.transparent,
          ),
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
