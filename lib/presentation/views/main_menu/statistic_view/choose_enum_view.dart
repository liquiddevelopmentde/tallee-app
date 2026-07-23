import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class ChooseEnumView<T extends Enum> extends StatefulWidget {
  /// A view that allows the user to choose an enum value from a list of enum values.
  /// - [enumValue]: A list of available enum values to choose from
  /// - [initialEnum]: The initially selected enum value
  /// - [enableMultiSelection]: Whether multiple enum values can be selected
  const ChooseEnumView({
    super.key,
    required this.enumValue,
    this.initialEnums,
    this.enableMultiSelection = false,
  });

  final List<T> enumValue;
  final List<T>? initialEnums;
  final bool enableMultiSelection;

  @override
  State<ChooseEnumView<T>> createState() => _ChooseEnumViewState<T>();
}

class _ChooseEnumViewState<T extends Enum> extends State<ChooseEnumView<T>> {
  final TextEditingController controller = TextEditingController();

  late final List<T> filteredValues;
  late List<T> selectedValues;

  @override
  void initState() {
    filteredValues = [...widget.enumValue];
    selectedValues = widget.initialEnums ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(getTitle(widget.enumValue.first, loc))),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop(popResult);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomSearchBar(
                controller: controller,
                hintText: getHintText(widget.enumValue.first, loc),
                onChanged: (query) {
                  setState(() {
                    filterValues(query);
                  });
                },
              ),
            ),
            Expanded(
              child: Visibility(
                visible: filteredValues.isNotEmpty,
                replacement: TopCenteredMessage(
                  icon: Icons.info,
                  title: loc.info,
                  message: AppLocalizations.of(
                    context,
                  ).there_is_no_group_matching_your_search,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    bottom: 85,
                    top: 10,
                    right: 10,
                    left: 10,
                  ),
                  itemCount: filteredValues.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    bool isHighlighted = selectedValues.any(
                      (item) => item == filteredValues[index],
                    );

                    return GestureDetector(
                      child: AnimatedContainer(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: CustomTheme.boxColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: CustomTheme.boxBorderColor,
                            width: 2,
                          ),
                        ),
                        duration: const Duration(milliseconds: 150),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getValName(filteredValues[index], context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.check,
                              color: isHighlighted
                                  ? CustomTheme.textColor
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        setState(() {
                          if (selectedValues.contains(filteredValues[index])) {
                            selectedValues.removeWhere(
                              (val) => val == filteredValues[index],
                            );
                          } else {
                            // In single select mode only allow one item
                            if (!isMultiSelect) {
                              selectedValues.clear();
                            }
                            selectedValues.add(filteredValues[index]);
                          }
                        });

                        // Navigate back to create match view instantly
                        if (!isMultiSelect) {
                          await Future.delayed(
                            Constants.MINIMUM_SKELETON_DURATION,
                          ).then((_) {
                            if (!context.mounted) return;
                            Navigator.of(context).pop(
                              selectedValues.isEmpty
                                  ? null
                                  : selectedValues.first,
                            );
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isMultiSelect => widget.enableMultiSelection;

  Object? get popResult {
    if (isMultiSelect) return selectedValues;
    return selectedValues.isEmpty ? null : selectedValues.first;
  }

  /// Filters the values based on the search [query].
  void filterValues(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredValues.clear();
        filteredValues.addAll(widget.enumValue);
      } else {
        final List<({T value, int score})> scoredValues = [];

        for (final val in widget.enumValue) {
          int maxScore = 0;

          // Check item name
          maxScore = max(
            maxScore,
            weightedRatio(getValName(val, context), query),
          );

          if (maxScore >= Constants.FUZZY_SEARCH_THRESHOLD) {
            scoredValues.add((value: val, score: maxScore));
          }
        }

        // Sort by score descending
        scoredValues.sort((a, b) => b.score.compareTo(a.score));

        filteredValues.clear();
        filteredValues.addAll(scoredValues.map((e) => e.value));
      }
    });
  }

  /// Calls the correct translation function depending on the enum.
  /// Returns the localized string translation of the value
  String getValName(T value, BuildContext context) {
    if (value is StatisticScope) {
      return translateScopeToString(value, context);
    } else if (value is StatisticType) {
      return translateStatisticTypeToString(value, context);
    } else if (value is Timeframe) {
      return translateTimeframeToString(value, context);
    } else {
      return value.toString();
    }
  }

  /// Returns the correct view title depending on the enum.
  String getTitle(T value, AppLocalizations loc) {
    if (value is StatisticScope) {
      return loc.choose_scopes;
    } else if (value is StatisticType) {
      return loc.choose_types;
    } else if (value is Timeframe) {
      return loc.choose_timeframes;
    } else {
      return '';
    }
  }

  String getHintText(T value, AppLocalizations loc) {
    if (value is StatisticScope) {
      return loc.search_for_scopes;
    } else if (value is StatisticType) {
      return loc.search_for_types;
    } else if (value is Timeframe) {
      return loc.search_for_timeframes;
    } else {
      return '';
    }
  }
}
