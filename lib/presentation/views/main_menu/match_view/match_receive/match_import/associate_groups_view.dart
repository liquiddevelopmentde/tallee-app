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
      final match = allGroups.where((localGroup) {
        return localGroup.name.toLowerCase() ==
            importedGroup.name.toLowerCase();
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
            const SizedBox(height: 20),
            GroupTile(group: widget.match.group!, playersClickable: false),
            const Icon(Icons.arrow_downward, size: 30),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              layoutBuilder:
                  (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[...previousChildren, ?currentChild],
                    );
                  },
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: associatedGroup == null
                  ? GestureDetector(
                      onTap: _showGroupSelectionSheet,
                      child: Container(
                        key: const ValueKey('tap_to_associate'),
                        margin: CustomTheme.tileMargin,
                        height: 150,
                        decoration: CustomTheme.standardBoxDecoration.copyWith(
                          border: Border.all(
                            color: Colors.red.withAlpha(150),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people, size: 35),
                              SizedBox(height: 5),
                              Text(
                                'Tap to associate a group.',
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
              onPressed: associatedGroup != null ? _saveMatch : null,
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
