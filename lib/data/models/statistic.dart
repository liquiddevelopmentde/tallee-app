import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';

class Statistic {
  final StatisticType type;
  final List<StatisticScope> scopes;
  final Timeframe? timeframe;
  final List<Group>? selectedGroups;
  final List<Game>? selectedGames;

  Statistic({
    required this.type,
    required this.scopes,
    this.timeframe,
    this.selectedGroups,
    this.selectedGames,
  });
}
