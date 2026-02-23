import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/group_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class ChooseGroupView extends StatefulWidget {
  /// A view that allows the user to choose a group from a list of groups.
  /// - [groups]: A list of available groups to choose from
  /// - [initialGroupId]: The ID of the initially selected group
  const ChooseGroupView({
    super.key,
    required this.groups,
    required this.initialGroupId,
  });

  /// A list of available groups to choose from
  final List<Group> groups;

  /// The ID of the initially selected group
  final String initialGroupId;

  @override
  State<ChooseGroupView> createState() => _ChooseGroupViewState();
}

class _ChooseGroupViewState extends State<ChooseGroupView> {
  late String selectedGroupId;
  final TextEditingController controller = TextEditingController();
  late final List<Group> filteredGroups;

  @override
  void initState() {
    selectedGroupId = widget.initialGroupId;
    filteredGroups = [...widget.groups];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop(
              selectedGroupId == ''
                  ? null
                  : widget.groups.firstWhere(
                      (group) => group.id == selectedGroupId,
                    ),
            );
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
          Navigator.of(context).pop(
            selectedGroupId == ''
                ? null
                : widget.groups.firstWhere(
                    (group) => group.id == selectedGroupId,
                  ),
          );
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
                  padding: const EdgeInsets.only(bottom: 85),
                  itemCount: filteredGroups.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedGroupId != filteredGroups[index].id) {
                            selectedGroupId = filteredGroups[index].id;
                          } else {
                            selectedGroupId = '';
                          }
                        });
                      },
                      child: GroupTile(
                        group: filteredGroups[index],
                        isHighlighted:
                            selectedGroupId == filteredGroups[index].id,
                      ),
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
