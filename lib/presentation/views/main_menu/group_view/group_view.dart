import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/group_view/create_group_view.dart';
import 'package:tallee/presentation/views/main_menu/group_view/group_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/empty_message.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/group_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';
import 'package:tallee/state/group_search_provider.dart';

class GroupView extends StatefulWidget {
  /// A view that displays a list of groups
  const GroupView({super.key});

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  late final AppDatabase db;
  late final GroupSearchProvider _searchProvider;

  /// Loaded groups from the database
  late List<Group> loadedGroups;

  /// Loading state
  bool isLoading = true;

  TextEditingController searchBarController = TextEditingController();

  List<Group> allGroups = List.filled(
    7,
    Group(
      name: 'Skeleton Group',
      description: '',
      members: List.filled(6, Player(name: 'Skeleton Player')),
    ),
  );

  late List<Group> displayedGroups = [...allGroups];

  @override
  void initState() {
    super.initState();
    db = context.read<AppDatabase>();
    _searchProvider = context.read<GroupSearchProvider>();
    _searchProvider.addListener(handleSearchToggle);
    loadGroups();
  }

  @override
  void dispose() {
    _searchProvider.removeListener(handleSearchToggle);
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final searchProvider = context.read<GroupSearchProvider>();

    // Reset filtered groups when search is disabled
    if (!searchProvider.isSearching) {
      displayedGroups = [...allGroups];
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomTheme.backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              // Searchbar
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );

                  return ClipRect(
                    child: SizeTransition(
                      sizeFactor: curvedAnimation,
                      alignment: Alignment.topCenter,
                      child: FadeTransition(
                        opacity: curvedAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                child: searchProvider.isSearching
                    ? Padding(
                        key: const ValueKey('group-searchbar-visible'),
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 10,
                        ),
                        child: CustomSearchBar(
                          controller: searchBarController,
                          hintText: '',
                          onChanged: (value) {
                            setState(() {
                              applySearch(value);
                            });
                          },
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('group-searchbar-hidden'),
                      ),
              ),

              // Content
              Expanded(
                child: AppSkeleton(
                  enabled: isLoading,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Groups
                      if (allGroups.isNotEmpty)
                        if (displayedGroups.isEmpty)
                          // No filtered groups
                          Expanded(
                            child: Center(
                              child: TopCenteredMessage(
                                icon: Icons.info,
                                title: loc.info,
                                message:
                                    loc.there_is_no_group_matching_your_search,
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              padding: CustomTheme.listViewPadding(context),
                              itemCount: displayedGroups.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GroupTile(
                                  onPlayerChanged: loadGroups,
                                  group: displayedGroups[index],
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      adaptivePageRoute(
                                        settings: const RouteSettings(
                                          name: RouteNames.groupDetailView,
                                        ),
                                        builder: (context) {
                                          return GroupDetailView(
                                            group: displayedGroups[index],
                                            callback: loadGroups,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          )
                      else if (!isLoading)
                        // No groups
                        EmptyMessage(
                          icon: GROUP_ICON,
                          title: loc.no_groups,
                          description: loc.no_groups_created_yet,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Outside the skeleton so it is not cross-faded on loading changes
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: FloatingAnimatedButton(
              text: loc.create_group,
              icon: Icons.add,
              onPressed: () async {
                await Navigator.push(
                  context,
                  adaptivePageRoute(
                    settings: const RouteSettings(
                      name: RouteNames.createGroupView,
                    ),
                    builder: (context) {
                      return CreateGroupView(onMembersChanged: loadGroups);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Filters the groups based on the search [query].
  void applySearch(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedGroups = [...allGroups];
      } else {
        final List<({Group group, int score})> scoredGroups = [];

        for (final group in allGroups) {
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
        displayedGroups = scoredGroups.map((e) => e.group).toList();
      }
    });
  }

  void handleSearchToggle() {
    if (!mounted) return;

    if (!_searchProvider.isSearching) {
      searchBarController.clear();
    }
  }

  void loadGroups() {
    //if (!mounted) return;
    setState(() => isLoading = true);

    Future.wait([
      db.groupDao.getAllGroups(),
      Future.delayed(MINIMUM_SKELETON_DURATION),
    ]).then((results) {
      if (!mounted) return;

      loadedGroups = results[0] as List<Group>;
      setState(() {
        allGroups = loadedGroups
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        displayedGroups = [...loadedGroups];
        isLoading = false;
      });
    });
  }
}
