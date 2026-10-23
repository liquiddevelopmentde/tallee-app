import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
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
  /// - [emptyText]: Optional text shown over the placeholder when there is no data
  const BarChart({
    super.key,
    required this.values,
    required this.displayCount,
    required this.barColor,
    required this.showAllValues,
    required this.showDisplayCountHighlighting,
    this.emptyText,
    required this.barTextColor,
  });

  final List<(Player, num)> values;
  final int displayCount;
  final Color barColor;
  final bool showAllValues;
  final bool showDisplayCountHighlighting;
  final String? emptyText;
  final Color barTextColor;

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

  Duration get animationDuration => const Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        // Bars
        AnimatedOpacity(
          opacity: hasData ? 1.0 : 0.2,
          duration: animationDuration,
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

              // Maximum value to scale bars
              final maxVal = displayValues.isNotEmpty
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
                    final double fraction = (maxVal > 0)
                        ? (displayValues[index].$2 / maxVal)
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
                              alignment: Alignment.centerLeft,
                              clipBehavior: Clip.hardEdge,
                              children: [
                                // Bar
                                AnimatedContainer(
                                  duration: animationDuration,
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

        // Text overlay
        AnimatedOpacity(
          opacity: hasData ? 0.0 : 1.0,
          duration: animationDuration,
          child: Text(
            emptyText ?? loc.no_suitable_matches_yet,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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

  /// Generates the text widget for the player name with a color that contrasts
  /// with the part of the label covered by the bar.
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

    final skeletonizing = Skeletonizer.maybeOf(context)?.enabled == true;
    final skeletonTextColor = context.talleeColors.skeletonFromColor.withAlpha(
      textAlpha,
    );
    final insideTextColor = skeletonizing
        ? skeletonTextColor
        : barTextColor.withAlpha(textAlpha);
    final outsideTextColor = skeletonizing
        ? skeletonTextColor
        : context.talleeColors.textColor.withAlpha(textAlpha);

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
          context,
          player,
          style: baseStyle,
          mainStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: insideTextColor,
          ),
          countStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: insideTextColor,
          ),
        ),
      ),
    );
  }
}
