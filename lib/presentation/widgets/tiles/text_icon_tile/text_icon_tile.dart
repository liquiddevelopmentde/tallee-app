import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

export 'pair_tile.dart';
export 'player_tile.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - [player]: An optional player object to display.
  /// - [pair]: An optional team object representing a pair of players.
  /// - [text]: The text to display if no player or pair is provided.
  /// - [onIconTap]: The callback to be invoked when the icon is tapped.
  /// - [icon]: Optional custom icon. Defaults to [Icons.close].
  /// - [onTileTap]: The callback to be invoked when the tile is tapped.
  const TextIconTile({
    super.key,
    required this.content,
    this.backgroundColor,
    this.icon = Icons.close,
    this.onIconTap,
    this.pairIconLeft = false,
    this.onTileTap,
    this.highlighted = false,
    this.leading,
    this.borderColor,
  });

  final Widget content;
  final Color? backgroundColor;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final bool pairIconLeft;
  final VoidCallback? onTileTap;
  final bool highlighted;

  /// Optional widget shown before the content, e.g. a winner crown.
  final Widget? leading;

  /// Optional colored border drawn inside the tile.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null && icon != null;
    final resolvedBackgroundColor =
        backgroundColor ??
        (highlighted
            ? CustomTheme.onBoxColor.withAlpha((140).round())
            : CustomTheme.onBoxColor);

    return GestureDetector(
      onTap: onTileTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: resolvedBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor == null
              ? null
              : Border.all(
                  color: borderColor!,
                  width: 1.0,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: 4),
            ],
            if (iconEnabled) const SizedBox(width: 3),
            Flexible(child: content),
            if (iconEnabled) ...<Widget>[
              const SizedBox(width: 3),
              GestureDetector(onTap: onIconTap, child: Icon(icon!, size: 20)),
            ],
          ],
        ),
      ),
    );
  }
}
