import 'package:clock/clock.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:uuid/uuid.dart';

class Match {
  final String id;
  final DateTime createdAt;
  final String name;
  final List<Player>? players;
  final Group? group;
  Player? winner;

  Match({
    String? id,
    DateTime? createdAt,
    required this.name,
    this.players,
    this.group,
    this.winner,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now();

  @override
  String toString() {
    return 'Match{\n\tid: $id,\n\tname: $name,\n\tplayers: $players,\n\tgroup: $group,\n\twinner: $winner\n}';
  }

  /// Creates a Match instance from a JSON object.
  Match.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      createdAt = DateTime.parse(json['createdAt']),
      players = json['players'] != null
          ? (json['players'] as List)
                .map((playerJson) => Player.fromJson(playerJson))
                .toList()
          : null,
      group = json['group'] != null ? Group.fromJson(json['group']) : null,
      winner = json['winner'] != null ? Player.fromJson(json['winner']) : null;

  /// Converts the Match instance to a JSON object.
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'players': players?.map((player) => player.toJson()).toList(),
    'group': group?.toJson(),
    'winner': winner?.toJson(),
  };
}
