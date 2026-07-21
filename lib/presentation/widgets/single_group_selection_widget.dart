import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/group_view/create_group_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/custom_radio_list_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class SingleGroupSelectionWidget extends StatefulWidget {
  const SingleGroupSelectionWidget({
    this.availableGroups,
    this.initialSelectedGroup,
    required this.onChanged,
    this.onGroupCreated,
    super.key,
  });

  /// An optional list of groups to choose from. If null, all groups from the database are used.
  final List<Group>? availableGroups;

  /// An optional group that should be pre-selected.
  final Group? initialSelectedGroup;

  /// A callback function that is invoked whenever the selection changes.
  final Function(Group group) onChanged;

  /// A callback function that is invoked when a group was created.
  final VoidCallback? onGroupCreated;

  @override
  State<SingleGroupSelectionWidget> createState() =>
      _SingleGroupSelectionWidgetState();
}

class _SingleGroupSelectionWidgetState
    extends State<SingleGroupSelectionWidget> {
  late final AppDatabase db;
  bool isLoading = true;

  /// Future that loads all groups from the database.
  late Future<List<Group>> _allGroupsFuture;

  /// The complete list of all available groups.
  List<Group> allGroups = [];

  /// The list of groups suggested based on the search input.
  List<Group> suggestedGroups = [];

  Group? selectedGroup;

  /// Controller for the search bar input.
  late final TextEditingController _searchBarController =
      TextEditingController();

  /// Skeleton data used while loading groups.
  late final List<Group> skeletonData = List.filled(
    5,
    Group(name: 'Group 0', members: []),
  );

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    suggestedGroups = skeletonData;

    if (widget.initialSelectedGroup != null) {
      selectedGroup = widget.initialSelectedGroup;
    }

    loadGroupList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomSearchBar(
            maxLength: Constants.MAX_GROUP_NAME_LENGTH,
            controller: _searchBarController,
            constraints: const BoxConstraints(maxHeight: 45, minHeight: 45),
            hintText: loc.search_for_groups,
            trailingButtonShown: true,
            trailingButtonicon: Icons.add_circle,
            trailingButtonEnabled: true,
            onTrailingButtonPressed: () async {
              final newGroup = await Navigator.of(context).push<Group>(
                adaptivePageRoute(
                  builder: (context) => const CreateGroupView(),
                ),
              );
              if (newGroup != null) {
                widget.onGroupCreated?.call();
                loadGroupList();
                widget.onChanged(newGroup);
              }
            },
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  suggestedGroups = [...allGroups];
                } else {
                  final List<({Group group, int score})> scoredGroups = [];

                  for (final group in allGroups) {
                    int maxScore = 0;
                    maxScore = max(maxScore, weightedRatio(group.name, value));
                    for (final member in group.members) {
                      maxScore = max(
                        maxScore,
                        weightedRatio(member.name, value),
                      );
                    }

                    if (maxScore >= Constants.FUZZY_SEARCH_THRESHOLD) {
                      scoredGroups.add((group: group, score: maxScore));
                    }
                  }
                  scoredGroups.sort((a, b) => b.score.compareTo(a.score));
                  suggestedGroups = scoredGroups.map((e) => e.group).toList();
                }
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: AppSkeleton(
              enabled: isLoading,
              child: Visibility(
                visible: suggestedGroups.isNotEmpty,
                replacement: TopCenteredMessage(
                  icon: Icons.info,
                  title: loc.info,
                  message: _getInfoText(context),
                  fullscreen: false,
                ),
                child: RadioGroup<Group>(
                  groupValue: selectedGroup,
                  onChanged: (value) {
                    if (value != null) {
                      widget.onChanged(value);
                    }
                  },
                  child: ListView.builder(
                    itemCount: suggestedGroups.length,
                    itemBuilder: (context, index) {
                      final group = suggestedGroups[index];
                      return CustomRadioListTile<Group>(
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            group.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        value: group,
                        onContainerTap: (value) async {
                          await HapticFeedback.selectionClick();
                          setState(() {
                            selectedGroup = value;
                          });
                          widget.onChanged(value);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Loads the list of groups from the database or uses the provided available groups.
  /// Sets the loading state and updates the group lists accordingly.
  void loadGroupList() {
    _allGroupsFuture = Future.wait([
      db.groupDao.getAllGroups(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]).then((results) => results[0] as List<Group>);

    _allGroupsFuture.then((loadedGroups) {
      if (!mounted) return;
      setState(() {
        // If a list of available groups is provided (even if empty), use that list.
        if (widget.availableGroups != null) {
          widget.availableGroups!.sort((a, b) => a.name.compareTo(b.name));
          allGroups = [...widget.availableGroups!];
        } else {
          // Otherwise, use the loaded groups from the database.
          loadedGroups.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          allGroups = [...loadedGroups];
        }
        suggestedGroups = [...allGroups];
        isLoading = false;
      });
    });
  }

  /// Determines the appropriate info text to display when no groups
  /// are available in the suggested groups list.
  String _getInfoText(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (allGroups.isEmpty) {
      return loc.no_groups_created_yet;
    } else {
      return loc.there_is_no_group_matching_your_search;
    }
  }
}
