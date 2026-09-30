import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
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
    this.borderColor = Colors.transparent,
    this.leadingIcon,
  });

  final Widget content;
  final IconData? icon;
  final Icon? leadingIcon;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final bool highlighted;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null && icon != null;
    final bgColor = backgroundColor ?? CustomTheme.onBoxColor;

    return GestureDetector(
      onTap: onTileTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: highlighted ? bgColor.withAlpha((140).round()) : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null
              ? Border.all(
                  color: borderColor!,
                  strokeAlign: BorderSide.strokeAlignOutside,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            ?leadingIcon,
            Flexible(child: content),
            if (iconEnabled)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onIconTap?.call();
                },
                child: Icon(icon!, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
