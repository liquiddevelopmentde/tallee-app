import 'package:clock/clock.dart';
import 'package:uuid/uuid.dart';

class Player {
  final String id;
  final DateTime createdAt;
  final String name;
  final String description;
  final bool deleted;
  int nameCount;

  Player({
    required this.name,
    this.deleted = false,
    int? nameCount,
    String? id,
    DateTime? createdAt,
    String? description,
  }) : nameCount = nameCount ?? 0,
       id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       description = description ?? '';

  @override
  String toString() {
    return 'Player{id: $id, createdAt: $createdAt, name: $name, nameCount: $nameCount, description: $description, deleted: $deleted}';
  }

  Player copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? description,
    int? nameCount,
    bool? deleted,
  }) {
    return Player(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      nameCount: nameCount ?? this.nameCount,
      deleted: deleted ?? this.deleted,
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
          description == other.description &&
          deleted == other.deleted;

  @override
  int get hashCode =>
      Object.hash(id, createdAt, name, nameCount, description, deleted);

  Player.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      name = json['name'],
      description = json['description'],
      deleted = json['deleted'],
      nameCount = json['nameCount'] ?? 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'description': description,
    'deleted': deleted,
    'nameCount': nameCount,
  };

  Map<String, dynamic> toNormalizedJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'description': description,
    'deleted': deleted,
  };
}
