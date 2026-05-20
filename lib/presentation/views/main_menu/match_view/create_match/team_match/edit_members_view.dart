import 'package:flutter/material.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/player_selection.dart';

class EditMembersView extends StatefulWidget {
  const EditMembersView({
    super.key,
    required this.matchPlayer,
    required this.teamMember,
  });

  final List<Player> matchPlayer;

  final List<Player> teamMember;

  @override
  State<EditMembersView> createState() => _EditMembersViewState();
}

class _EditMembersViewState extends State<EditMembersView> {
  List<Player> selectedPlayers = [];
  List<Player> matchPlayer = [];

  @override
  void initState() {
    selectedPlayers = [...widget.teamMember];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.edit_members),
        leading: HapticIconButton(
          onPressed: selectedPlayers.isNotEmpty
              ? () => Navigator.pop(context, selectedPlayers)
              : null,
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: PlayerSelection(
        initialSelectedPlayers: widget.teamMember,
        availablePlayers: widget.matchPlayer,
        onChanged: (List<Player> newSelectedPlayers) {
          setState(() {
            selectedPlayers = newSelectedPlayers;
          });
        },
      ),
    );
  }
}
