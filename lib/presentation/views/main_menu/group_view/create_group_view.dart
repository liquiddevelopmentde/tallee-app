import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/player_selection.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';

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

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    if (widget.groupToEdit != null) {
      groupNameController.text = widget.groupToEdit!.name;
      groupDescriptionController.text = widget.groupToEdit!.description;
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
        backgroundColor: CustomTheme.backgroundColor,
        appBar: AppBar(title: Text(viewTitle)),
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: CustomTheme.standardMargin,
                child: TextInputField(
                  controller: groupNameController,
                  hintText: loc.group_name,
                  maxLength: Constants.MAX_GROUP_NAME_LENGTH,
                ),
              ),
              Container(
                margin: CustomTheme.standardMargin,
                child: TextInputField(
                  controller: groupDescriptionController,
                  hintText: loc.description,
                  maxLength: Constants.MAX_GROUP_DESCRIPTION_LENGTH,
                  minLines: 3,
                  maxLines: 3,
                  showCounterText: true,
                ),
              ),
              Expanded(
                child: PlayerSelection(
                  initialSelectedPlayers: initialSelectedPlayers,
                  onPlayerCreated: () => widget.onMembersChanged?.call(),
                  onChanged: (players, units) {
                    setState(() {
                      selectedPlayers = [...players];
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: BottomAnimatedButton(
                  sizeRelativeToWidth: 0.95,
                  buttonText: buttonText,
                  buttonType: ButtonType.primary,
                  onPressed:
                      (groupNameController.text.isEmpty ||
                          (selectedPlayers.length < 2))
                      ? null
                      : saveGroup,
                ),
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
      HapticFeedback.successNotification();
      widget.onMembersChanged?.call();
      if (mounted) {
        Navigator.pop(context, updatedGroup);
      }
    } else {
      if (mounted) {
        HapticFeedback.errorNotification();
      }
      showSnackbar(
        message: widget.groupToEdit == null
            ? loc.error_creating_group
            : loc.error_editing_group,
      );
    }
  }

  /// Handles creating a new group and returns whether the operation was successful.
  Future<bool> createGroup() async {
    final groupName = groupNameController.text.trim();
    final groupDescription = groupDescriptionController.text.trim();

    final success = await db.groupDao.addGroup(
      group: Group(
        name: groupName,
        description: groupDescription,
        members: selectedPlayers,
      ),
    );
    return success;
  }

  /// Handles editing an existing group and returns a tuple of
  /// (success, updatedGroup).
  Future<(bool, Group?)> editGroup() async {
    final groupName = groupNameController.text.trim();
    final groupDescription = groupDescriptionController.text.trim();

    Group? updatedGroup = Group(
      id: widget.groupToEdit!.id,
      name: groupName,
      description: groupDescription,
      members: selectedPlayers,
      createdAt: widget.groupToEdit!.createdAt,
    );

    bool successfullNameChange = true;
    bool successfullDescriptionChange = true;
    bool successfullMemberChange = true;

    if (widget.groupToEdit!.name != groupName) {
      successfullNameChange = await db.groupDao.updateGroupName(
        groupId: widget.groupToEdit!.id,
        name: groupName,
      );
    }

    if (widget.groupToEdit!.description != groupDescription) {
      successfullDescriptionChange = await db.groupDao.updateGroupDescription(
        groupId: widget.groupToEdit!.id,
        description: groupDescription,
      );
    }

    if (widget.groupToEdit!.members != selectedPlayers) {
      successfullMemberChange = await db.playerGroupDao.replaceGroupPlayers(
        groupId: widget.groupToEdit!.id,
        newPlayers: selectedPlayers,
      );
      await deleteObsoleteMatchGroupRelations();
      widget.onMembersChanged?.call();
    }

    final success =
        successfullNameChange &&
        successfullDescriptionChange &&
        successfullMemberChange;

    return (success, updatedGroup);
  }

  /// Removes the group association from matches that no longer belong to the edited group.
  ///
  /// After updating the group's members, matches that were previously linked to
  /// this group but don't have any of the newly selected players are considered
  /// obsolete. For each such match, the group association is removed by setting
  /// its [groupId] to null.
  Future<void> deleteObsoleteMatchGroupRelations() async {
    final groupMatches = await db.matchDao.getMatchesByGroup(
      groupId: widget.groupToEdit!.id,
    );

    final selectedPlayerIds = selectedPlayers.map((p) => p.id).toSet();
    final relationshipsToDelete = groupMatches.where((match) {
      return !match.players.any(
        (player) => selectedPlayerIds.contains(player.id),
      );
    }).toList();

    for (var match in relationshipsToDelete) {
      await db.matchDao.removeMatchGroup(matchId: match.id);
    }
  }

  /// Displays a snackbar with the given message and optional action.
  ///
  /// [message] The message to display in the snackbar.
  void showSnackbar({required String message}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(CustomSnackBar(message: message));
    }
  }
}
