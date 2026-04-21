import 'package:clock/clock.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';
import 'package:uuid/uuid.dart';

class Match {
  final String id;
  final DateTime createdAt;
  final DateTime? endedAt;
  final String name;
  final Game game;
  final Group? group;
  final List<Player> players;
  final String notes;
  Map<String, ScoreEntry?> scores;

  Match({
    required this.name,
    required this.game,
    required this.players,
    this.endedAt,
    this.group,
    this.notes = '',
    String? id,
    DateTime? createdAt,
    Map<String, ScoreEntry?>? scores,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       scores = scores ?? {for (Player p in players) p.id: null};

  @override
  String toString() {
    return 'Match{id: $id, createdAt: $createdAt, endedAt: $endedAt, name: $name, game: $game, group: $group, players: $players, notes: $notes, scores: $scores, mvp: $mvp}';
  }

  /// Creates a Match instance from a JSON object where related objects are
  /// represented by their IDs. Therefore, the game, group, and players are not
  /// fully constructed here.
  Match.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      endedAt = json['endedAt'] != null
          ? DateTime.parse(json['endedAt'])
          : null,
      name = json['name'],
      game = Game(
        name: '',
        ruleset: Ruleset.singleWinner,
        description: '',
        color: GameColor.blue,
        icon: '',
      ),
      group = null,
      players = [],
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

  /// Converts the Match instance to a JSON object. Related objects are
  /// represented by their IDs, so the game, group, and players are not fully
  /// serialized here.
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'name': name,
    'gameId': game.id,
    'groupId': group?.id,
    'playerIds': players.map((player) => player.id).toList(),
    'scores': scores.map((key, value) => MapEntry(key, value?.toJson())),
    'notes': notes,
  };

  List<Player> get mvp {
    if (players.isEmpty || scores.isEmpty) return [];

    switch (game.ruleset) {
      case Ruleset.highestScore:
        return _getPlayersWithHighestScore();

      case Ruleset.lowestScore:
        return _getPlayersWithLowestScore();

      case Ruleset.singleWinner:
        return _getPlayersWithHighestScore().take(1).toList();

      case Ruleset.singleLoser:
        return _getPlayersWithLowestScore().take(1).toList();

      case Ruleset.multipleWinners:
        return [];
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
}
