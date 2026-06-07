import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:uuid/uuid.dart';

class Statistic {
  final String id;
  final StatisticType type;
  final List<StatisticScope> scopes;
  final Timeframe timeframe;
  final List<Group>? selectedGroups;
  final List<Game>? selectedGames;
  final int displayCount;

  Statistic({
    required this.type,
    required this.scopes,
    this.timeframe = Timeframe.allTime,
    this.selectedGroups,
    this.selectedGames,
    this.displayCount = 5,
    String? id,
  }) : id = id ?? const Uuid().v4();

  @override
  String toString() {
    return 'Statistic(id: $id, type: $type, scopes: $scopes, timeframe: $timeframe, selectedGroups: $selectedGroups, selectedGames: $selectedGames)';
  }

  Statistic copyWith({
    StatisticType? type,
    List<StatisticScope>? scopes,
    Timeframe? timeframe,
    List<Group>? selectedGroups,
    List<Game>? selectedGames,
    int? displayCount,
  }) {
    return Statistic(
      id: id,
      type: type ?? this.type,
      scopes: scopes ?? this.scopes,
      timeframe: timeframe ?? this.timeframe,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      selectedGames: selectedGames ?? this.selectedGames,
      displayCount: displayCount ?? this.displayCount,
    );
  }
}
