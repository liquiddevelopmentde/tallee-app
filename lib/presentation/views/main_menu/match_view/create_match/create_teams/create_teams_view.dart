import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/util/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_teams/manage_members_view.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/tiles/team_creation_tile.dart';

class CreateTeamsView extends StatefulWidget {
  const CreateTeamsView({super.key, required this.match, this.onWinnerChanged});

  final Match match;
  final VoidCallback? onWinnerChanged;

  @override
  State<CreateTeamsView> createState() => _CreateTeamsViewState();
}

class _CreateTeamsViewState extends State<CreateTeamsView> {
  final Random random = Random();
  List<Player> get matchPlayers => widget.match.players;

  late List<Team> teams;
  late List<TextEditingController> nameController;
  final int initialTeamCount = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context);

    // Init the teams
    teams = List.generate(
      initialTeamCount,
      (index) => Team(
        name: '${loc.team} ${index + 1}',
        color: getTeamColor(index),
        members: [],
      ),
    );

    // Init the controllers
    nameController = teams.map(getNewController).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(title: Text(loc.create_teams)),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 96),
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
                );
              },
            ),
          ),

          // Button row
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
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

  @override
  void dispose() {
    for (final c in nameController) {
      c.dispose();
    }
    super.dispose();
  }
}
