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
  Map<String, List<ScoreEntry>> scores;
  Player? winner;

  Match({
    String? id,
    DateTime? createdAt,
    this.endedAt,
    required this.name,
    required this.game,
    this.group,
    this.players = const [],
    this.notes = '',
    Map<String, List<ScoreEntry>>? scores,
    this.winner,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       scores = scores ?? {for (var player in players) player.id: []};

  @override
  String toString() {
    return 'Match{id: $id, createdAt: $createdAt, endedAt: $endedAt, name: $name, game: $game, group: $group, players: $players, notes: $notes, scores: $scores, winner: $winner}';
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
      scores = json['scores'],
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
    'scores': scores.map(
      (playerId, scoreList) =>
          MapEntry(playerId, scoreList.map((score) => score.toJson()).toList()),
    ),
    'notes': notes,
  };
}
