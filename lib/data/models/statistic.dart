import 'package:clock/clock.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:uuid/uuid.dart';

export 'package:tallee/core/enums.dart';

class Statistic {
  final String id;
  final DateTime createdAt;
  final StatisticType type;
  final List<StatisticScope> scopes;
  final Timeframe timeframe;
  final AppColor color;
  final List<Group>? selectedGroups;
  final List<Game>? selectedGames;
  final int displayCount;
  final bool isFavourite;

  Statistic({
    required this.type,
    required this.scopes,
    this.timeframe = Timeframe.allTime,
    this.selectedGroups,
    this.selectedGames,
    this.displayCount = 5,
    this.isFavourite = false,
    String? id,
    DateTime? createdAt,
    AppColor? color,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       color = color ?? getRandomAppColor();

  @override
  String toString() {
    return 'Statistic(id: $id, createdAt: $createdAt, type: $type, scopes: $scopes, timeframe: $timeframe, color: $color, selectedGroups: $selectedGroups, selectedGames: $selectedGames, displayCount: $displayCount, isFavourite: $isFavourite)';
  }

  Statistic copyWith({
    StatisticType? type,
    List<StatisticScope>? scopes,
    Timeframe? timeframe,
    AppColor? color,
    List<Group>? selectedGroups,
    List<Game>? selectedGames,
    int? displayCount,
    bool? isFavourite,
  }) {
    return Statistic(
      id: id,
      type: type ?? this.type,
      scopes: scopes ?? this.scopes,
      timeframe: timeframe ?? this.timeframe,
      color: color ?? this.color,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      selectedGames: selectedGames ?? this.selectedGames,
      displayCount: displayCount ?? this.displayCount,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'scopes': scopes.map((s) => s.name).toList(),
    'timeframe': timeframe.name,
    'color': color.name,
    'selectedGroups': selectedGroups?.map((g) => g.id).toList(),
    'selectedGames': selectedGames?.map((g) => g.id).toList(),
    'displayCount': displayCount,
    'isFavourite': isFavourite,
  };

  Statistic.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['createdAt']),
      type = StatisticType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StatisticType.totalWins,
      ),
      scopes = (json['scopes'] as List)
          .map(
            (scope) => StatisticScope.values.firstWhere(
              (e) => e.name == scope,
              orElse: () => StatisticScope.allPlayers,
            ),
          )
          .toList(),
      timeframe = Timeframe.values.firstWhere(
        (e) => e.name == json['timeframe'],
        orElse: () => Timeframe.allTime,
      ),
      color = AppColor.values.firstWhere(
        (e) => e.name == json['color'],
        orElse: () => AppColor.orange,
      ),
      selectedGroups = null,
      selectedGames = null,
      displayCount = json['displayCount'],
      isFavourite = json['isFavourite'] ?? false;
}
