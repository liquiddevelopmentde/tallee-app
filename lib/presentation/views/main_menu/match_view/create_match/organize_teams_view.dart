import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result_view.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
import 'package:tallee/presentation/widgets/tiles/team_creation_tile.dart';

class OrganizeTeamsView extends StatefulWidget {
  const OrganizeTeamsView({super.key, required this.match});

  final Match match;

  @override
  State<OrganizeTeamsView> createState() => _OrganizeTeamsViewState();
}

class _OrganizeTeamsViewState extends State<OrganizeTeamsView> {
  final Random _random = Random();
  late final List<_TeamDraft> _teams;

  List<Player> get _players => widget.match.players;

  @override
  void initState() {
    super.initState();
    _teams = List.generate(2, _createTeamDraft);
    _redistributePlayers();
  }

  @override
  void dispose() {
    for (final team in _teams) {
      team.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(title: const Text('Organize Teams')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemCount: _teams.length,
                itemBuilder: (context, index) {
                  return TeamCreationTile(
                    color: _teams[index].color,
                    controller: _teams[index].nameController,
                    players: _teams[index].members,
                    hintText: 'Team ${index + 1}',
                    onDelete: () => _removeTeam(index),
                    onColorSelection: (color) {
                      setState(() {
                        _teams[index].color = color;
                      });
                    },
                    onPlayerTap: (player) =>
                        _showMovePlayerSheet(player, index),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MainMenuButton(
                  icon: Icons.cached,
                  onPressed: () => setState(() {
                    _redistributePlayers();
                  }),
                ),
                const SizedBox(width: 15),
                MainMenuButton(
                  text: 'Add team',
                  icon: Icons.emoji_events,
                  onPressed: _teams.length >= widget.match.players.length
                      ? null
                      : _addTeam,
                ),
                const SizedBox(width: 15),
                MainMenuButton(
                  icon: Icons.check,
                  onPressed: () async {
                    final match = await createMatchWithTeams();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        adaptivePageRoute(
                          fullscreenDialog: true,
                          builder: (context) => MatchResultView(match: match),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Match> createMatchWithTeams() async {
    final teams = _teams
        .map(
          (team) => Team(
            name: team.nameController.text.trim().isNotEmpty
                ? team.nameController.text.trim()
                : 'Team ${_teams.indexOf(team) + 1}',
            color: team.color,
            members: team.members,
          ),
        )
        .toList();
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.teamDao.addTeamsAsList(teams: teams, matchId: widget.match.id);
    return widget.match.copyWith(teams: teams);
  }

  _TeamDraft _createTeamDraft(int index) {
    return _TeamDraft(
      nameController: TextEditingController(text: 'Team ${index + 1}'),
      color: getTeamColor(index),
    );
  }

  void _addTeam() {
    setState(() {
      _teams.add(_createTeamDraft(_teams.length));
      _redistributePlayers();
    });
  }

  void _removeTeam(int index) {
    setState(() {
      final removedTeam = _teams.removeAt(index);
      removedTeam.dispose();

      if (_teams.isEmpty) {
        _teams.add(_createTeamDraft(0));
      }

      _redistributePlayers();
    });
  }

  void _movePlayer(Player player, int fromTeamIndex, int toTeamIndex) {
    setState(() {
      _teams[fromTeamIndex].members.remove(player);
      _teams[toTeamIndex].members.add(player);
    });
  }

  void _showMovePlayerSheet(Player player, int fromTeamIndex) {
    final otherTeams = [
      for (int i = 0; i < _teams.length; i++)
        if (i != fromTeamIndex) (index: i, team: _teams[i]),
    ];

    if (otherTeams.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: CustomTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    '${player.name} verschieben in …',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.textColor,
                    ),
                  ),
                ),
                const Divider(),
                ...otherTeams.map((entry) {
                  final teamName =
                      entry.team.nameController.text.trim().isNotEmpty
                      ? entry.team.nameController.text.trim()
                      : 'Team ${entry.index + 1}';
                  final teamColor = getColorFromGameColor(entry.team.color);
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: teamColor,
                    ),
                    title: Text(
                      teamName,
                      style: const TextStyle(color: CustomTheme.textColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _movePlayer(player, fromTeamIndex, entry.index);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _redistributePlayers() {
    for (final team in _teams) {
      team.members.clear();
    }

    if (_players.isEmpty || _teams.isEmpty) {
      return;
    }

    final shuffledPlayers = [..._players]..shuffle(_random);

    for (int i = 0; i < shuffledPlayers.length; i++) {
      final teamIndex = i % _teams.length;
      _teams[teamIndex].members.add(shuffledPlayers[i]);
    }
  }
}

class _TeamDraft {
  _TeamDraft({required this.nameController, required this.color});

  final TextEditingController nameController;
  GameColor color;
  final List<Player> members = [];

  void dispose() {
    nameController.dispose();
  }
}
