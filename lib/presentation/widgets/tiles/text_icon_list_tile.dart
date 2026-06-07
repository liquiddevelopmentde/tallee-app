import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/team.dart';

class TextIconListTile extends StatelessWidget {
  /// A list tile widget that displays text with an optional icon button.
  /// - [text]: The text to display in the tile.
  /// - [onPressed]: The callback to be invoked when the icon is pressed.
  /// - [iconEnabled]: A boolean to determine if the icon should be displayed.
  const TextIconListTile({
    super.key,
    required this.text,
    this.suffixText = '',
    this.pair,
    this.icon,
    this.color,
    this.onPressed,
  });

  /// The text to display in the tile.
  final String text;

  /// An optional suffix text to display after the main text.
  final String suffixText;

  /// An optional parameter to show 2 players (a pair) in one tile
  final Team? pair;

  /// The icon to display in the tile.
  final IconData? icon;

  final Color? color;

  /// The callback to be invoked when the icon is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color:
            Color.lerp(CustomTheme.onBoxColor, color?.withAlpha(10), 0.1) ??
            CustomTheme.boxColor,
        border: Border.all(
          color: color ?? CustomTheme.boxBorderColor,
          width: color != null ? 2 : 1,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
        borderRadius: CustomTheme.standardBorderRadiusAll,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (pair == null) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: suffixText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: CustomTheme.textColor.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              child: Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: pair!.members[0].name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: getNameCountText(pair!.members[0]),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: CustomTheme.textColor.withAlpha(100),
                          ),
                        ),
                        const TextSpan(
                          text: ' & ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: pair!.members[1].name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: getNameCountText(pair!.members[1]),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: CustomTheme.textColor.withAlpha(100),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.link),
                ],
              ),
            ),
          ],
          if (icon != null)
            GestureDetector(onTap: onPressed, child: Icon(icon, size: 20)),
        ],
      ),
    );
  }
}
