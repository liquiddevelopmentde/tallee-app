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

  AppColor? selectedColor = AppColor.orange;

  AppColor? lastSelectedColor;

  @override
  void initState() {
    super.initState();
    db = context.read<AppDatabase>();

    if (widget.groupToEdit != null) {
      groupNameController.text = widget.groupToEdit!.name;
      groupDescriptionController.text = widget.groupToEdit!.description;
      selectedColor = widget.groupToEdit!.color;
      setState(() {
        initialSelectedPlayers = widget.groupToEdit!.members;
        selectedPlayers = widget.groupToEdit!.members;
      });
    }
    groupNameController.addListener(() {
      setState(() {});
    });
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
    final buttonText = widget.groupToEdit == null
        ? loc.create_group
        : loc.save_changes;

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

              BottomAnimatedButton(
                text: buttonText,
                onPressed:
                    (groupNameController.text.isEmpty ||
                        (selectedPlayers.length < 2))
                    ? null
                    : saveGroup,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Saves the group by creating a new one or updating the existing one,
  /// depending on whether the widget  is in edit mode.
  Future<void> saveGroup() async {
    final loc = AppLocalizations.of(context);
    late bool success;
    Group? updatedGroup;

    if (widget.groupToEdit == null) {
      success = await createGroup();
    } else {
      final result = await editGroup();
      success = result.$1;
      updatedGroup = result.$2;
    }

    if (!mounted) return;

    if (success) {
      Haptics.successNotification();
      widget.onMembersChanged?.call();
      if (mounted) {
        Navigator.of(context).pop((updatedGroup: updatedGroup));
      }
    } else {
      if (mounted) {
        Haptics.errorNotification();
      }
      scaffoldMessengerKey.showSnackBar(
        message: widget.groupToEdit == null
            ? loc.error_creating_group
            : loc.error_editing_group,
      );
    }
  }

  /// Handles creating a new group and returns whether the operation was successful.
  Future<bool> createGroup() async {
    final String groupName = groupNameController.text.trim();
    final String groupDescription = groupDescriptionController.text.trim();
    final AppColor? groupColor = selectedColor;

    final success = await db.groupDao.addGroup(
      group: Group(
        name: groupName,
        description: groupDescription,
        members: selectedPlayers,
        color: groupColor ?? AppColor.randomColor(exclude: [lastSelectedColor]),
      ),
    );
    return success;
  }

  /// Handles editing an existing group and returns a tuple of
  /// (success, updatedGroup).
  Future<(bool, Group?)> editGroup() async {
    final groupName = groupNameController.text.trim();
    final groupDescription = groupDescriptionController.text.trim();
    final AppColor? groupColor = selectedColor;
    final AppColor randomColor = AppColor.randomColor(
      exclude: [lastSelectedColor, widget.groupToEdit!.color],
    );

    Group? updatedGroup = Group(
      id: widget.groupToEdit!.id,
      name: groupName,
      description: groupDescription,
      members: selectedPlayers,
      createdAt: widget.groupToEdit!.createdAt,
      color: groupColor ?? randomColor,
    );

    bool success = true;

    if (widget.groupToEdit!.name != groupName) {
      success &= await db.groupDao.updateGroupName(
        groupId: widget.groupToEdit!.id,
        name: groupName,
      );
    }

    if (widget.groupToEdit!.description != groupDescription) {
      success &= await db.groupDao.updateGroupDescription(
        groupId: widget.groupToEdit!.id,
        description: groupDescription,
      );
    }

    if (widget.groupToEdit!.color != groupColor) {
      success &= await db.groupDao.updateGroupColor(
        groupId: widget.groupToEdit!.id,
        color: groupColor ?? randomColor,
      );
    }

    if (widget.groupToEdit!.members != selectedPlayers) {
      success &= await db.playerGroupDao.replaceGroupPlayers(
        groupId: widget.groupToEdit!.id,
        newPlayers: selectedPlayers,
      );
      await deleteObsoleteMatchGroupRelations();
      widget.onMembersChanged?.call();
    }

    return (success, updatedGroup);
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
