import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
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

  Team copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<Player>? members,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          createdAt == other.createdAt &&
          const DeepCollectionEquality().equals(members, other.members);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAt,
    const DeepCollectionEquality().hash(members),
  );

  Team.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      createdAt = DateTime.parse(json['createdAt']),
      members = []; // Populated during import via DataTransferService

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'memberIds': members.map((member) => member.id).toList(),
  };
}
