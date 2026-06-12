import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/group_view/create_group_view.dart';
import 'package:tallee/presentation/views/main_menu/group_view/group_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/group_tile.dart';
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

  List<Group> groups = List.filled(
    7,
    Group(
      name: 'Skeleton Group',
      description: '',
      members: List.filled(6, Player(name: 'Skeleton Player')),
    ),
  );

  late List<Group> filteredGroups = [...groups];

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _searchProvider = Provider.of<GroupSearchProvider>(context, listen: false);
    _searchProvider.addListener(_handleSearchToggle);
    loadGroups();
  }

  @override
  void dispose() {
    _searchProvider.removeListener(_handleSearchToggle);
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final searchProvider = Provider.of<GroupSearchProvider>(context);

    // Reset filtered groups when search is disabled
    if (!searchProvider.isSearching) {
      filteredGroups = [...groups];
    }

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
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
                              filterGroups(value);
                            });
                          },
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('group-searchbar-hidden'),
                      ),
              ),
              Expanded(
                child: AppSkeleton(
                  enabled: isLoading,
                  child: Visibility(
                    visible: groups.isNotEmpty,
                    replacement: Center(
                      child: TopCenteredMessage(
                        icon: Icons.info,
                        title: loc.info,
                        message: loc.no_groups_created_yet,
                      ),
                    ),
                    child: Visibility(
                      visible: filteredGroups.isNotEmpty,
                      replacement: Center(
                        child: TopCenteredMessage(
                          icon: Icons.info,
                          title: loc.info,
                          message: loc.there_is_no_group_matching_your_search,
                        ),
                      ),
                      child: ListView.builder(
                        padding: CustomTheme.listViewPadding(context),
                        itemCount: filteredGroups.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GroupTile(
                            onPlayerChanged: loadGroups,
                            group: filteredGroups[index],
                            onTap: () async {
                              await Navigator.push(
                                context,
                                adaptivePageRoute(
                                  builder: (context) {
                                    return GroupDetailView(
                                      group: filteredGroups[index],
                                      callback: loadGroups,
                                    );
                                  },
                                ),
                              );
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
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: FloatingAnimatedButton(
              text: loc.create_group,
              icon: Icons.group_add,
              onPressed: () async {
                await Navigator.push(
                  context,
                  adaptivePageRoute(
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
  void filterGroups(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGroups = [...groups];
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

          if (maxScore >= Constants.FUZZY_SEARCH_THRESHOLD) {
            scoredGroups.add((group: group, score: maxScore));
          }
        }

        // Sort by score descending
        scoredGroups.sort((a, b) => b.score.compareTo(a.score));
        filteredGroups = scoredGroups.map((e) => e.group).toList();
      }
    });
  }

  void _handleSearchToggle() {
    if (!mounted) {
      return;
    }

    if (!_searchProvider.isSearching) {
      searchBarController.clear();
    }
  }

  void loadGroups() {
    setState(() {
      isLoading = true;
    });
    Future.wait([
      db.groupDao.getAllGroups(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]).then((results) {
      loadedGroups = results[0] as List<Group>;
      setState(() {
        groups = loadedGroups
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        filteredGroups = [...loadedGroups];
      });
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }
}
