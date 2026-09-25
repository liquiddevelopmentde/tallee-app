import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/name_display.dart';

class BarChart extends StatelessWidget {
  /// A widget that displays a horizontal bar chart for a list of values.
  /// - [values]: A list of tuples containing players and their corresponding numeric values.
  /// - [displayCount]: The number of top values to display in the bar chart.
  /// - [barColor]: The color of the bars in the chart.
  /// - [showAllValues]: Whether to show all values or limit to [displayCount].
  /// - [showDisplayCountHighlighting]: Whether to highlight entries that exceed the display count
  const BarChart({
    super.key,
    required this.values,
    required this.displayCount,
    required this.barColor,
    required this.showAllValues,
    required this.showDisplayCountHighlighting,
  });

  final List<(Player, num)> values;
  final int displayCount;
  final Color barColor;
  final bool showAllValues;
  final bool showDisplayCountHighlighting;

  static final List<(Player, num)> placeholderValues = [
    (Player(name: ''), 15),
    (Player(name: ''), 12),
    (Player(name: ''), 9),
    (Player(name: ''), 6),
    (Player(name: ''), 3),
  ];

  bool get hasData => values.any((entry) => entry.$2 != 0);

  // Use placeholder values if no values have been provided
  List<(Player, num)> get effectiveValues =>
      hasData ? values : placeholderValues;

  // If its the placeholder, the bar should take the whole space
  double get maxBarWidthFactor => hasData ? 0.8 : 1.0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        // Bars
        Opacity(
          opacity: hasData ? 1.0 : 0.2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxBarWidth = constraints.maxWidth * maxBarWidthFactor;

              // Show all values in the detail view and for the placeholder
              final displayedValuesCount = showAllValues || !hasData
                  ? effectiveValues.length
                  : min(effectiveValues.length, displayCount);
              final displayValues = effectiveValues
                  .take(displayedValuesCount)
                  .toList();

              // Maximum to scale bars
              final maximum = displayValues.isNotEmpty
                  ? displayValues.fold<num>(
                      0,
                      (currentMax, entry) =>
                          entry.$2 > currentMax ? entry.$2 : currentMax,
                    )
                  : 0;

              return Column(
                children: [
                  // Bars
                  ...List.generate(displayedValuesCount, (index) {
                    /// Fraction of wins
                    final double fraction = (maximum > 0)
                        ? (displayValues[index].$2 / maximum)
                        : 0.0;

                    /// Calculated width for current the bar
                    final double barWidth = (maxBarWidth * fraction).clamp(
                      0.0,
                      maxBarWidth,
                    );

                    /// Whether this entry is part of the "overflow" that exceeds the display count
                    final isOverflowEntry = index >= displayCount;

                    /// Whether to apply highlighting for entries that exceed the display count
                    final isHighlightedOverflow =
                        isOverflowEntry && showDisplayCountHighlighting;

                    /// Adjust bar color for highlighted overflow entries
                    final barClr = isHighlightedOverflow
                        ? barColor.withAlpha(120)
                        : barColor;

                    const textLeftPadding = 4.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: maxBarWidth,
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                // Bar
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.easeInOut,
                                  height: 24,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: barClr,
                                  ),
                                ),

                                // Player
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: textLeftPadding,
                                  ),
                                  child: playerText(
                                    context: context,
                                    player: displayValues[index].$1,
                                    barColor: barColor,
                                    barWidth: barWidth,
                                    textLeftPadding: textLeftPadding,
                                    isHighlightedOverflow:
                                        isHighlightedOverflow,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Value
                          if (hasData) ...[
                            const Spacer(),
                            Center(
                              child: Text(
                                formatValue(displayValues[index].$2),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),

        if (!hasData)
          // Text overlay
          Text(
            loc.no_results_yet,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  /// Returns a String representation of [value]. Rounds to one digit after
  /// comma if the value is a double.
  String formatValue(num value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    } else {
      return value.toString();
    }
  }

  /// Generates the text widget for the player name. If the bar color is
  /// yellow, the text with the bar in the background gets black
  Widget playerText({
    required BuildContext context,
    required Player player,
    required Color barColor,
    required double barWidth,
    required double textLeftPadding,
    required bool isHighlightedOverflow,
  }) {
    final textAlpha = isHighlightedOverflow ? 150 : 255;
    final baseStyle = DefaultTextStyle.of(context).style;

    if (barColor != getColorFromAppColor(AppColor.yellow)) {
      return RichText(
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        text: buildPlayerNameCountSpan(
          player,
          style: baseStyle,
          mainStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CustomTheme.textColor.withAlpha(textAlpha),
          ),
          countStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CustomTheme.textColor.withAlpha(
              isHighlightedOverflow ? 170 : 150,
            ),
          ),
        ),
      );
    }

    final insideTextColor = const Color(0xFF101010).withAlpha(textAlpha);
    final outsideTextColor = CustomTheme.textColor.withAlpha(textAlpha);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) {
        final coveredTextWidth = (barWidth - textLeftPadding).clamp(
          0.0,
          rect.width,
        );
        final splitStop = rect.width > 0
            ? (coveredTextWidth / rect.width).clamp(0.0, 1.0)
            : 0.0;

        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            insideTextColor,
            insideTextColor,
            outsideTextColor,
            outsideTextColor,
          ],
          stops: [0.0, splitStop, splitStop, 1.0],
        ).createShader(rect);
      },
      child: RichText(
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        text: buildPlayerNameCountSpan(
          player,
          style: baseStyle,
          mainStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          countStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
