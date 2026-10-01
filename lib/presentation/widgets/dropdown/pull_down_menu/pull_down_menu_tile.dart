import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/custom_theme.dart';

class PullDownMenuTile extends StatefulWidget {
  /// A single selectable row inside a [CustomPullDownMenu].
  ///
  /// -[icon]: Icon shown at the trailing edge of the row.
  /// - [label]: The text describing the action.
  /// - [onTap]: Called after the menu closes when the tile is tapped.
  /// - [enabled]: Whether the tile can be tapped.
  /// - [isDestructive]: Whether the tile represents a destructive action (rendered in red).
  const PullDownMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool isDestructive;

  @override
  State<PullDownMenuTile> createState() => _PullDownMenuTileState();
}

class _PullDownMenuTileState extends State<PullDownMenuTile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isDestructive
        ? CustomTheme.red
        : CustomTheme.textColor;
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
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
              widget.onTap();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isPressed ? CustomTheme.onBoxColor : CustomTheme.boxColor,
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
            Icon(widget.icon, size: 20, color: contentColor),
          ],
        ),
      ),
    );
  }
}
