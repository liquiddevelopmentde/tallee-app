import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_teams/edit_members_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result_view.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
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
  late List<Team> teams;
  late List<TextEditingController> nameController;

  final int initialTeamCount = 2;
  List<Player> get matchPlayers => widget.match.players;

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
    redistributePlayers();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(title: Text(loc.create_teams)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  return TeamCreationTile(
                    color: teams[index].color,
                    controller: nameController[index],
                    players: teams[index].members,
                    hintText: '${loc.team} ${index + 1}',
                    onEdit: () async {
                      final newPlayers = await Navigator.push(
                        context,
                        adaptivePageRoute(
                          fullscreenDialog: true,
                          builder: (context) => EditMembersView(
                            matchPlayer: widget.match.players,
                            teamMember: teams[index].members,
                          ),
                        ),
                      );

                      setState(() {
                        // Remove the selected players from every team
                        for (final player in newPlayers) {
                          for (final team in teams) {
                            if (team.members.contains(player)) {
                              team.members.remove(player);
                            }
                          }
                        }

                        // Add the selected players to the current team
                        teams[index] = teams[index].copyWith(
                          members: newPlayers,
                        );
                      });
                    },
                    onDelete: teams.length >= 3
                        ? () => _removeTeam(index)
                        : null,
                    onColorSelection: (color) {
                      setState(() {
                        teams[index] = teams[index].copyWith(color: color);
                      });
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MainMenuButton(
                  icon: Icons.cached,
                  text: loc.redistribute,
                  onPressed: () => setState(() {
                    redistributePlayers();
                  }),
                ),
                const SizedBox(width: 15),
                MainMenuButton(
                  icon: Icons.add,
                  onPressed: teams.length >= widget.match.players.length
                      ? null
                      : addTeam,
                ),
                const SizedBox(width: 15),
                MainMenuButton(
                  icon: Icons.check,
                  onPressed: teams.every((team) => team.members.isNotEmpty)
                      ? () async {
                          final match = await createMatchWithTeams();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              adaptivePageRoute(
                                fullscreenDialog: true,
                                builder: (context) => MatchResultView(
                                  match: match,
                                  onWinnerChanged: widget.onWinnerChanged,
                                ),
                              ),
                              (route) => route.isFirst,
                            );
                          }
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Adds a new team to the list of teams, creates a corresponding controller,
  /// and redistributes the players among all teams.
  void addTeam() {
    setState(() {
      final newTeam = getNewTeam();
      teams.add(newTeam);
      nameController.add(getNewController(newTeam));
      redistributePlayers();
    });
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

  /// Removes the team with the given index and redistributes its players to the
  /// remaining teams. If there are less than 2 teams the removed team gets
  /// replaced with a new one
  void _removeTeam(int index) {
    final loc = AppLocalizations.of(context);

    setState(() {
      final removedTeam = teams.removeAt(index);
      final removedController = nameController.removeAt(index);
      removedController.dispose();
      if (teams.length < 2) {
        final fallbackTeam = getNewTeam();
        teams.add(fallbackTeam);
        nameController.add(getNewController(fallbackTeam));
      }

      // Update index-based team names
      for (int i = 0; i < nameController.length; i++) {
        if (nameController[i].text.contains(
          RegExp('^${RegExp.escape(loc.team)} \\d+\$'),
        )) {
          nameController[i].text = '${loc.team} ${i + 1}';
        }
      }

      addToSmallestTeams(removedTeam.members);
    });
  }

  /// Adds the given players to the teams with the least amount of members
  /// [orphanedPlayers] The players to be added to the teams.
  void addToSmallestTeams(List<Player> orphanedPlayers) {
    if (teams.isEmpty || orphanedPlayers.isEmpty) return;

    for (final player in orphanedPlayers) {
      var targetIndex = 0;
      for (var i = 1; i < teams.length; i++) {
        if (teams[i].members.length < teams[targetIndex].members.length) {
          targetIndex = i;
        }
      }
      teams[targetIndex].members.add(player);
    }
  }

  // Iterates through all teams and redistributes players randomly and
  // as evenly as possible.
  void redistributePlayers() {
    for (final team in teams) {
      team.members.clear();
    }

    if (matchPlayers.isEmpty || teams.isEmpty) {
      return;
    }

    final shuffledPlayers = [...matchPlayers]..shuffle(random);

    for (int i = 0; i < shuffledPlayers.length; i++) {
      final teamIndex = i % teams.length;
      teams[teamIndex].members.add(shuffledPlayers[i]);
    }
  }

  /// Saves the teams to the database and returns the updated match with the teams.
  Future<Match> createMatchWithTeams() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final match = widget.match.copyWith(teams: teams);
    await db.matchDao.addMatch(match: match);
    return match;
  }

  @override
  void dispose() {
    for (final c in nameController) {
      c.dispose();
    }
    super.dispose();
  }
}
