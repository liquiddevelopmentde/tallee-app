import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';

export 'pair_tile.dart';
export 'player_tile.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - [content]: A content widget to display.
  /// - [backgroundColor]: Optional background color for the tile. Defaults to [context.talleeColors.onBoxColor].
  /// - [showIcon]: Whether the icon should be shown.
  /// - [icon]: Optional custom icon. Defaults to [Icons.close].
  /// - [onTileTap]: The callback to be invoked when the tile is tapped.
  /// - [highlighted]: Whether the tile is highlighted.
  const TextIconTile({
    super.key,
    required this.content,
    this.backgroundColor,
    this.showIcon = false,
    this.icon = Icons.close,
    this.onTileTap,
    this.highlighted = false,
  });

  final Widget content;
  final Color? backgroundColor;
  final bool showIcon;
  final IconData icon;
  final VoidCallback? onTileTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? context.talleeColors.onBoxColor;
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
              ? Border.all(color: context.talleeColors.boxBorderColor)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) const SizedBox(width: 3),
            Flexible(child: content),
            if (showIcon) ...<Widget>[
              const SizedBox(width: 3),
              Icon(icon, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
