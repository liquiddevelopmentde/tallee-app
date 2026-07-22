import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/single_group_selection_widget.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/group_tile.dart';

class AssociateGroupsView extends StatefulWidget {
  const AssociateGroupsView({
    required this.match,
    required this.associations,
    super.key,
  });

  final Match match;

  final Map<String, Player?> associations;

  @override
  State<AssociateGroupsView> createState() => _AssociateGroupsViewState();
}

class _AssociateGroupsViewState extends State<AssociateGroupsView> {
  Group? associatedGroup;

  @override
  void initState() {
    super.initState();
    _autoAssociateGroup();
  }

  Future<void> _autoAssociateGroup() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final allGroups = await db.groupDao.getAllGroups();

    if (!mounted) return;

    final importedGroup = widget.match.group;
    if (importedGroup != null) {
      final mappedLocalPlayerIds = importedGroup.members
          .map((m) => widget.associations[m.id]?.id)
          .whereType<String>()
          .toSet();

      if (mappedLocalPlayerIds.length != importedGroup.members.length) return;

      final match = allGroups.where((localGroup) {
        final localMemberIds = localGroup.members.map((m) => m.id).toSet();
        return localMemberIds.length == mappedLocalPlayerIds.length &&
            localMemberIds.containsAll(mappedLocalPlayerIds);
      }).firstOrNull;

      if (match != null) {
        setState(() {
          associatedGroup = match;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Associate Group')),
        body: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: CustomTheme.standardMargin,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: CustomTheme.standardBorderRadiusAll,
                ),
                child: Text(
                  associatedGroup != null
                      ? 'Group associated'
                      : 'New group will be created',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            GroupTile(group: widget.match.group!, playersClickable: false),
            const Icon(Icons.arrow_downward, size: 30),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              layoutBuilder:
                  (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: associatedGroup == null
                  ? Container(
                      key: const ValueKey('no_association'),
                      margin: CustomTheme.tileMargin,
                      height: 150,
                      decoration: CustomTheme.standardBoxDecoration.copyWith(
                        border: Border.all(
                          color: Colors.orange.withAlpha(150),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_add,
                              size: 35,
                              color: Colors.orange,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'No matching local group found.\nA new group will be created.',
                              style: TextStyle(
                                color: CustomTheme.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.visible,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : GroupTile(
                      key: ValueKey(associatedGroup!.id),
                      group: associatedGroup!,
                      onTap: _showGroupSelectionSheet,
                      borderColor: Colors.green.withAlpha(150),
                      playersClickable: false,
                    ),
            ),
            const Spacer(),
            BottomAnimatedButton(
              buttonText: 'Save match',
              sizeRelativeToWidth: 0.95,
              onPressed: _saveMatch,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMatch() async {
    return;
  }

  Future<void> _showGroupSelectionSheet() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final allGroups = await db.groupDao.getAllGroups();

    final importedGroup = widget.match.group!;
    final mappedLocalPlayerIds = importedGroup.members
        .map((m) => widget.associations[m.id]?.id)
        .whereType<String>()
        .toSet();

    final validGroups = allGroups.where((localGroup) {
      final localMemberIds = localGroup.members.map((m) => m.id).toSet();
      return localMemberIds.length == mappedLocalPlayerIds.length &&
          localMemberIds.containsAll(mappedLocalPlayerIds);
    }).toList();

    if (!mounted) return;

    final selected = await showModalBottomSheet<Group>(
      context: context,
      backgroundColor: CustomTheme.backgroundColor,
      builder: (context) {
        return SingleGroupSelectionWidget(
          onChanged: (group) async {
            await Future.delayed(const Duration(milliseconds: 400));
            if (!context.mounted) return;
            Navigator.of(context).pop(group);
          },
          onGroupCreated: () {
            _autoAssociateGroup();
          },
          availableGroups: validGroups,
          initialSelectedGroup: associatedGroup,
        );
      },
    );

    if (selected != null) {
      setState(() {
        associatedGroup = selected;
      });
    }
  }
}
