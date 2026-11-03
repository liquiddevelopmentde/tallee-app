import 'dart:math';

import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/empty_message.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/group_tile.dart';

class ChooseGroupView extends StatefulWidget {
  /// A view that allows the user to choose a group from a list of groups.
  /// - [groups]: A list of available groups to choose from
  /// - [initialGroups]: The initially selected group
  /// - [enableMultiSelection]: Whether multiple groups can be selected
  /// - [description]: An optional description shown at the top
  const ChooseGroupView({
    super.key,
    required this.groups,
    this.initialGroups,
    this.enableMultiSelection = false,
    this.description,
  });

  final List<Group> groups;
  final List<Group>? initialGroups;
  final bool enableMultiSelection;
  final String? description;

  @override
  State<ChooseGroupView> createState() => _ChooseGroupViewState();
}

class _ChooseGroupViewState extends State<ChooseGroupView> {
  final TextEditingController controller = TextEditingController();

  /// Currently selected group(s)
  late List<Group> selectedGroups;

  /// Groups filtered according to the current search query
  late final List<Group> filteredGroups;

  List<Group> get groups =>
      widget.groups..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

  // If selecting multiple is possible
  late bool enableMultiSelection;

  @override
  void initState() {
    selectedGroups = widget.initialGroups ?? [];
    filteredGroups = [...groups];
    enableMultiSelection = widget.enableMultiSelection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.talleeColors.backgroundColor,
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
          spacing: 10,
          children: [
            // Description
            if (widget.description != null && groups.isNotEmpty)
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(horizontal: 32),
                child: Text(
                  widget.description!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(color: context.talleeColors.hintColor),
                ),
              ),

            // Content
            Expanded(
              child: Column(
                children: [
                  if (groups.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomSearchBar(
                        controller: controller,
                        hintText: loc.search_for_groups,
                        onChanged: (value) {
                          setState(() {
                            filterGroups(value);
                          });
                        },
                      ),
                    ),

                  if (groups.isEmpty)
                    // No groups created
                    Expanded(
                      child: EmptyViewMessage(
                        icon: GROUP_ICON,
                        title: loc.no_groups,
                        message: loc.no_groups_created_yet,
                      ),
                    )
                  else if (filteredGroups.isEmpty)
                    // No groups matching search query
                    Expanded(
                      child: EmptyViewMessage(
                        icon: GROUP_ICON,
                        title: loc.no_results,
                        message: loc.there_is_no_group_matching_your_search,
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 25, top: 10),
                        itemCount: filteredGroups.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GroupTile(
                            group: filteredGroups[index],
                            isHighlighted: selectedGroups.any(
                              (group) => group.id == filteredGroups[index].id,
                            ),
                            onTap: () async {
                              setState(() {
                                if (selectedGroups.contains(
                                  filteredGroups[index],
                                )) {
                                  selectedGroups.removeWhere(
                                    (group) =>
                                        group.id == filteredGroups[index].id,
                                  );
                                } else {
                                  // In single select mode only allow one group
                                  if (!enableMultiSelection) {
                                    selectedGroups.clear();
                                  }
                                  selectedGroups.add(filteredGroups[index]);
                                }
                              });

                              // Navigate back to create match view instantly
                              if (!enableMultiSelection) {
                                await Future.delayed(MINIMUM_SKELETON_DURATION)
                                    .then((_) {
                                      if (!context.mounted) return;
                                      Navigator.of(context).pop(
                                        selectedGroups.isEmpty
                                            ? null
                                            : selectedGroups.first,
                                      );
                                    });
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Object? get popResult {
    if (enableMultiSelection) return selectedGroups;
    return selectedGroups.isEmpty ? null : selectedGroups.first;
  }

  /// Filters the groups based on the search [query].
  void filterGroups(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGroups.clear();
        filteredGroups.addAll(groups);
      } else {
        final List<({Group group, int score})> scoredGroups = [];

        for (final group in groups) {
          int maxScore = 0;

          // Check group name
          maxScore = max(maxScore, weightedRatio(group.name, query));

          // Check member names
          for (final member in group.members) {
            maxScore = max(maxScore, weightedRatio(member.name, query));
          }

          if (maxScore >= FUZZY_SEARCH_THRESHOLD) {
            scoredGroups.add((group: group, score: maxScore));
          }
        }

        // Sort by score descending
        scoredGroups.sort((a, b) => b.score.compareTo(a.score));

        filteredGroups.clear();
        filteredGroups.addAll(scoredGroups.map((e) => e.group));
      }
    });
  }
}
