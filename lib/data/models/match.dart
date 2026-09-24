import 'dart:math';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:tallee/core/constants/constants.dart';
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
  final Map<String, List<ScoreEntry>> scoresByRound;

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
    Map<String, List<ScoreEntry>>? scoresByRound,
    @Deprecated('Use scoresByRound instead') Map<String, ScoreEntry?>? scores,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       scoresByRound =
           scoresByRound ??
           (scores?.map(
                 (k, v) => MapEntry(k, v != null ? [v] : <ScoreEntry>[]),
               ) ??
               {});

  @Deprecated('Use totalScore(playerId) instead')
  Map<String, ScoreEntry?> get scores => {
    for (final e in scoresByRound.entries) e.key: e.value.lastOrNull,
  };

  int totalScore(String playerId) {
    final entries = scoresByRound[playerId];
    if (entries == null || entries.isEmpty) return 0;
    return entries.fold<int>(0, (sum, entry) => sum + entry.change);
  }

  int? _scoreForPlayer(String playerId) {
    final entries = scoresByRound[playerId];
    if (entries == null || entries.isEmpty) return null;
    return entries.fold<int>(0, (sum, entry) => sum + entry.change);
  }

  int get roundCount {
    if (scoresByRound.isEmpty) return 0;
    final allRounds = scoresByRound.values
        .expand((entries) => entries)
        .map((e) => e.roundNumber);
    if (allRounds.isEmpty) return 0;
    return allRounds.toSet().length;
  }

  int get currentRound {
    if (scoresByRound.isEmpty) return 0;
    final allRounds = scoresByRound.values
        .expand((entries) => entries)
        .map((e) => e.roundNumber);
    if (allRounds.isEmpty) return 0;
    return allRounds.reduce(max) + 1;
  }

  @override
  String toString() {
    return 'Match{id: $id, createdAt: $createdAt, endedAt: $endedAt, name: $name, game: $game, group: $group, players: $players, isTeamMatch: $isTeamMatch, teams: $teams, notes: $notes, scoresByRound: $scoresByRound, mvp: $mvp}';
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
    Map<String, List<ScoreEntry>>? scoresByRound,
    @Deprecated('Use scoresByRound instead') Map<String, ScoreEntry?>? scores,
  }) {
    final resolvedScoresByRound =
        scoresByRound ??
        (scores?.map((k, v) => MapEntry(k, v != null ? [v] : <ScoreEntry>[])) ??
            this.scoresByRound);

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
      scoresByRound: resolvedScoresByRound,
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
          const DeepCollectionEquality().equals(
            scoresByRound,
            other.scoresByRound,
          );

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
    const DeepCollectionEquality().hash(scoresByRound),
  );

  Match.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      endedAt = json['endedAt'] != null
          ? DateTime.parse(json['endedAt'])
          : null,
      name = json['name'],
      game = Game.fromJson(json['game'] as Map<String, dynamic>),
      group = json['group'] != null
          ? Group.fromJson(json['group'] as Map<String, dynamic>)
          : null,
      players = (json['players'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      isTeamMatch = json['isTeamMatch'],
      teams = json['teams'] != null
          ? (json['teams'] as List<dynamic>)
                .map((e) => Team.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      scoresByRound = json['scores'] != null
          ? (json['scores'] as Map<String, dynamic>).map((key, value) {
              if (value == null) {
                return MapEntry(key, <ScoreEntry>[]);
              }
              if (value is List) {
                return MapEntry(
                  key,
                  value
                      .map(
                        (e) => ScoreEntry.fromJson(e as Map<String, dynamic>),
                      )
                      .toList(),
                );
              }
              return MapEntry(key, [
                ScoreEntry.fromJson(value as Map<String, dynamic>),
              ]);
            })
          : {},
      notes = json['notes'] ?? '';

  Map<String, dynamic> toJson() => {
    'version': MATCH_DATA_SCHEMA_VERSION,
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'name': name,
    'game': game.toJson(),
    'group': group?.toJson(),
    'players': players.map((player) => player.toJson()).toList(),
    'isTeamMatch': isTeamMatch,
    'teams': teams?.map((team) => team.toJson()).toList(),
    'scores': scores.map((key, value) => MapEntry(key, value?.toJson())),
    'notes': notes,
  };

  Map<String, dynamic> toNormalizedJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'name': name,
    'gameId': game.id,
    'groupId': group?.id,
    'playerIds': players.map((player) => player.id).toList(),
    'isTeamMatch': isTeamMatch,
    'teams': teams?.map((team) => team.toNormalizedJson()).toList(),
    'scores': scores.map((key, value) => MapEntry(key, value?.toJson())),
    'notes': notes,
  };

  factory Match.fromNormalizedJson(
    Map<String, dynamic> json, {
    required Game game,
    Group? group,
    required List<Player> players,
    List<Team>? teams,
  }) {
    return Match(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      name: json['name'],
      game: game,
      group: group,
      players: players,
      isTeamMatch: json['isTeamMatch'],
      teams: teams,
      scoresByRound: json['scores'] != null
          ? (json['scores'] as Map<String, dynamic>).map((key, value) {
              if (value == null) {
                return MapEntry(key, <ScoreEntry>[]);
              }
              if (value is List) {
                return MapEntry(
                  key,
                  value
                      .map(
                        (e) => ScoreEntry.fromJson(e as Map<String, dynamic>),
                      )
                      .toList(),
                );
              }
              return MapEntry(key, [
                ScoreEntry.fromJson(value as Map<String, dynamic>),
              ]);
            })
          : {},
      notes: json['notes'] ?? '',
    );
  }

  bool get useTeamLogic => isTeamMatch || (teams?.isNotEmpty ?? false);

  // Most Valuable Player(s) based on the match's ruleset
  List<Player> get mvp {
    if (players.isEmpty ||
        scoresByRound.values.every((entries) => entries.isEmpty)) {
      return [];
    }

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
    if (players.isEmpty ||
        scoresByRound.values.every((entries) => entries.isEmpty)) {
      return [];
    }

    final scoresList = players
        .map((player) => _scoreForPlayer(player.id))
        .whereType<int>()
        .toList();

    if (scoresList.isEmpty) return [];

    final int highestScore = scoresList.reduce(
      (max, score) => score > max ? score : max,
    );

    return players.where((player) {
      final s = _scoreForPlayer(player.id);
      if (s == null) return false;
      return s == highestScore;
    }).toList();
  }

  List<Player> _getPlayersWithLowestScore() {
    if (players.isEmpty ||
        scoresByRound.values.every((entries) => entries.isEmpty)) {
      return [];
    }

    final scoresList = players
        .map((player) => _scoreForPlayer(player.id))
        .whereType<int>()
        .toList();

    if (scoresList.isEmpty) return [];

    final int lowestScore = scoresList.reduce(
      (min, score) => score < min ? score : min,
    );

    return players.where((player) {
      final s = _scoreForPlayer(player.id);
      if (s == null) return false;
      return s == lowestScore;
    }).toList();
  }

  List<Player> _getPlayersWithLivesRemaining() {
    if (players.isEmpty ||
        scoresByRound.values.every((entries) => entries.isEmpty)) {
      return [];
    }

    return players.where((player) {
      final entries = scoresByRound[player.id];
      if (entries == null || entries.isEmpty) return false;
      return entries.last.score > 0;
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
