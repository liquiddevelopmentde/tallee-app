import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';

class ChooseTile extends StatefulWidget {
  /// A tile widget that allows users to choose an option by tapping on it.
  /// - [title]: The title text displayed on the tile.
  /// - [icon]: Optional icon next to the title text.
  /// - [trailing]: Optional trailing text displayed on the tile.
  /// - [onPressed]: The callback invoked when the tile is tapped.
  /// - [enabled]: To enable/disable the tile and prohibit interaction
  const ChooseTile({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    this.onPressed,
    this.enabled = true,
  });

  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Widget? trailing;
  final bool enabled;

  @override
  State<ChooseTile> createState() => _ChooseTileState();
}

class _ChooseTileState extends State<ChooseTile> {
  bool get tappable => widget.onPressed != null && widget.enabled;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: tappable
        ? () {
            Haptics.selectionClick();
            widget.onPressed!.call();
          }
        : null,
    child: Opacity(
      opacity: widget.enabled ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: context.standardBoxDecoration,
        child: Row(
          spacing: 5,
          children: [
            Row(
              spacing: 10,
              children: [
                if (widget.icon != null) Icon(widget.icon),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.trailing != null)
                    IgnorePointer(
                      ignoring: !widget.enabled,
                      child: widget.trailing,
                    ),
                  if (tappable) const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
