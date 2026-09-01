import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_numeric_text/flutter_numeric_text.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class LiveEditListTile extends StatefulWidget {
  /// A large stepper tile with two big buttons on either side of a value.
  /// - [title]: The widget shown above the stepper (usually the unit name).
  /// - [value]: The initial value displayed by the tile.
  /// - [onChanged]: The callback invoked with the new value whenever it changes.
  /// - [color]: The optional accent color used to frame the [title].
  /// - [minValue]: The inclusive lower bound the value is clamped to.
  /// - [maxValue]: The inclusive upper bound the value is clamped to.
  /// - [isLivesRuleset]: Whether to render a heart icon next to the value and
  ///   dim it once the unit is eliminated.
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

  late final TextEditingController controller;
  late final FocusNode focusNode;

  bool get isLowestValue => value <= widget.minValue;

  IconData get icon =>
      isLowestValue ? Icons.heart_broken_rounded : Icons.favorite_rounded;

  @override
  void initState() {
    value = widget.value.clamp(widget.minValue, widget.maxValue);
    controller = TextEditingController(text: value.toString());
    focusNode = FocusNode()..addListener(onFocusChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LiveEditListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final clamped = widget.value.clamp(widget.minValue, widget.maxValue);
      if (clamped != value) {
        setState(() => value = clamped);
        if (!focusNode.hasFocus) setControllerText(value.toString());
      }
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChanged);
    focusNode.dispose();
    controller.dispose();
    super.dispose();
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
                      child: SizedBox(
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Value
                            SizedBox(
                              width: 150,
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

                            // Invisible input field.
                            Positioned.fill(
                              top: 8,
                              left: 2,
                              child: MediaQuery.withNoTextScaling(
                                child: TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  onChanged: onTextChanged,
                                  onSubmitted: (_) => focusNode.unfocus(),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        signed: true,
                                      ),
                                  inputFormatters: [
                                    TextInputFormatter.withFunction((
                                      oldValue,
                                      newValue,
                                    ) {
                                      return isValidScoreInput(newValue.text)
                                          ? newValue
                                          : oldValue;
                                    }),
                                  ],
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  showCursor: true,
                                  enableInteractiveSelection: true,
                                  cursorColor: CustomTheme.textColor,
                                  cursorHeight: 36,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    height: 1.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.transparent,
                                  ),
                                  decoration: const InputDecoration(
                                    isCollapsed: true,
                                    border: InputBorder.none,
                                    counterText: '',
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(end: isLowestValue ? 1 : 0),
                  builder: (context, t, _) {
                    final iconColor = Color.lerp(
                      Colors.red,
                      CustomTheme.textColor.withAlpha(90),
                      t,
                    );
                    final valueColor = Color.lerp(
                      CustomTheme.textColor,
                      CustomTheme.textColor.withAlpha(90),
                      t,
                    );

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLivesRuleset) ...[
                          Icon(icon, color: iconColor, size: 28),
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
                    );
                  },
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

  /// Updates the value with the given [delta], clamped into range.
  void changeValue(int delta) => applyValue(value + delta, syncTextField: true);

  /// Parses live keyboard input to keep the text field and the animated
  /// text in sync.
  void onTextChanged(String text) {
    if (text.isEmpty || text == '-') {
      setControllerText(value.toString());
      return;
    }
    final parsed = int.tryParse(text);
    if (parsed != null) applyValue(parsed);
  }

  /// Applies the [newValue] to the value variable and syncs the text field if needed
  void applyValue(int newValue, {bool syncTextField = false}) {
    final clamped = newValue.clamp(widget.minValue, widget.maxValue);
    if (clamped != value) {
      setState(() => value = clamped);
      widget.onChanged?.call(value);
    }

    // Only sync when value differs or explicitly called
    if (syncTextField || clamped != newValue) {
      setControllerText(clamped.toString());
    }
  }

  void onFocusChanged() {
    if (focusNode.hasFocus) {
      // Place the cursor at the end of the number
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    } else {
      setControllerText(value.toString());
    }
  }

  void setControllerText(String text) {
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Validates the input for a score text field.
  bool isValidScoreInput(String text) {
    if (text.isEmpty || text == '-') {
      return true;
    }

    final isNegative = text.startsWith('-');
    final digits = isNegative ? text.substring(1) : text;

    if (digits.isEmpty || digits.length > 4) {
      return false;
    }

    // CHeck if all characters are digits 0 <= x <= 9
    return digits.codeUnits.every((unit) => unit >= 48 && unit <= 57);
  }
}
