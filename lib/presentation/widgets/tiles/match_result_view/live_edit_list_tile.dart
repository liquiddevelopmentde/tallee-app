import 'package:flutter/material.dart';
import 'package:flutter_numeric_text/flutter_numeric_text.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class LiveEditListTile extends StatefulWidget {
  /// A large stepper tile with two big buttons on either side of a value.
  const LiveEditListTile({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.color,
    this.minValue = -9999,
    this.maxValue = 9999,
    this.isLivesRuleset = false,
  });

  final Widget title;
  final int value;
  final void Function(int newValue)? onChanged;
  final Color? color;
  final int minValue;
  final int maxValue;
  final bool isLivesRuleset;

  @override
  State<LiveEditListTile> createState() => _LiveEditListTileState();
}

class _LiveEditListTileState extends State<LiveEditListTile> {
  final int largeStep = 10;
  final int smallStep = 1;
  late int value;

  bool get isLowestValue => value <= widget.minValue;

  IconData get icon =>
      isLowestValue ? Icons.heart_broken_rounded : Icons.favorite_rounded;

  Color get valueColor => isLowestValue
      ? CustomTheme.textColor.withAlpha(90)
      : CustomTheme.textColor;

  @override
  void initState() {
    value = widget.value.clamp(widget.minValue, widget.maxValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        children: [
          if (widget.color != null) ...[
            // Colored unit name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: widget.color?.withAlpha(30),
                border: Border.all(color: widget.color!, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.title,
            ),
          ] else ...[
            // Default unit name
            widget.title,
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Decrease button
              FloatingAnimatedButton(
                icon: Icons.remove_rounded,
                onPressed: value > widget.minValue
                    ? () => changeValue(-smallStep)
                    : null,
                onLongPressed: value > widget.minValue
                    ? () => changeValue(-largeStep)
                    : null,
              ),

              // Value display
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLivesRuleset) ...[
                      Icon(
                        icon,
                        color: isLowestValue ? valueColor : Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: NumericText(
                        value.toString(),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        textWidthBasis: TextWidthBasis.longestLine,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: valueColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Increase button
              FloatingAnimatedButton(
                icon: Icons.add_rounded,
                onPressed: value < widget.maxValue
                    ? () => changeValue(smallStep)
                    : null,
                onLongPressed: value < widget.maxValue
                    ? () => changeValue(largeStep)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Updated the value with the given [delta] while clamping it between the
  /// minimum and the maximum value
  void changeValue(int delta) {
    final clamped = (value + delta).clamp(widget.minValue, widget.maxValue);
    if (clamped == value) return;
    setState(() => value = clamped);
    widget.onChanged?.call(value);
  }
}
