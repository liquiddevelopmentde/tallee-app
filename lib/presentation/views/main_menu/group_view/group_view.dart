import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/provider/group_search_provider.dart';
import 'package:tallee/presentation/views/main_menu/group_view/create_group_view.dart';
import 'package:tallee/presentation/views/main_menu/group_view/group_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
import 'package:tallee/presentation/widgets/text_input/custom_search_bar.dart';
import 'package:tallee/presentation/widgets/tiles/group_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class GroupView extends StatefulWidget {
  /// A view that displays a list of groups
  const GroupView({super.key});

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  late final AppDatabase db;

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
    Provider.of<GroupSearchProvider>(
      context,
      listen: false,
    ).addListener(_handleSearchToggle);
    loadGroups();
  }

  @override
  void dispose() {
    Provider.of<GroupSearchProvider>(
      context,
      listen: false,
    ).removeListener(_handleSearchToggle);
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
              if (searchProvider.isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomSearchBar(
                    controller: searchBarController,
                    hintText: '',
                    onChanged: (value) {
                      setState(() {
                        filterGroups(value);
                      });
                    },
                  ),
                ),
              const SizedBox(height: 10),
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
                        padding: const EdgeInsets.only(bottom: 85),
                        itemCount: filteredGroups.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == filteredGroups.length) {
                            return SizedBox(
                              height: MediaQuery.paddingOf(context).bottom - 20,
                            );
                          }
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
            child: MainMenuButton(
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
    final lowercaseQuery = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredGroups = [...groups];
      } else {
        filteredGroups.clear();
        filteredGroups.addAll(
          groups.where(
            (group) =>
                group.name.toLowerCase().contains(lowercaseQuery) ||
                group.members.any(
                  (player) =>
                      player.name.toLowerCase().contains(lowercaseQuery),
                ),
          ),
        );
      }
    });
  }

  void _handleSearchToggle() {
    final searchProvider = Provider.of<GroupSearchProvider>(
      context,
      listen: false,
    );
    if (!searchProvider.isSearching) {
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
