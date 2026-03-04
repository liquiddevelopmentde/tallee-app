import 'package:clock/clock.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/dto/game.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/player.dart';
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
  Player? winner;

  Match({
    String? id,
    DateTime? createdAt,
    this.endedAt,
    required this.name,
    required this.game,
    this.group,
    this.players = const [],
    String? notes,
    this.winner,
  }) : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? clock.now(),
        notes = notes ?? '';

  @override
  String toString() {
    return 'Match{id: $id, name: $name, game: $game, group: $group, players: $players, notes: $notes, endedAt: $endedAt}';
  }

  /// Creates a Match instance from a JSON object (ID references format).
  /// Related objects are reconstructed from IDs by the DataTransferService.
  Match.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = DateTime.parse(json['createdAt']),
        endedAt = json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
        name = json['name'],
        game = Game(name: '', ruleset: Ruleset.singleWinner, description: '', color: GameColor.blue, icon: ''), // Populated during import via DataTransferService
        group = null, // Populated during import via DataTransferService
        players = [], // Populated during import via DataTransferService
        notes = json['notes'] ?? '';

  /// Converts the Match instance to a JSON object using normalized format (ID references only).
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'name': name,
    'gameId': game.id,
    'groupId': group?.id,
    'playerIds': players.map((player) => player.id).toList(),
    'notes': notes,
  };
}
