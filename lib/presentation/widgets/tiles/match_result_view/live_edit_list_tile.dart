import 'package:flutter/material.dart';
import 'package:flutter_numeric_text/flutter_numeric_text.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';

class LiveEditListTile extends StatefulWidget {
  const LiveEditListTile({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
  });

  final String title;

  final int value;

  final void Function(int newValue)? onChanged;

  @override
  State<LiveEditListTile> createState() => _LiveEditListTileState();
}

class _LiveEditListTileState extends State<LiveEditListTile> {
  int _score = 0;
  final int maxScore = 9999;
  final int minScore = -9999;

  @override
  void initState() {
    _score = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: CustomTheme.standardBoxDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MainMenuButton(
            onPressed: () => _score > minScore
                ? {
                    setState(() {
                      _score--;
                      if (widget.onChanged != null) {
                        widget.onChanged!(_score);
                      }
                    }),
                  }
                : null,
            icon: Icons.remove_rounded,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: NumericText(
                    _score.toString(),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    textWidthBasis: TextWidthBasis.longestLine,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          MainMenuButton(
            onPressed: () => _score < maxScore
                ? {
                    setState(() {
                      _score++;
                      if (widget.onChanged != null) {
                        widget.onChanged!(_score);
                      }
                    }),
                  }
                : null,
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }
}
