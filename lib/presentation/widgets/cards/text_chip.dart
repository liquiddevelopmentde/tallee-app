import 'package:flutter/cupertino.dart';
import 'package:tallee/core/custom_theme.dart';

class TextChip extends StatefulWidget {
  /// A tappable text chip that shows a label and an optional item count.
  ///
  /// - [text]: The label text to display on the chip.
  /// - [onTap]: The callback function to execute when the chip is tapped.
  /// - [count]: An optional integer to display next to the label (default is 0).
  /// - [activated]: A boolean indicating whether the chip is in an activated state
  const TextChip({
    super.key,
    required this.text,
    required this.onTap,
    this.count = 0,
    this.activated = false,
  });

  final String text;
  final VoidCallback onTap;
  final int count;
  final bool activated;

  @override
  State<TextChip> createState() => _TextChipState();
}

class _TextChipState extends State<TextChip> {
  bool isPressed = false;
  final int delay = 200;

  @override
  Widget build(BuildContext context) {
    final text = widget.text + (widget.count > 0 ? ' (${widget.count})' : '');
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        Future.delayed(Duration(milliseconds: delay), () {
          setState(() {
            isPressed = false;
          });
        });
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: CustomTheme.onBoxColor,
          border: Border.all(
            color: widget.activated
                ? CustomTheme.textColor.withAlpha(150)
                : CustomTheme.textColor.withAlpha(50),
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: AnimatedDefaultTextStyle(
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: delay),
          style: TextStyle(
            color: isPressed
                ? CustomTheme.textColor.withAlpha(150)
                : CustomTheme.textColor.withAlpha(255),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
