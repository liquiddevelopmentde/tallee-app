import 'package:clock/clock.dart';
import 'package:tallee/data/models/player.dart';
import 'package:uuid/uuid.dart';

class Team {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Player> members;

  Team({
    String? id,
    required this.name,
    DateTime? createdAt,
    required this.members,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now();

  @override
  String toString() {
    return 'Team{id: $id, name: $name, members: $members}';
  }

  /// Creates a Team instance from a JSON object (memberIds format).
  /// Player objects are reconstructed from memberIds by the DataTransferService.
  Team.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      createdAt = DateTime.parse(json['createdAt']),
      members = []; // Populated during import via DataTransferService

  /// Converts the Team instance to a JSON object using normalized format (memberIds only).
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'memberIds': members.map((member) => member.id).toList(),
  };
}
