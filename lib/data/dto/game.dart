import 'package:clock/clock.dart';
import 'package:uuid/uuid.dart';
import 'package:game_tracker/core/enums.dart';

class Game {
  final String id;
  final DateTime createdAt;
  final String name;
  final Ruleset ruleset;
  final String description;
  final String color;
  final String icon;

  Game({
    String? id,
    DateTime? createdAt,
    required this.name,
    required this.ruleset,
    required this.description,
    required this.color,
    required this.icon,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now();

  @override
  String toString() {
    return 'Game{id: $id, name: $name, ruleset: $ruleset, description: $description, color: $color, icon: $icon}';
  }

  /// Creates a Game instance from a JSON object.
  Game.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      name = json['name'],
      ruleset = Ruleset.values.firstWhere((e) => e.name == json['ruleset']),
      description = json['description'],
      color = json['color'],
      icon = json['icon'];

  /// Converts the Game instance to a JSON object.
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'ruleset': ruleset.name,
    'description': description,
    'color': color,
    'icon': icon,
  };
}

