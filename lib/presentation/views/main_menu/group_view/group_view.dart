import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/group_view/create_group_view.dart';
import 'package:tallee/presentation/views/main_menu/group_view/group_detail_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
import 'package:tallee/presentation/widgets/tiles/group_tile.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class GroupsView extends StatefulWidget {
  /// A view that displays a list of groups
  const GroupsView({super.key});

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  late final AppDatabase db;

  /// Loaded groups from the database
  late List<Group> loadedGroups;

  /// Loading state
  bool isLoading = true;

  List<Group> groups = List.filled(
    7,
    Group(
      name: 'Skeleton Group',
      description: '',
      members: List.filled(6, Player(name: 'Skeleton Player', description: '')),
    ),
  );

  @override
  void initState() {
    super.initState();

    db = Provider.of<AppDatabase>(context, listen: false);
    loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AppSkeleton(
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
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 85),
                itemCount: groups.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == groups.length) {
                    return SizedBox(
                      height: MediaQuery.paddingOf(context).bottom - 20,
                    );
                  }
                  return GroupTile(
                    group: groups[index],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        adaptivePageRoute(
                          builder: (context) {
                            return GroupDetailView(
                              group: groups[index],
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
                      return const CreateGroupView();
                    },
                  ),
                );
                setState(() {
                  loadGroups();
                });
              },
            ),
          ),
        ],
      ),
    );
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
      });
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }
}
