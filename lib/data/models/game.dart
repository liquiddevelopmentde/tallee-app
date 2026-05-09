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

  Game copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    Ruleset? ruleset,
    String? description,
    GameColor? color,
    String? icon,
  }) {
    return Game(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      ruleset: ruleset ?? this.ruleset,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Game &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          createdAt == other.createdAt &&
          name == other.name &&
          ruleset == other.ruleset &&
          description == other.description &&
          color == other.color &&
          icon == other.icon;

  @override
  int get hashCode =>
      Object.hash(id, createdAt, name, ruleset, description, color, icon);

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
