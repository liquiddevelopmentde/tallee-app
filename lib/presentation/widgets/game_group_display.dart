import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/data/models/models.dart';

class GameGroupDisplay extends StatelessWidget {
  /// Shows `game / group` in a single line.
  ///
  /// If both texts do not fit, the available width is shared fairly: a text
  /// shorter than half of the space keeps its full width and the other one
  /// gets the rest; otherwise both get half and are cut off with an ellipsis.
  /// - [match]: The match whose game and group are displayed.
  /// - [centered]: Whether the line is centered instead of start-aligned.
  const GameGroupDisplay({
    super.key,
    required this.match,
    this.centered = false,
  });

  final Match match;
  final bool centered;

  Group? get group => match.group;

  Game get game => match.game;

  @override
  Widget build(BuildContext context) {
    const separator = ' / ';
    final gameText = game.name;
    final groupText = group == null
        ? null
        : '${group!.name}${match.extraPlayerCount}';

    final gameStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: game.color.colorValue(context).boxColorValue(context),
    );
    final separatorStyle = TextStyle(
      color: context.talleeColors.hintColor.withAlpha(150),
      fontWeight: FontWeight.bold,
    );
    final groupStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: context.talleeColors.hintColor,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final gameWidth = measureTextWidth(context, gameText, gameStyle);
        var effectiveGameWidth = gameWidth;
        var groupWidth = 0.0;

        if (groupText != null) {
          final groupNatural = measureTextWidth(context, groupText, groupStyle);
          groupWidth = groupNatural;
          final available =
              constraints.maxWidth -
              measureTextWidth(context, separator, separatorStyle);

          if (gameWidth + groupNatural > available) {
            final half = max(0.0, available / 2);
            if (gameWidth <= half) {
              groupWidth = available - gameWidth;
            } else if (groupNatural <= half) {
              effectiveGameWidth = available - groupNatural;
            } else {
              effectiveGameWidth = half;
              groupWidth = half;
            }
          }
        } else {
          effectiveGameWidth = min(gameWidth, constraints.maxWidth);
        }

        return Row(
          mainAxisAlignment: centered
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            getEllipsisText(gameText, gameStyle, effectiveGameWidth),
            if (groupText != null) ...[
              Text(separator, style: separatorStyle),
              getEllipsisText(groupText, groupStyle, groupWidth),
            ],
          ],
        );
      },
    );
  }

  /// Measures the width [text] needs in a single line, using the same text
  /// scaling and default style as a [Text] widget would.
  double measureTextWidth(BuildContext context, String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width.ceilToDouble();
    painter.dispose();
    return width;
  }

  Widget getEllipsisText(String text, TextStyle style, double width) =>
      SizedBox(
        width: max(0.0, width),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      );
}
