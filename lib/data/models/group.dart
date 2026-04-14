import 'package:clock/clock.dart';
import 'package:tallee/data/models/player.dart';
import 'package:uuid/uuid.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<Player> members;

  Group({
    String? id,
    DateTime? createdAt,
    required this.name,
    String? description,
    required this.members,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       description = description ?? '';

  @override
  String toString() {
    return 'Group{id: $id, name: $name, description: $description, members: $members}';
  }

  /// Creates a Group instance from a JSON object where the related [Player]
  /// objects are represented by their IDs.
  Group.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      name = json['name'],
      description = json['description'],
      members = [];

  /// Converts the Group instance to a JSON object. Related [Player] objects are
  /// represented by their IDs.
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'description': description,
    'memberIds': members.map((member) => member.id).toList(),
  };
}
