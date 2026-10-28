import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/app_colors.dart';
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
  /// - [muted]: Whether the tile is highlighted.
  /// - [selected]: Whether the tile is selected, e.g. for pairing.
  const TextIconTile({
    super.key,
    required this.content,
    this.backgroundColor,
    this.showIcon = false,
    this.icon = Icons.close,
    this.onTileTap,
    this.muted = false,
    this.selected = false,
  }) : assert(!(muted && selected), 'muted and selected can\'t both be true');

  final Widget content;
  final Color? backgroundColor;
  final bool showIcon;
  final IconData icon;
  final VoidCallback? onTileTap;
  final bool muted;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? context.talleeColors.onBoxColor;
    final tileBgColor = muted
        ? effectiveBgColor.withAlpha((140).round())
        : effectiveBgColor;

    return GestureDetector(
      onTap: onTileTap,
      child: AnimatedContainer(
        curve: Curves.easeInOutCubicEmphasized,
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: tileBgColor,
          borderRadius: BorderRadius.circular(12),
          border: effectiveBgColor == Colors.transparent
              ? Border.all(color: context.talleeColors.boxBorderColor)
              : null,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: AnimatedSize(
          curve: Curves.easeInOutCubicEmphasized,
          duration: const Duration(milliseconds: 250),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) const SizedBox(width: 3),
              Flexible(child: content),
              if (showIcon) ...<Widget>[
                const SizedBox(width: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(icon, key: ValueKey(icon), size: 20),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
