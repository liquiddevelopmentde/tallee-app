import 'package:flutter/material.dart';
import 'package:flutter_numeric_text/flutter_numeric_text.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';

class LiveEditListTile extends StatefulWidget {
  const LiveEditListTile({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.color,
  });

  final Widget title;

  final int value;

  final void Function(int newValue)? onChanged;

  final Color? color;

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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        children: [
          if (widget.color != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: widget.color?.withAlpha(30),
                border: Border.all(color: widget.color!, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.title,
            )
          else
            widget.title,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FloatingAnimatedButton(
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
                onLongPressed: () => _score > minScore
                    ? {
                        setState(() {
                          _score -= 10;
                          if (widget.onChanged != null) {
                            widget.onChanged!(_score);
                          }
                        }),
                      }
                    : null,
                icon: Icons.remove_rounded,
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
              FloatingAnimatedButton(
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
                onLongPressed: () => _score > minScore
                    ? {
                        setState(() {
                          _score += 10;
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
        ],
      ),
    );
  }
}
