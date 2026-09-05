import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/choose_group_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/tiles/object_tiles/group_tile.dart';
import 'package:tallee/services/remote_share_service.dart';
import 'package:tallee/state/data_refresh_provider.dart';

class AssociateGroupsView extends StatefulWidget {
  const AssociateGroupsView({
    required this.match,
    required this.associations,
    this.associatedGame,
    super.key,
  });

  final Match match;

  final Map<String, Player?> associations;

  final Game? associatedGame;

  @override
  State<AssociateGroupsView> createState() => _AssociateGroupsViewState();
}

class _AssociateGroupsViewState extends State<AssociateGroupsView> {
  Group? associatedGroup;

  @override
  void initState() {
    super.initState();
    autoAssociateGroup();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(loc.associate_group)),
        body: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: CustomTheme.standardMargin,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                  color: associatedGroup == null ? Colors.orange : Colors.green,
                  borderRadius: CustomTheme.standardBorderRadiusAll,
                ),
                child: Text(
                  associatedGroup != null
                      ? loc.group_associated
                      : loc.new_group_will_be_created,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                      onTap: navigateToGroupSelection,
                      child: Container(
                        key: const ValueKey('no_association'),
                        margin: CustomTheme.tileMargin,
                        height: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: CustomTheme.standardBoxDecoration.copyWith(
                          border: Border.all(
                            color: Colors.orange.withAlpha(150),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.group_add,
                                size: 35,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                loc.no_matching_local_group_found,
                                style: const TextStyle(
                                  color: CustomTheme.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.visible,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                loc.tap_to_choose_existing,
                                style: const TextStyle(
                                  color: CustomTheme.hintColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : GroupTile(
                      key: ValueKey(associatedGroup!.id),
                      group: associatedGroup!,
                      onTap: navigateToGroupSelection,
                      borderColor: Colors.green.withAlpha(150),
                      playersClickable: false,
                    ),
            ),
            const SizedBox(height: 2),
            if (associatedGroup != null)
              Text(
                loc.tap_to_choose_different_group,
                style: const TextStyle(
                  color: CustomTheme.hintColor,
                  fontSize: 14,
                  overflow: TextOverflow.visible,
                ),
                softWrap: true,
              ),
            const Spacer(),
            BottomAnimatedButton(
              buttonText: loc.save_match,
              sizeRelativeToWidth: 0.95,
              onPressed: saveMatch,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveMatch() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final loc = AppLocalizations.of(context);

    // Filter null values and cast to Map<String, Player>
    final playerAssociations = <String, Player>{};
    for (var entry in widget.associations.entries) {
      if (entry.value != null) {
        playerAssociations[entry.key] = entry.value!;
      }
    }

    try {
      await RemoteShareService().saveImportedMatch(
        db: db,
        importedMatch: widget.match,
        playerAssociations: playerAssociations,
        associatedGame: widget.associatedGame,
        associatedGroup: associatedGroup,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(CustomSnackBar(message: loc.unexpected_error));
      return;
    }

    if (!mounted) return;

    Provider.of<DataRefreshProvider>(context, listen: false).refresh();

    ScaffoldMessenger.of(context)
        .showSnackBar(CustomSnackBar(message: loc.data_successfully_imported));

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> navigateToGroupSelection() async {
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

    final selected = await Navigator.push<Group>(
      context,
      adaptivePageRoute(
        builder: (context) => ChooseGroupView(
          groups: validGroups,
          initialGroups: [?associatedGroup],
        ),
      ),
    );

    setState(() {
      associatedGroup = selected;
    });
  }

  Future<void> autoAssociateGroup() async {
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
}
