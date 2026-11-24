import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';
import 'package:tallee/core/theme/app_spacing.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/colored_circle.dart';
import 'package:tallee/presentation/widgets/dialog/selection_sheet.dart';
import 'package:tallee/presentation/widgets/player_selection_widget.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';
import 'package:tallee/presentation/widgets/tiles/choose_tile.dart';

class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key, this.groupToEdit, this.onMembersChanged});

  /// The group to edit, if any
  final Group? groupToEdit;

  final VoidCallback? onMembersChanged;

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  late final AppDatabase db;

  /// GlobalKey for ScaffoldMessenger to show snackbars
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Controller for the group name input field
  final groupNameController = TextEditingController();

  /// Controller for the group description input field
  final groupDescriptionController = TextEditingController();

  /// List of currently selected players
  List<Player> selectedPlayers = [];

  /// List of initially selected players (when editing a group)
  List<Player> initialSelectedPlayers = [];

  AppColor? selectedColor;

  AppColor? lastSelectedColor;

  bool get canCreateGroup =>
      (groupNameController.text.trim().isNotEmpty ||
      (selectedPlayers.length >= 2));

  bool get isEditMode => widget.groupToEdit != null;

  bool get hasChangedName =>
      widget.groupToEdit!.name != groupNameController.text.trim();

  bool get hasChangedColor => widget.groupToEdit!.color != selectedColor;

  bool get hasChangedDescription =>
      widget.groupToEdit!.description != groupDescriptionController.text.trim();

  bool get hasChangedMembers {
    final group = widget.groupToEdit!;

    final oldIds = group.members.map((m) => m.id).toSet();
    final newIds = selectedPlayers.map((p) => p.id).toSet();

    return oldIds.length != newIds.length || !oldIds.containsAll(newIds);
  }

  bool get hasChangedGroup {
    if (hasChangedName) return true;
    if (hasChangedColor) return true;
    if (hasChangedDescription) return true;
    if (hasChangedMembers) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    db = context.read<AppDatabase>();

    if (isEditMode) {
      // Prefill values
      groupNameController.text = widget.groupToEdit!.name;
      groupDescriptionController.text = widget.groupToEdit!.description;
      selectedColor = widget.groupToEdit!.color;
      setState(() {
        initialSelectedPlayers = widget.groupToEdit!.members;
        selectedPlayers = widget.groupToEdit!.members;
      });
    }
    groupNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final viewTitle = widget.groupToEdit == null
        ? loc.create_new_group
        : loc.edit_group;

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: context.talleeColors.backgroundColor,
        appBar: AppBar(title: Text(viewTitle)),
        body: SafeArea(
          minimum: AppSpacing.pagePadding,
          maintainBottomViewPadding: true,
          child: Column(
            spacing: 10,
            children: [
              // Group name
              TextInputField(
                controller: groupNameController,
                hintText: loc.group_name,
                maxLength: MAX_GROUP_NAME_LENGTH,
              ),

              // Color selection
              ChooseTile(
                title: loc.color,
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    spacing: 10,
                    children: [
                      if (selectedColor == null) ...[
                        const ColoredCircle(isRandomColor: true),
                        Text(loc.random_color),
                      ] else ...[
                        ColoredCircle(color: selectedColor),
                        Text(selectedColor!.toLocalizedString(context)),
                      ],
                    ],
                  ),
                ),
                onPressed: () => showColorSheet(loc),
              ),

              // Group description
              TextInputField(
                controller: groupDescriptionController,
                hintText: loc.description,
                maxLength: MAX_GROUP_DESCRIPTION_LENGTH,
                minLines: 3,
                maxLines: 3,
                showCounterText: true,
              ),

              // Player selection
              Expanded(
                child: PlayerSelectionWidget.multiple(
                  pairingEnabled: false,
                  initialSelectedPlayers: initialSelectedPlayers,
                  onPlayerCreated: () => widget.onMembersChanged?.call(),
                  onMultipleChanged: (players, units) {
                    setState(() {
                      selectedPlayers = [...players];
                    });
                  },
                ),
              ),

              if (isEditMode)
                // Update group button
                BottomAnimatedButton(
                  text: loc.save_changes,
                  onPressed: hasChangedGroup ? saveGroup : null,
                )
              else
                // Create group button
                BottomAnimatedButton(
                  text: loc.create_group,
                  onPressed: canCreateGroup ? saveGroup : null,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Saves the group by creating a new one or updating the existing one,
  /// depending on whether the widget  is in edit mode.
  Future<bool> saveGroup() async {
    bool success;
    Group newGroup;

    final name = groupNameController.text.trim();
    final description = groupDescriptionController.text.trim();
    final AppColor? color = selectedColor;
    final AppColor randomColor = AppColor.randomColor(
      exclude: isEditMode ? [lastSelectedColor, widget.groupToEdit!.color] : [],
    );
    final members = selectedPlayers;

    if (isEditMode) {
      (newGroup: newGroup, success: success) = await handleGroupUpdate(
        newName: name,
        newDesc: description,
        newColor: color ?? randomColor,
        newMembers: members,
      );
    } else {
      newGroup = Group(
        name: name,
        members: members,
        color: color ?? randomColor,
        description: description,
      );
      success = await db.groupDao.addGroup(group: newGroup);
    }

    handleSaveNavigation(success, newGroup);
    return success;
  }

  /// Handles navigation after saving a group.
  ///
  /// If the saving was successfull, it triggers onGroupChanged an pops the game.
  /// If not, it shows a snackbar
  void handleSaveNavigation(bool success, Group newGroup) {
    if (success) {
      Haptics.successNotification();
      widget.onMembersChanged?.call();
      if (mounted) {
        Navigator.of(context).pop((updatedGroup: newGroup));
      }
    } else {
      Haptics.errorNotification();
      if (mounted) {
        final loc = AppLocalizations.of(context);
        scaffoldMessengerKey.showSnackBar(
          message: widget.groupToEdit == null
              ? loc.error_creating_group
              : loc.error_editing_group,
        );
      }
    }
  }

  /// Handles updating an existing group in the database.
  /// Returns the success of the database operations an the new group.
  Future<({bool success, Group newGroup})> handleGroupUpdate({
    required String newName,
    required String newDesc,
    required AppColor newColor,
    required List<Player> newMembers,
  }) async {
    final oldGroup = widget.groupToEdit!;
    var success = true;

    if (hasChangedName) {
      success &= await db.groupDao.updateGroupName(
        groupId: widget.groupToEdit!.id,
        name: newName,
      );
    }

    if (hasChangedDescription) {
      success &= await db.groupDao.updateGroupDescription(
        groupId: widget.groupToEdit!.id,
        description: newDesc,
      );
    }

    if (hasChangedColor) {
      success &= await db.groupDao.updateGroupColor(
        groupId: widget.groupToEdit!.id,
        color: newColor,
      );
    }

    if (hasChangedMembers) {
      success &= await db.playerGroupDao.replaceGroupPlayers(
        groupId: widget.groupToEdit!.id,
        newPlayers: selectedPlayers,
      );
      await deleteObsoleteMatchGroupRelations();
    }

    Group newGroup = await db.groupDao.getGroupById(groupId: oldGroup.id);
    return (success: success, newGroup: newGroup);
  }

  /// Removes the group association from matches that no longer belong to the edited group.
  ///
  /// After updating the group's members, matches that were previously linked to
  /// this group but don't have any of the newly selected players are considered
  /// obsolete. For each such match, the group association is removed by setting
  /// its `groupId` to null.
  Future<void> deleteObsoleteMatchGroupRelations() async {
    final groupMatches = await db.matchDao.getMatchesByGroup(
      groupId: widget.groupToEdit!.id,
    );

    final selectedPlayerIds = selectedPlayers.map((p) => p.id).toSet();
    final relationshipsToDelete = groupMatches
        .where(
          (match) => !match.players.any(
            (player) => selectedPlayerIds.contains(player.id),
          ),
        )
        .toList();

    for (final match in relationshipsToDelete) {
      await db.matchDao.removeMatchGroup(matchId: match.id);
    }
  }

  void showColorSheet(AppLocalizations loc) {
    SelectionSheet.show(
      context: context,
      builder: (BuildContext context) => SelectionSheet<AppColor?>(
        title: loc.color,
        description: loc.select_a_group_color_description,
        values: const [null, ...AppColor.values],
        selectedValue: selectedColor,
        leadingBuilder: (AppColor? color) => color == null
            ? const ColoredCircle(isRandomColor: true)
            : ColoredCircle(color: color),
        labelBuilder: (BuildContext context, AppColor? color) =>
            color == null ? loc.random_color : color.toLocalizedString(context),
        onValueUpdated: (AppColor? color) {
          if (color == selectedColor) return;
          setState(() {
            lastSelectedColor = selectedColor;
            selectedColor = color;
          });
        },
      ),
    );
  }
}
