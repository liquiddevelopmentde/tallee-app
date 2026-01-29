import 'package:clock/clock.dart';
import 'package:game_tracker/data/dto/player.dart';
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
    required this.description,
    required this.members,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now();

  @override
  String toString() {
    return 'Group{id: $id, name: $name, description: $description, members: $members}';
  }

  /// Creates a Group instance from a JSON object (memberIds format).
  /// Player objects are reconstructed from memberIds by the DataTransferService.
  Group.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      name = json['name'],
      description = json['description'],
      members = []; // Populated during import via DataTransferService

  /// Converts the Group instance to a JSON object using normalized format (memberIds only).
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'description': description,
    'memberIds': members.map((member) => member.id).toList(),
  };
}
