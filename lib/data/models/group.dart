import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:tallee/data/models/player.dart';
import 'package:uuid/uuid.dart';

class Group {
  final String id;
  final DateTime createdAt;
  final String name;
  final List<Player> members;
  final String description;

  Group({
    required this.name,
    required this.members,
    String? id,
    DateTime? createdAt,
    String? description,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       description = description ?? '';

  @override
  String toString() {
    return 'Group{id: $id, name: $name, description: $description, members: $members}';
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    List<Player>? members,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          const DeepCollectionEquality().equals(members, other.members);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    createdAt,
    const DeepCollectionEquality().hash(members),
  );

  /// Creates a Group instance from a JSON object where the related [Player]
  /// objects are represented by their full nested objects.
  Group.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      name = json['name'],
      description = json['description'] ?? '',
      members =
          (json['members'] as List<dynamic>?)
              ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

  /// Converts the Group instance to a JSON object with full nested objects.
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'description': description,
    'members': members.map((member) => member.toJson()).toList(),
  };

  /// Converts the Group instance to a JSON object using only IDs for members.
  Map<String, dynamic> toNormalizedJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'description': description,
    'memberIds': members.map((member) => member.id).toList(),
  };

  /// Creates a Group instance from a normalized JSON object and a list of members.
  factory Group.fromNormalizedJson(
    Map<String, dynamic> json,
    List<Player> members,
  ) {
    return Group(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      name: json['name'],
      description: json['description'] ?? '',
      members: members,
    );
  }
}
