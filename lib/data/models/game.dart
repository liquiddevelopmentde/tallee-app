import 'package:clock/clock.dart';
import 'package:tallee/core/enums.dart';
import 'package:uuid/uuid.dart';

class Game {
  final String id;
  final DateTime createdAt;
  final String name;
  final Ruleset ruleset;
  final String description;
  final GameColor color;
  final String icon;

  Game({
    required this.name,
    required this.ruleset,
    this.color = GameColor.orange,
    this.description = '',
    this.icon = '',
    String? id,
    DateTime? createdAt,
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
      ruleset = Ruleset.values.firstWhere(
        (e) => e.name == json['ruleset'],
        orElse: () => Ruleset.singleWinner,
      ),
      description = json['description'],
      color = GameColor.values.firstWhere((e) => e.name == json['color']),
      icon = json['icon'];

  /// Converts the Game instance to a JSON object.
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'ruleset': ruleset.name,
    'description': description,
    'color': color.name,
    'icon': icon,
  };
}
