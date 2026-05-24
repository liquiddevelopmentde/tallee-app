import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:uuid/uuid.dart';

class Statistic {
  final String id;
  final StatisticType type;
  final List<StatisticScope> scopes;
  final Timeframe? timeframe;
  final List<Group>? selectedGroups;
  final List<Game>? selectedGames;

  Statistic({
    required this.type,
    required this.scopes,
    String? id,
    this.timeframe,
    this.selectedGroups,
    this.selectedGames,
  }) : id = id ?? const Uuid().v4();

  @override
  String toString() {
    return 'Statistic(id: $id, type: $type, scopes: $scopes, timeframe: $timeframe, selectedGroups: $selectedGroups, selectedGames: $selectedGames)';
  }
}
