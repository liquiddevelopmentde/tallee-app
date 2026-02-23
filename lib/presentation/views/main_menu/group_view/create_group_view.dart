import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/custom_width_button.dart';
import 'package:tallee/presentation/widgets/player_selection.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';

class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key, this.groupToEdit});

  /// The group to edit, if any
  final Group? groupToEdit;

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  late final AppDatabase db;

  /// GlobalKey for ScaffoldMessenger to show snackbars
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Controller for the group name input field
  final _groupNameController = TextEditingController();

  /// List of currently selected players
  List<Player> selectedPlayers = [];

  /// List of initially selected players (when editing a group)
  List<Player> initialSelectedPlayers = [];

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    if (widget.groupToEdit != null) {
      _groupNameController.text = widget.groupToEdit!.name;
      setState(() {
        initialSelectedPlayers = widget.groupToEdit!.members;
        selectedPlayers = widget.groupToEdit!.members;
      });
    }
    _groupNameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.groupToEdit == null ? loc.create_new_group : loc.edit_group,
          ),
          actions: widget.groupToEdit == null
              ? []
              : [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      if (widget.groupToEdit != null) {
                        showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(loc.delete_group),
                            content: Text(loc.this_cannot_be_undone),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(loc.cancel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(loc.delete),
                              ),
                            ],
                          ),
                        ).then((confirmed) async {
                          if (confirmed == true && context.mounted) {
                            bool success = await db.groupDao.deleteGroup(
                              groupId: widget.groupToEdit!.id,
                            );
                            if (!context.mounted) return;
                            if (success) {
                              Navigator.pop(context);
                            } else {
                              if (!mounted) return;
                              showSnackbar(message: loc.error_deleting_group);
                            }
                          }
                        });
                      }
                    },
                  ),
                ],
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: CustomTheme.standardMargin,
                child: TextInputField(
                  controller: _groupNameController,
                  hintText: loc.group_name,
                ),
              ),
              Expanded(
                child: PlayerSelection(
                  initialSelectedPlayers: initialSelectedPlayers,
                  onChanged: (value) {
                    setState(() {
                      selectedPlayers = [...value];
                    });
                  },
                ),
              ),
              CustomWidthButton(
                text: widget.groupToEdit == null
                    ? loc.create_group
                    : loc.edit_group,
                sizeRelativeToWidth: 0.95,
                buttonType: ButtonType.primary,
                onPressed:
                    (_groupNameController.text.isEmpty ||
                        (selectedPlayers.length < 2))
                    ? null
                    : () async {
                        late Group? updatedGroup;
                        late bool success;
                        if (widget.groupToEdit == null) {
                          success = await db.groupDao.addGroup(
                            group: Group(
                              name: _groupNameController.text.trim(),
                              members: selectedPlayers,
                            ),
                          );
                        } else {
                          updatedGroup = Group(
                            id: widget.groupToEdit!.id,
                            name: _groupNameController.text.trim(),
                            members: selectedPlayers,
                          );
                          //TODO: Implement group editing in database
                          /*
                          success = await db.groupDao.updateGroup(
                            group: updatedGroup,
                          );
                          */
                          success = true;
                        }
                        if (!context.mounted) return;
                        if (success) {
                          Navigator.pop(context, updatedGroup);
                        } else {
                          showSnackbar(
                            message: widget.groupToEdit == null
                                ? loc.error_creating_group
                                : loc.error_editing_group,
                          );
                        }
                      },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays a snackbar with the given message and optional action.
  ///
  /// [message] The message to display in the snackbar.
  void showSnackbar({required String message}) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: CustomTheme.boxColor,
        ),
      );
    }
  }
}
