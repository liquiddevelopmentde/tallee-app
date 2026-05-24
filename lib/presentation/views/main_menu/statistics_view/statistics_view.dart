import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/statistics_view/create_statistic_view.dart';
import 'package:tallee/presentation/views/main_menu/statistics_view/statistic_tile_factory.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';

class StatisticsView extends StatefulWidget {
  /// A view that displays player statistics
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  bool isLoading = true;
  List<Match> _allMatches = const [];
  List<Player> _allPlayers = const [];
  List<Widget> statisticTiles = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      getStatisticTiles(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          alignment: AlignmentDirectional.bottomCenter,
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: AppSkeleton(
                enabled: isLoading,
                fixLayoutBuilder: true,
                child: Column(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...statisticTiles,
                    SizedBox(height: MediaQuery.paddingOf(context).bottom + 80),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 20,
              child: MainMenuButton(
                text: loc.create_statistic,
                icon: Icons.bar_chart,
                onPressed: () async {
                  Statistic newStatistic = await Navigator.push(
                    context,
                    adaptivePageRoute(
                      builder: (context) => CreateStatisticView(
                        onStatisticCreated: () => getStatisticTiles(context),
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  final newTile = buildStatisticTile(
                    statistic: newStatistic,
                    matches: _allMatches,
                    players: _allPlayers,
                    context: context,
                  );

                  setState(() {
                    statisticTiles.add(newTile);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> getStatisticTiles(BuildContext context) async {
    setState(() {
      isLoading = true;
      statisticTiles = List.generate(
        4,
        (index) => Column(
          children: [
            buildSkeletonStatisticTile(context: context),
            const SizedBox(height: 12),
          ],
        ),
      );
    });

    final db = Provider.of<AppDatabase>(context, listen: false);

    final results = await Future.wait([
      db.statisticDao.getAllStatistics(),
      db.matchDao.getAllMatches(),
      db.playerDao.getAllPlayers(),
      Future.delayed(Constants.MINIMUM_SKELETON_DURATION),
    ]);

    if (!mounted) return;

    final statistics = results[0] as List<Statistic>;
    _allMatches = results[1] as List<Match>;
    _allPlayers = results[2] as List<Player>;

    setState(() {
      statisticTiles = [
        for (final statistic in statistics) ...[
          buildStatisticTile(
            statistic: statistic,
            matches: _allMatches,
            players: _allPlayers,
            context: context,
          ),
        ],
      ];
      isLoading = false;
    });
  }
}
