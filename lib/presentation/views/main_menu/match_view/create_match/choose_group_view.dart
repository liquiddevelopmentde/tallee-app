import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_game_view.dart';
import 'package:tallee/presentation/widgets/buttons/animated_dialog_button.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/group_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class ChooseGroupView extends StatefulWidget {
  /// A view that allows the user to choose a group from a list of groups.
  /// - [groups]: A list of available groups to choose from
  /// - [initialGroup]: The initially selected group
  const ChooseGroupView({
    super.key,
    required this.groups,
    this.initialGroup,
    this.statistic,
  });

  /// A list of available groups to choose from
  final List<Group> groups;

  /// The ID of the initially selected group
  final Group? initialGroup;

  /// Optional statistic payload for choosing groups for a statistic
  final Statistic? statistic;

  @override
  State<ChooseGroupView> createState() => _ChooseGroupViewState();
}

class _ChooseGroupViewState extends State<ChooseGroupView> {
  final TextEditingController controller = TextEditingController();

  List<Group> selectedGroups = [];
  late final List<Group> filteredGroups;

  // If selecting multiple is possible
  bool enableMultiSelection = false;

  @override
  void initState() {
    filteredGroups = [...widget.groups];
    enableMultiSelection = widget.statistic != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: HapticIconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(
              context,
            ).pop(selectedGroups.isEmpty ? null : selectedGroups.first);
          },
        ),
        title: Text(loc.choose_group),
      ),
      body: PopScope(
        // This fixes that the Android Back Gesture didn't return the
        // selectedGroupId and therefore the selected Group wasn't saved
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          Navigator.of(
            context,
          ).pop(selectedGroups.isEmpty ? null : selectedGroups.first);
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
                    message: AppLocalizations.of(
                      context,
                    ).there_is_no_group_matching_your_search,
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
                      onTap: () {
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
                      },
                    );
                  },
                ),
              ),
            ),
            // Create statistic button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: AnimatedDialogButton(
                buttonConstraints: const BoxConstraints(minWidth: 390),
                buttonText: loc.create_statistic,
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
        filteredGroups.clear();
        filteredGroups.addAll(
          widget.groups.where(
            (group) =>
                group.name.toLowerCase().contains(query.toLowerCase()) ||
                group.members.any(
                  (player) =>
                      player.name.toLowerCase().contains(query.toLowerCase()),
                ),
          ),
        );
      }
    });
  }
}
