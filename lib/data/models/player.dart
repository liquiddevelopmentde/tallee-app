import 'package:clock/clock.dart';
import 'package:uuid/uuid.dart';

class Player {
  final String id;
  final DateTime createdAt;
  final String name;
  int nameCount;
  final String description;

  Player({
    String? id,
    DateTime? createdAt,
    required this.name,
    this.nameCount = 0,
    String? description,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       description = description ?? '';

  @override
  String toString() {
    return 'Player{id: $id, createdAt: $createdAt, name: $name, nameCount: $nameCount, description: $description}';
  }

  Player copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    int? nameCount,
    String? description,
  }) {
    return Player(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      nameCount: nameCount ?? this.nameCount,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          createdAt == other.createdAt &&
          name == other.name &&
          nameCount == other.nameCount &&
          description == other.description;

  @override
  int get hashCode => Object.hash(id, createdAt, name, nameCount, description);

  Player.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      name = json['name'],
      nameCount = 0,
      description = json['description'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'description': description,
  };
}
