import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_numeric_text/flutter_numeric_text.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class LiveEditListTile extends StatefulWidget {
  /// A large stepper tile with two big buttons on either side of a value.
  /// - [title]: The widget shown above the stepper (usually the unit name).
  /// - [value]: The initial value displayed by the tile.
  /// - [onChanged]: The callback invoked with the new value whenever it changes.
  /// - [color]: The optional accent color used to frame the [title].
  /// - [boundaries]: The inclusive (min, max) range the value is clamped to.
  /// - [isLivesRuleset]: Whether to render a heart icon next to the value and
  ///   dim it once the unit is eliminated.
  /// - [focusNode]:
  /// - [textInputAction]:
  /// - [onSubmitted]:
  const LiveEditListTile({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.color,
    this.boundaries = Constants.SCORE_INPUT_BOUNDARIES,
    this.isLivesRuleset = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final Widget title;
  final int value;
  final void Function(int newValue)? onChanged;
  final Color? color;
  final ({int min, int max}) boundaries;
  final bool isLivesRuleset;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<LiveEditListTile> createState() => _LiveEditListTileState();
}

class _LiveEditListTileState extends State<LiveEditListTile> {
  final int largeStep = 10;
  final int smallStep = 1;
  static const Duration animationDuration = Duration(milliseconds: 300);
  bool suppressAnimation = false;

  late int value;
  late final TextStyle valueTextStyle;
  late final TextEditingController controller;
  late final FocusNode focusNode;

  int get minValue => widget.boundaries.min;

  int get maxValue => widget.boundaries.max;

  // Ruleset.lives variables
  bool get isLowestValue => value <= widget.boundaries.min;
  IconData get livesIcon =>
      isLowestValue ? Icons.heart_broken_rounded : Icons.favorite_rounded;

  @override
  void initState() {
    value = widget.value.clamp(minValue, maxValue);
    valueTextStyle = TextStyle(
      fontSize: widget.isLivesRuleset ? 58 : 38,
      fontWeight: FontWeight.w600,
    );

    controller = TextEditingController(text: value.toString());
    focusNode = (widget.focusNode ?? FocusNode())..addListener(onFocusChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LiveEditListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final clamped = widget.value.clamp(minValue, maxValue);
      if (clamped != value) {
        setState(() => value = clamped);
        if (!focusNode.hasFocus) {
          suppressAnimation = false;
          setControllerText(value.toString());
        }
      }
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChanged);
    if (widget.focusNode == null) focusNode.dispose();
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

          // Button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Decrease button
              FloatingAnimatedButton(
                icon: Icons.remove_rounded,
                onPressed: value > minValue
                    ? () => onButtonPressed(-smallStep)
                    : null,
                onLongPressed: value > minValue
                    ? () => onButtonPressed(-largeStep)
                    : null,
              ),

              // Value display
              Expanded(
                child: widget.isLivesRuleset
                    // Lives display
                    ? TweenAnimationBuilder(
                        duration: animationDuration,
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

                          final valueText = value.toString();

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Hearts icon
                              Icon(livesIcon, color: iconColor, size: 28),
                              const SizedBox(width: 5),

                              // Value
                              SizedBox(
                                width: measureTextWidth(
                                  valueText,
                                  valueTextStyle,
                                ),
                                child: NumericText(
                                  valueText,
                                  duration: animationDuration,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  textWidthBasis: TextWidthBasis.longestLine,
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  style: valueTextStyle.copyWith(
                                    color: valueColor,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    // Score display
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                      displayedText,
                                      duration: suppressAnimation
                                          ? Duration.zero
                                          : animationDuration,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      textWidthBasis:
                                          TextWidthBasis.longestLine,
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                            applyHeightToFirstAscent: false,
                                            applyHeightToLastDescent: false,
                                          ),
                                      style: valueTextStyle.copyWith(
                                        color: CustomTheme.textColor,
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
                                        textInputAction: widget.textInputAction,
                                        onSubmitted: (_) {
                                          if (widget.onSubmitted != null) {
                                            widget.onSubmitted!();
                                          } else {
                                            focusNode.unfocus();
                                          }
                                        },
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              signed: true,
                                            ),
                                        inputFormatters: [
                                          TextInputFormatter.withFunction((
                                            oldValue,
                                            newValue,
                                          ) {
                                            return isValidScoreInput(
                                                  newValue.text,
                                                )
                                                ? newValue
                                                : oldValue;
                                          }),
                                        ],
                                        textAlign: TextAlign.center,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        showCursor: true,
                                        enableInteractiveSelection: true,
                                        cursorColor: CustomTheme.textColor,
                                        cursorHeight: 36,
                                        style: valueTextStyle.copyWith(
                                          height: 1.0,
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
                      ),
              ),

              // Increase button
              FloatingAnimatedButton(
                icon: Icons.add_rounded,
                onPressed: value < maxValue
                    ? () => onButtonPressed(smallStep)
                    : null,
                onLongPressed: value < maxValue
                    ? () => onButtonPressed(largeStep)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Measures the width of [text] rendered with [style].
  double measureTextWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.width + 4;
  }

  String get displayedText {
    final text = controller.text;
    // Fixes the layout problem
    if (text.isEmpty) return '\u00A0';
    if (text == '-') return text;
    return value.toString();
  }

  /// Updates the value with the given [delta], clamped into range.
  void onButtonPressed(int delta) {
    suppressAnimation = false;
    applyValue(value + delta);
    // Unfocus all text fields
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Parses live keyboard input to keep the text field and the animated
  /// text in sync.
  void onTextChanged(String text) {
    suppressAnimation = true;
    if (text.isEmpty || text == '-') {
      setState(() {});
    } else {
      final parsed = int.tryParse(text);
      if (parsed != null) applyValue(parsed);
    }
  }

  /// Applies the [newValue] to the value variable and syncs the text field if needed
  void applyValue(int newValue) {
    final clamped = controller.text.isEmpty
        // Reset count if text field is empty
        ? 0
        : newValue.clamp(minValue, maxValue);
    if (clamped != value) {
      value = clamped;
      widget.onChanged?.call(value);
    }
    setState(() => setControllerText(clamped.toString()));
  }

  /// Handles entering / leaving a text field
  void onFocusChanged() {
    // Textfield is focused
    if (focusNode.hasFocus) {
      // Place cursor at the end
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    } else {
      // User left textfield
      // Fallback to 0 for empty/invalid field content
      final resolved = int.tryParse(controller.text) ?? 0;
      applyValue(resolved);
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

    final maxDigits = max(
      maxValue.toString().length,
      minValue.toString().length - 1,
    );
    if (digits.isEmpty || digits.length > maxDigits) {
      return false;
    }

    // Check if all characters are digits 0 <= x <= 9
    return RegExp(r'^\d+$').hasMatch(digits);
  }
}
