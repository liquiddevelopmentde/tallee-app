import 'package:flutter/cupertino.dart';
import 'package:tallee/core/custom_theme.dart';

class TextChip extends StatefulWidget {
  const TextChip({
    super.key,
    required this.text,
    this.count = 0,
    required this.onTap,
  });

  final String text;
  final int count;
  final VoidCallback onTap;

  @override
  State<TextChip> createState() => _TextChipState();
}

class _TextChipState extends State<TextChip> {
  @override
  Widget build(BuildContext context) {
    final text = widget.text + (widget.count > 0 ? ' (${widget.count})' : '');
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: CustomTheme.onBoxColor,
          border: Border.all(
            color: CustomTheme.hintColor,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text),
      ),
    );
  }
}
