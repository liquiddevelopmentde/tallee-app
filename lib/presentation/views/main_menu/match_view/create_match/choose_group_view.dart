import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/group_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class ChooseGroupView extends StatefulWidget {
  /// A view that allows the user to choose a group from a list of groups.
  /// - [groups]: A list of available groups to choose from
  /// - [initialGroups]: The initially selected group
  /// - [statistic]: Optional statistic payload for choosing groups for a statistic
  /// - [enableMultiSelection]: Whether multiple groups can be selected
  const ChooseGroupView({
    super.key,
    required this.groups,
    this.initialGroups,
    this.statistic,
    this.enableMultiSelection = false,
  });

  final List<Group> groups;
  final List<Group>? initialGroups;
  final Statistic? statistic;
  final bool enableMultiSelection;

  @override
  State<ChooseGroupView> createState() => _ChooseGroupViewState();
}

class _ChooseGroupViewState extends State<ChooseGroupView> {
  final TextEditingController controller = TextEditingController();

  late final List<Group> filteredGroups;
  late List<Group> selectedGroups;

  // If selecting multiple is possible
  late bool enableMultiSelection;

  @override
  void initState() {
    filteredGroups = [...widget.groups];
    selectedGroups = widget.initialGroups ?? [];
    enableMultiSelection =
        widget.enableMultiSelection || widget.statistic != null;
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
                    filterGroups(value);
                  });
                },
              ),
            ),
            Expanded(
              child: Visibility(
                visible: filteredGroups.isNotEmpty,
                replacement: Visibility(
                  visible: widget.groups.isNotEmpty,
                  replacement: TopCenteredMessage(
                    icon: Icons.info,
                    title: loc.info,
                    message: loc.no_groups_created_yet,
                  ),
                  child: TopCenteredMessage(
                    icon: Icons.info,
                    title: loc.info,
                    message: AppLocalizations.of(context)
                        .there_is_no_group_matching_your_search,
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 85, top: 10),
                  itemCount: filteredGroups.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GroupTile(
                      group: filteredGroups[index],
                      isHighlighted: selectedGroups.any(
                        (group) => group.id == filteredGroups[index].id,
                      ),
                      onTap: () async {
                        setState(() {
                          if (selectedGroups.contains(filteredGroups[index])) {
                            selectedGroups.removeWhere(
                              (group) => group.id == filteredGroups[index].id,
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
            ),

            // Create statistic button
            if (widget.statistic != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                child: BottomAnimatedButton(
                  buttonConstraints: const BoxConstraints(minWidth: 390),
                  buttonText: buttonText,
                  onPressed: selectedGroups.isNotEmpty
                      ? () => submitStatistic()
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get buttonText =>
      widget.statistic != null &&
          widget.statistic!.scopes.contains(StatisticScope.selectedGames)
      ? AppLocalizations.of(context).confirm
      : AppLocalizations.of(context).create_statistic;

  Object? get popResult {
    if (widget.statistic != null) return null;
    if (enableMultiSelection) return selectedGroups;
    return selectedGroups.isEmpty ? null : selectedGroups.first;
  }

  Future<void> submitStatistic() async {
    final statistic = widget.statistic!.copyWith(
      selectedGroups: selectedGroups,
    );
    final db = Provider.of<AppDatabase>(context, listen: false);

    if (widget.statistic!.scopes.contains(StatisticScope.selectedGames)) {
      // Choose a game
      final games = await db.gameDao.getAllGames();
      if (mounted) {
        final createdStatistic = await Navigator.of(context).push<Statistic>(
          adaptivePageRoute(
            builder: (context) =>
                ChooseGameView(statistic: statistic, games: games),
          ),
        );
        if (!mounted) return;
        if (createdStatistic != null) {
          Navigator.of(context).pop(createdStatistic);
        }
      }
    } else {
      // Create statistic
      await db.statisticDao.addStatistic(statistic: statistic);
      if (!mounted) return;
      Navigator.of(context).pop(statistic);
    }
  }

  /// Filters the groups based on the search [query].
  void filterGroups(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGroups.clear();
        filteredGroups.addAll(widget.groups);
      } else {
        final List<({Group group, int score})> scoredGroups = [];

        for (final group in widget.groups) {
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
