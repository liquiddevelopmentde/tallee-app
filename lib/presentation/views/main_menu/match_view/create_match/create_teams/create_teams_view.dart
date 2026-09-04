import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_teams/manage_members_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/tiles/team_creation_tile.dart';

class CreateTeamsView extends StatefulWidget {
  const CreateTeamsView({
    super.key,
    required this.match,
    this.previousMatch,
    this.onWinnerChanged,
  });

  final Match match;
  final Match? previousMatch;
  final VoidCallback? onWinnerChanged;

  @override
  State<CreateTeamsView> createState() => _CreateTeamsViewState();
}

class _CreateTeamsViewState extends State<CreateTeamsView> {
  final Random random = Random();

  List<Player> get matchPlayers => widget.match.players;

  List<Player> get prefillMatchPlayers => widget.previousMatch?.players ?? [];

  List<Team> get prefillMatchTeams => widget.previousMatch?.teams ?? [];

  List<Team> teams = [];
  List<TextEditingController> nameController = [];
  final int initialTeamCount = 2;

  List<FocusNode> focusNodes = [];
  bool didInitTeams = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (didInitTeams &&
        focusNodes.length == teams.length &&
        nameController.length == teams.length) {
      return;
    }

    didInitTeams = true;

    final loc = AppLocalizations.of(context);

    final bool areTeamsLogicallyPossible =
        prefillMatchPlayers.length >= prefillMatchTeams.length;

    if (areTeamsLogicallyPossible &&
        widget.previousMatch?.teams != null &&
        widget.previousMatch!.teams!.isNotEmpty) {
      final matchPlayerIds = matchPlayers.map((p) => p.id).toSet();

      // Use prefilled teams, exclude players that are not in the matches players anymore
      teams = widget.previousMatch!.teams!.map((team) {
        return team.copyWith(
          members: team.members
              .where((member) => matchPlayerIds.contains(member.id))
              .toList(),
        );
      }).toList();
    } else {
      // Init the teams/reset teams
      teams = List.generate(
        initialTeamCount,
        (index) => Team(
          name: '${loc.team} ${index + 1}',
          color: getTeamColor(index),
          members: [],
        ),
      );
    }

    if (focusNodes.length != teams.length) {
      for (final focusNode in focusNodes) {
        focusNode.dispose();
      }
      focusNodes = List.generate(teams.length, (index) => FocusNode());
    }

    // Init the controllers
    if (nameController.length != teams.length) {
      for (final controller in nameController) {
        controller.dispose();
      }
      nameController = teams.map(getNewController).toList();
    }
  }

  @override
  void dispose() {
    for (final c in nameController) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(loc.create_teams)),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 105),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                return TeamCreationTile(
                  color: teams[index].color,
                  controller: nameController[index],
                  hintText: '${loc.team} ${index + 1}',
                  onDelete: teams.length <= 2 ? null : () => removeTeam(index),
                  onColorSelection: (color) {
                    setState(() {
                      teams[index] = teams[index].copyWith(color: color);
                    });
                  },
                  focusNode: focusNodes[index],
                  textInputAction: index == teams.length - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onSubmitted: (_) => focusNextTile(index),
                );
              },
            ),
          ),

          // Button row
          Positioned(
            bottom: MediaQuery.viewPaddingOf(context).bottom + 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add new team
                FloatingAnimatedButton(
                  icon: Icons.add,
                  text: loc.add_team,
                  onPressed: teams.length >= widget.match.players.length
                      ? null
                      : addTeam,
                ),
                const SizedBox(width: 15),

                // Confirm teams
                FloatingAnimatedButton(
                  icon: Icons.arrow_forward_sharp,
                  onPressed: teams.length >= 2
                      ? () {
                          if (widget.previousMatch != null) finalizeTeams();
                          final match = widget.match.copyWith(teams: teams);
                          Navigator.push(
                            context,
                            adaptivePageRoute(
                              builder: (context) => ManageMembersView(
                                match: match,
                                onWinnerChanged: widget.onWinnerChanged,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Moves the keyboard focus to the next team tile. If the current tile is the
  /// last one, the focus is dropped and the keyboard is dismissed instead.
  void focusNextTile(int index) {
    if (index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus();
    }
  }

  /// Creates a new team with a default name and color based on the current number
  Team getNewTeam() {
    final loc = AppLocalizations.of(context);
    return Team(
      name: '${loc.team} ${teams.length + 1}',
      color: getTeamColor(teams.length),
      members: [],
    );
  }

  /// Builds a [TextEditingController] for the given team and sets up a listener
  /// to update the team's name whenever the text changes.
  TextEditingController getNewController(Team team) {
    final textController = TextEditingController(text: team.name);
    textController.addListener(() {
      final index = teams.indexWhere((t) => t.id == team.id);
      if (index == -1) return;
      teams[index] = teams[index].copyWith(name: textController.text);
    });
    return textController;
  }

  /// Adds a new team to the list of teams, creates a corresponding controller,
  /// and redistributes the players among all teams.
  void addTeam() {
    setState(() {
      final newTeam = getNewTeam();
      teams.add(newTeam);
      nameController.add(getNewController(newTeam));
      focusNodes.add(FocusNode());
    });
  }

  /// Removes the team with the given index. If there are less than 2 teams the
  /// removed team gets replaced with a new one
  void removeTeam(int index) {
    final loc = AppLocalizations.of(context);

    setState(() {
      teams.removeAt(index);
      final removedController = nameController.removeAt(index);
      removedController.dispose();
      final removedFocusNode = focusNodes.removeAt(index);
      removedFocusNode.dispose();

      // Update index-based team names and default colors
      for (int i = 0; i < nameController.length; i++) {
        if (nameController[i].text.contains(
          RegExp('^${RegExp.escape(loc.team)} \\d+\$'),
        )) {
          nameController[i].text = '${loc.team} ${i + 1}';

          // Reset color to default if it was based on the index
          final previousIndex = i < index ? i : i + 1;
          if (teams[i].color == getTeamColor(previousIndex)) {
            teams[i] = teams[i].copyWith(color: getTeamColor(i));
          }
        }
      }
    });
  }

  /// Finalizes the team creation by assigning any players that are currently
  /// not part of a team to the available teams.
  ///
  /// If new teams have been created (those not present in [previousMatch]),
  /// the unassigned players are distributed among these new teams to fill them
  /// up evenly. If no new teams exist, players are distributed among all
  /// existing teams, maintaining a balanced member count across teams.
  void finalizeTeams() {
    final prefillTeamIds = prefillMatchTeams.map((t) => t.id).toSet();
    final allMatchPlayers = widget.match.players;
    final assignedPlayerIds = teams
        .expand((t) => t.members)
        .map((m) => m.id)
        .toSet();
    final unassignedPlayers = allMatchPlayers
        .where((p) => !assignedPlayerIds.contains(p.id))
        .toList();
    if (unassignedPlayers.isNotEmpty) {
      final newTeams = teams
          .where((t) => !prefillTeamIds.contains(t.id))
          .toList();

      if (newTeams.isNotEmpty) {
        for (final player in unassignedPlayers) {
          final targetTeam = newTeams.reduce(
            (a, b) => a.members.length <= b.members.length ? a : b,
          );
          final teamIndex = teams.indexWhere((t) => t.id == targetTeam.id);
          teams[teamIndex] = teams[teamIndex].copyWith(
            members: [...teams[teamIndex].members, player],
          );
        }
      } else {
        for (final player in unassignedPlayers) {
          final targetTeam = teams.reduce(
            (a, b) => a.members.length <= b.members.length ? a : b,
          );
          final teamIndex = teams.indexOf(targetTeam);
          teams[teamIndex] = teams[teamIndex].copyWith(
            members: [...teams[teamIndex].members, player],
          );
        }
      }
    }
  }
}
