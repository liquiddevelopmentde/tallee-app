import 'package:clock/clock.dart';
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
  final DateTime? startDate;
  final DateTime? endDate;
  final AppColor color;
  final List<Group>? selectedGroups;
  final List<Game>? selectedGames;
  final int displayCount;
  final bool isFavourite;
  final int position;
  final SortDirection sortDirection;

  Statistic({
    required this.type,
    required this.scopes,
    this.timeframe = Timeframe.allTime,
    this.startDate,
    this.endDate,
    this.selectedGroups,
    this.selectedGames,
    this.displayCount = 5,
    this.isFavourite = false,
    this.position = 0,
    SortDirection? sortDirection,
    String? id,
    DateTime? createdAt,
    AppColor? color,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? clock.now(),
       color = color ?? AppColor.randomColor(),
       sortDirection = sortDirection ?? defaultsortDirectionFor(type);

  /// The sort order a new statistic of [type] starts with.
  /// "Worst score" shows ascending, everything else descending.
  static SortDirection defaultsortDirectionFor(StatisticType type) =>
      type == StatisticType.worstScore
      ? SortDirection.ascending
      : SortDirection.descending;

  @override
  String toString() =>
      'Statistic(id: $id, createdAt: $createdAt, type: $type, scopes: $scopes, timeframe: $timeframe, startDate: $startDate, endDate: $endDate, color: $color, selectedGroups: $selectedGroups, selectedGames: $selectedGames, displayCount: $displayCount, isFavourite: $isFavourite, sortDirection: $sortDirection)';

  Statistic copyWith({
    String? id,
    StatisticType? type,
    List<StatisticScope>? scopes,
    Timeframe? timeframe,
    DateTime? startDate,
    DateTime? endDate,
    AppColor? color,
    List<Group>? selectedGroups,
    List<Game>? selectedGames,
    int? displayCount,
    bool? isFavourite,
    int? position,
    SortDirection? sortDirection,
  }) => Statistic(
    id: id ?? this.id,
    type: type ?? this.type,
    scopes: scopes ?? this.scopes,
    timeframe: timeframe ?? this.timeframe,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    color: color ?? this.color,
    selectedGroups: selectedGroups ?? this.selectedGroups,
    selectedGames: selectedGames ?? this.selectedGames,
    displayCount: displayCount ?? this.displayCount,
    isFavourite: isFavourite ?? this.isFavourite,
    position: position ?? this.position,
    sortDirection: sortDirection ?? this.sortDirection,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'scopes': scopes.map((s) => s.name).toList(),
    'timeframe': timeframe.name,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'color': color.name,
    'selectedGroups': selectedGroups?.map((g) => g.id).toList(),
    'selectedGames': selectedGames?.map((g) => g.id).toList(),
    'displayCount': displayCount,
    'isFavourite': isFavourite,
    'position': position,
    'sortDirection': sortDirection.name,
  };

  factory Statistic.fromJson(Map<String, dynamic> json) {
    final type = StatisticType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => StatisticType.totalWins,
    );

    return Statistic(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      type: type,
      scopes: (json['scopes'] as List)
          .map(
            (scope) => StatisticScope.values.firstWhere(
              (e) => e.name == scope,
              orElse: () => StatisticScope.allPlayers,
            ),
          )
          .toList(),
      timeframe: Timeframe.values.firstWhere(
        (e) => e.name == json['timeframe'],
        orElse: () => Timeframe.allTime,
      ),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      color: AppColor.values.firstWhere(
        (e) => e.name == json['color'],
        orElse: () => AppColor.orange,
      ),
      displayCount: json['displayCount'],
      isFavourite: json['isFavourite'],
      position: json['position'],
      sortDirection: SortDirection.values.firstWhere(
        (e) =>
            e.name == json['sortDirection'] ||
            e.toString() == json['sortDirection'],
        orElse: () => Statistic.defaultsortDirectionFor(type),
      ),
    );
  }
}
