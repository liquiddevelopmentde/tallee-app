import 'package:clock/clock.dart';
import 'package:uuid/uuid.dart';

class Player {
  final String id;
  final DateTime createdAt;
  final String name;
  final int nameCount;
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
    return 'Player{id: $id, name: $name, description: $description}';
  }

  /// Creates a Player instance from a JSON object.
  Player.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      name = json['name'],
      nameCount = 0,
      description = json['description'];

  /// Converts the Player instance to a JSON object.
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'description': description,
  };
}
