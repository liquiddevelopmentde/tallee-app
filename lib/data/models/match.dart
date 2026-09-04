import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';
import 'package:tallee/data/models/team.dart';
import 'package:uuid/uuid.dart';

export 'package:tallee/core/enums.dart';

class Match {
  final String id;
  final DateTime createdAt;
  final DateTime? endedAt;
  final String name;
  final Game game;
  final Group? group;
  final List<Player> players;
  final bool isTeamMatch;
  final List<Team>? teams;
  final String notes;
  final Map<String, ScoreEntry?> scores;

  Match({
    required this.name,
    required this.game,
    required this.players,
    this.endedAt,
    this.group,
    this.isTeamMatch = false,
    this.teams,
    this.notes = '',
    String? id,
    DateTime? createdAt,
    Map<String, ScoreEntry?>? scores,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       scores = scores ?? {for (Player p in players) p.id: null};

  @override
  String toString() {
    return 'Match{id: $id, createdAt: $createdAt, endedAt: $endedAt, name: $name, game: $game, group: $group, players: $players, isTeamMatch: $isTeamMatch, teams: $teams, notes: $notes, scores: $scores, mvp: $mvp}';
  }

  Match copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? endedAt,
    String? name,
    Game? game,
    Group? group,
    List<Player>? players,
    bool? isTeamMatch,
    List<Team>? teams,
    String? notes,
    Map<String, ScoreEntry?>? scores,
  }) {
    return Match(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      name: name ?? this.name,
      game: game ?? this.game,
      group: group ?? this.group,
      players: players ?? this.players,
      isTeamMatch: isTeamMatch ?? this.isTeamMatch,
      teams: teams ?? this.teams,
      notes: notes ?? this.notes,
      scores: scores ?? this.scores,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Match &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          createdAt == other.createdAt &&
          endedAt == other.endedAt &&
          name == other.name &&
          game == other.game &&
          group == other.group &&
          const DeepCollectionEquality().equals(players, other.players) &&
          isTeamMatch == other.isTeamMatch &&
          const DeepCollectionEquality().equals(teams, other.teams) &&
          notes == other.notes &&
          const DeepCollectionEquality().equals(scores, other.scores);

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    endedAt,
    name,
    game,
    group,
    const DeepCollectionEquality().hash(players),
    isTeamMatch,
    const DeepCollectionEquality().hash(teams),
    notes,
    const DeepCollectionEquality().hash(scores),
  );

  Match.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      endedAt = json['endedAt'] != null
          ? DateTime.parse(json['endedAt'])
          : null,
      name = json['name'],
      game = Game(
        name: '',
        ruleset: Ruleset.winner,
        description: '',
        color: AppColor.blue,
      ),
      group = null,
      players = [],
      isTeamMatch = json['isTeamMatch'],
      teams = [],
      scores = json['scores'] != null
          ? (json['scores'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                value != null
                    ? ScoreEntry.fromJson(value as Map<String, dynamic>)
                    : null,
              ),
            )
          : {},
      notes = json['notes'] ?? '';

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'name': name,
    'gameId': game.id,
    'groupId': group?.id,
    'playerIds': players.map((player) => player.id).toList(),
    'isTeamMatch': isTeamMatch,
    'teams': teams?.map((team) => team.toJson()).toList(),
    'scores': scores.map((key, value) => MapEntry(key, value?.toJson())),
    'notes': notes,
  };

  bool get useTeamLogic => isTeamMatch || (teams?.isNotEmpty ?? false);

  // Most Valuable Player(s) based on the match's ruleset
  List<Player> get mvp {
    if (players.isEmpty || scores.isEmpty) return [];

    switch (game.ruleset) {
      case Ruleset.highestScore:
        return _getPlayersWithHighestScore();

      case Ruleset.lowestScore:
        return _getPlayersWithLowestScore();

      case Ruleset.loser:
        return _getPlayersWithLowestScore().take(1).toList();

      case Ruleset.winner:
        return _getPlayersWithHighestScore().toList();

      case Ruleset.placement:
        return _getPlayersWithHighestScore().take(1).toList();

      case Ruleset.lives:
        return _getPlayersWithLivesRemaining();
    }
  }

  List<Player> _getPlayersWithHighestScore() {
    if (players.isEmpty || scores.values.every((score) => score == null)) {
      return [];
    }

    final int highestScore = players
        .map((player) => scores[player.id]?.score)
        .whereType<int>()
        .reduce((max, score) => score > max ? score : max);

    return players.where((player) {
      final playerScores = scores[player.id];
      if (playerScores == null) return false;
      return playerScores.score == highestScore;
    }).toList();
  }

  List<Player> _getPlayersWithLowestScore() {
    if (players.isEmpty || scores.values.every((score) => score == null)) {
      return [];
    }

    final int lowestScore = players
        .map((player) => scores[player.id]?.score)
        .whereType<int>()
        .reduce((min, score) => score < min ? score : min);

    return players.where((player) {
      final playerScore = scores[player.id];
      if (playerScore == null) return false;
      return playerScore.score == lowestScore;
    }).toList();
  }

  List<Player> _getPlayersWithLivesRemaining() {
    if (players.isEmpty || scores.values.every((score) => score == null)) {
      return [];
    }

    return players.where((player) {
      final playerScore = scores[player.id];
      if (playerScore == null) return false;
      return playerScore.score > 0;
    }).toList();
  }

  // MVP for team-based matches (Most Valuable Team)
  List<Team> get mvt {
    if (teams == null || teams!.isEmpty) return [];

    switch (game.ruleset) {
      case Ruleset.highestScore:
        return _getHighestScoreTeam();

      case Ruleset.lowestScore:
        return _getLowestScoreTeam();

      case Ruleset.loser:
        return _getLowestScoreTeam().take(1).toList();

      case Ruleset.winner:
        return _getHighestScoreTeam();

      case Ruleset.placement:
        return _getHighestScoreTeam().take(1).toList();

      case Ruleset.lives:
        return _getTeamsWithLivesRemaining();
    }
  }

  List<Team> _getHighestScoreTeam() {
    if (teams!.every((team) => team.score == null)) {
      return [];
    }

    final int highestScore = teams!
        .map((team) => team.score)
        .whereType<int>()
        .reduce((max, score) => score > max ? score : max);

    return teams!.where((team) {
      return team.score == highestScore;
    }).toList();
  }

  List<Team> _getLowestScoreTeam() {
    if (teams!.every((team) => team.score == null)) {
      return [];
    }

    final int lowestScore = teams!
        .map((team) => team.score)
        .whereType<int>()
        .reduce((min, score) => score < min ? score : min);

    return teams!.where((team) {
      return team.score == lowestScore;
    }).toList();
  }

  List<Team> _getTeamsWithLivesRemaining() {
    if (teams!.every((team) => team.score == null)) {
      return [];
    }

    return teams!.where((team) => (team.score ?? 0) > 0).toList();
  }
}
