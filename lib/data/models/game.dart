import 'package:clock/clock.dart';
import 'package:tallee/core/enums.dart';
import 'package:uuid/uuid.dart';

class Game {
  final String id;
  final DateTime createdAt;
  final String name;
  final Ruleset ruleset;
  final AppColor color;
  final String description;

  Game({
    required this.name,
    required this.ruleset,
    this.color = AppColor.orange,
    this.description = '',
    String? id,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now();

  @override
  String toString() {
    return 'Game{id: $id, name: $name, ruleset: $ruleset, color: $color, description: $description}';
  }

  Game copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    Ruleset? ruleset,
    AppColor? color,
    String? description,
  }) {
    return Game(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      ruleset: ruleset ?? this.ruleset,
      color: color ?? this.color,
      description: description ?? this.description,
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
          color == other.color &&
          description == other.description;

  @override
  int get hashCode =>
      Object.hash(id, createdAt, name, ruleset, color, description);

  Game.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      name = json['name'],
      ruleset = Ruleset.values.firstWhere(
        (e) => e.name == json['ruleset'],
        orElse: () => Ruleset.winner,
      ),
      color = AppColor.values.firstWhere(
        (e) => e.name == json['color'],
        orElse: () => AppColor.orange,
      ),
      description = json['description'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'ruleset': ruleset.name,
    'color': color.name,
    'description': description,
  };
}
