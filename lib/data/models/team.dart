import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/player.dart';
import 'package:uuid/uuid.dart';

class Team {
  final String id;
  final String name;
  final DateTime createdAt;
  final AppColor color;
  final int? score;
  final List<Player> members;

  Team({
    String? id,
    required this.name,
    DateTime? createdAt,
    this.color = AppColor.blue,
    this.score,
    required this.members,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now();

  @override
  String toString() {
    return 'Team{id: $id, name: $name, color: $color, score: $score, members: $members}';
  }

  Team copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    AppColor? color,
    int? score,
    List<Player>? members,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      score: score ?? this.score,
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
          color == other.color &&
          score == other.score &&
          const DeepCollectionEquality().equals(members, other.members);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAt,
    color,
    score,
    const DeepCollectionEquality().hash(members),
  );

  Team.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      createdAt = DateTime.parse(json['createdAt']),
      color = AppColor.values.byName(json['color'] ?? AppColor.blue.name),
      score = json['score'] ?? 0,
      members = []; // Populated during import via DataTransferService

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'color': color.name,
    'score': score,
    'memberIds': members.map((member) => member.id).toList(),
  };
}
