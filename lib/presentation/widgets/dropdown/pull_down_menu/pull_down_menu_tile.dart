import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';
import 'package:tallee/presentation/widgets/dropdown/pull_down_menu/pull_down_menu.dart';

class PullDownMenuTile extends StatefulWidget {
  /// A single selectable row inside a [PullDownMenu].
  ///
  /// - [icon]: Optional icon shown at the trailing edge of the row.
  /// - [label]: The text describing the action.
  /// - [onTap]: Called after the menu closes when the tile is tapped. Required
  ///   unless [subItems] is set.
  /// - [enabled]: Whether the tile can be tapped.
  /// - [isDestructive]: Whether the tile represents a destructive action (rendered in red).
  /// - [subItems]: Opens a nested menu with these tiles at the position of the
  ///   enclosing menu instead of calling [onTap].
  const PullDownMenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.isDestructive = false,
    this.subItems,
  }) : assert(
         onTap != null || subItems != null,
         'Either onTap or subItems must be provided',
       ),
       assert(
         subItems == null || subItems.length > 0,
         'subItems must not be empty',
       );

  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isDestructive;
  final List<PullDownMenuTile>? subItems;

  @override
  State<PullDownMenuTile> createState() => _PullDownMenuTileState();
}

class _PullDownMenuTileState extends State<PullDownMenuTile> {
  bool isPressed = false;

  bool get hasSubmenu => widget.subItems != null;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isDestructive
        ? context.talleeColors.errorColor
        : context.talleeColors.textColor;
    final Color contentColor = widget.enabled ? color : color.withAlpha(100);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled
          ? (_) => setState(() => isPressed = true)
          : null,
      onTapUp: widget.enabled ? (_) => setState(() => isPressed = false) : null,
      onTapCancel: widget.enabled
          ? () => setState(() => isPressed = false)
          : null,
      onTap: widget.enabled
          ? () {
              Haptics.selectionClick();
              if (hasSubmenu) {
                openSubmenu();
              } else {
                Navigator.of(context).pop();
                widget.onTap?.call();
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isPressed
            ? context.talleeColors.onBoxColor
            : context.talleeColors.boxColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          spacing: 10,
          children: [
            Expanded(
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.icon case final icon?)
              Icon(icon, size: 20, color: contentColor),
            if (hasSubmenu)
              Icon(Icons.chevron_right, size: 18, color: contentColor),
          ],
        ),
      ),
    );
  }

  void openSubmenu() {
    final scope = PullDownMenuScope.maybeOf(context);
    assert(
      scope != null,
      'PullDownMenuTile with subItems must be used inside a PullDownMenu',
    );
    scope?.openSubmenu(widget.subItems!);
  }
}
