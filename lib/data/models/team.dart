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
  final DateTime? timerStartedAt;
  final List<Player> members;

  Team({
    String? id,
    required this.name,
    DateTime? createdAt,
    this.color = AppColor.blue,
    this.score,
    this.timerStartedAt,
    required this.members,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now();

  @override
  String toString() {
    return 'Team{id: $id, name: $name, color: $color, score: $score, timerStartedAt: $timerStartedAt, members: $members}';
  }

  Team copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    AppColor? color,
    int? score,
    DateTime? timerStartedAt,
    List<Player>? members,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      score: score ?? this.score,
      timerStartedAt: timerStartedAt ?? this.timerStartedAt,
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
          timerStartedAt == other.timerStartedAt &&
          const DeepCollectionEquality().equals(members, other.members);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAt,
    color,
    score,
    timerStartedAt,
    const DeepCollectionEquality().hash(members),
  );

  Team.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      createdAt = DateTime.parse(json['createdAt']),
      color = AppColor.values.firstWhere(
        (e) => e.name == json['color'],
        orElse: () => AppColor.orange,
      ),
      score = json['score'],
      timerStartedAt = json['timerStartedAt'] != null
          ? DateTime.parse(json['timerStartedAt'] as String)
          : null,
      members =
          (json['members'] as List<dynamic>?)
              ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'color': color.name,
    'score': score,
    'timerStartedAt': timerStartedAt?.toIso8601String(),
    'members': members.map((member) => member.toJson()).toList(),
  };

  Map<String, dynamic> toNormalizedJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'color': color.name,
    'score': score,
    'timerStartedAt': timerStartedAt?.toIso8601String(),
    'memberIds': members.map((member) => member.id).toList(),
  };

  factory Team.fromNormalizedJson(
    Map<String, dynamic> json,
    List<Player> members,
  ) {
    return Team(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      color: AppColor.values.firstWhere(
        (e) => e.name == json['color'],
        orElse: () => AppColor.orange,
      ),
      score: json['score'],
      timerStartedAt: json['timerStartedAt'] != null
          ? DateTime.parse(json['timerStartedAt'] as String)
          : null,
      members: members,
    );
  }
}
