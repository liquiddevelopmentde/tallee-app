import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class ChooseItemView extends StatefulWidget {
  /// A view that allows the user to choose a group from a list of groups.
  /// - [items]: A list of available groups to choose from
  /// - [initialItem]: The initially selected group
  /// - [enableMultiSelection]: Whether multiple groups can be selected
  const ChooseItemView({
    super.key,
    required this.items,
    this.initialItem,
    this.enableMultiSelection = false,
  });

  final List<dynamic> items;
  final dynamic initialItem;
  final bool enableMultiSelection;

  @override
  State<ChooseItemView> createState() => _ChooseItemViewState();
}

class _ChooseItemViewState extends State<ChooseItemView> {
  final TextEditingController controller = TextEditingController();

  List<dynamic> selectedItems = [];
  late final List<dynamic> filteredItems;

  // If selecting multiple is possible
  late bool enableMultiSelection;

  @override
  void initState() {
    filteredItems = [...widget.items];
    enableMultiSelection = widget.enableMultiSelection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(loc.choose_group)),
      body: PopScope(
        // This fixes that the Android Back Gesture didn't return the
        // selectedGroupId and therefore the selected Group wasn't saved
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
                hintText: loc.search_for_groups,
                onChanged: (value) {
                  setState(() {
                    filterItems(value);
                  });
                },
              ),
            ),
            Expanded(
              child: Visibility(
                visible: filteredItems.isNotEmpty,
                replacement: TopCenteredMessage(
                  icon: Icons.info,
                  title: loc.info,
                  message: AppLocalizations.of(
                    context,
                  ).there_is_no_group_matching_your_search,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 85, top: 10),
                  itemCount: filteredItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool isHighlighted = selectedItems.any(
                      (item) => item == filteredItems[index],
                    );
                    return GestureDetector(
                      child: Container(
                        child: Text(filteredItems[index].toString()),
                        color: isHighlighted ? Colors.blue : Colors.transparent,
                      ),
                      onTap: () async {
                        setState(() {
                          if (selectedItems.contains(filteredItems[index])) {
                            selectedItems.removeWhere(
                              (item) => item.id == filteredItems[index].id,
                            );
                          } else {
                            // In single select mode only allow one item
                            if (!enableMultiSelection) {
                              selectedItems.clear();
                            }
                            selectedItems.add(filteredItems[index]);
                          }
                        });

                        // Navigate back to create match view instantly
                        if (!enableMultiSelection) {
                          await Future.delayed(
                            Constants.MINIMUM_SKELETON_DURATION,
                          ).then((_) {
                            if (!context.mounted) return;
                            Navigator.of(context).pop(
                              selectedItems.isEmpty
                                  ? null
                                  : selectedItems.first,
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

  Object? get popResult {
    if (enableMultiSelection) return selectedItems;
    return selectedItems.isEmpty ? null : selectedItems.first;
  }

  /// Filters the items based on the search [query].
  void filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems.clear();
        filteredItems.addAll(widget.items);
      } else {
        final List<({dynamic item, int score})> scoredItems = [];

        for (final item in widget.items) {
          int maxScore = 0;

          // Check item name
          maxScore = max(maxScore, weightedRatio(item.name, query));

          // Check member names
          for (final member in item.members) {
            maxScore = max(maxScore, weightedRatio(member.name, query));
          }

          if (maxScore >= Constants.FUZZY_SEARCH_THRESHOLD) {
            scoredItems.add((item: item, score: maxScore));
          }
        }

        // Sort by score descending
        scoredItems.sort((a, b) => b.score.compareTo(a.score));

        filteredItems.clear();
        filteredItems.addAll(scoredItems.map((e) => e.item));
      }
    });
  }
}
