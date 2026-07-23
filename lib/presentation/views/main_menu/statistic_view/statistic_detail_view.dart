import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/translations.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/statistics_tile.dart';

class StatisticDetailView extends StatefulWidget {
  const StatisticDetailView({
    super.key,
    required this.statistic,
    required this.values,
    required this.icon,
    required this.barColor,
    required this.refreshStatistic,
  });

  final Statistic statistic;
  final List<(Player, num)> values;
  final IconData icon;
  final Color barColor;
  final Future<void> Function(String) refreshStatistic;

  @override
  State<StatisticDetailView> createState() => _StatisticDetailViewState();
}

class _StatisticDetailViewState extends State<StatisticDetailView> {
  late int displayCount;
  late bool isFavourite;
  Timer? timer;
  bool showHighlighting = false;

  @override
  void initState() {
    super.initState();
    displayCount = min(widget.statistic.displayCount, widget.values.length);
    isFavourite = widget.statistic.isFavourite;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final title = translateStatisticTypeToString(
      widget.statistic.type,
      context,
    );
    const style = TextStyle(fontWeight: FontWeight.bold);
    const divider = Divider(
      height: 12,
      thickness: 1,
      indent: 40,
      endIndent: 40,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.statistic),
        leading: HapticIconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => updateCount(),
        ),
        actions: [
          HapticIconButton(
            icon: isFavourite
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border),
            onPressed: () {
              setState(() {
                isFavourite = !isFavourite;
              });
              markAsFavourite(context);
            },
          ),
          HapticIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                showDialog<bool>(
                  context: context,
                  builder: (context) => CustomAlertDialog(
                    title: '${loc.delete_statistic}?',
                    content: Text(
                      loc.this_cannot_be_undone,
                      overflow: TextOverflow.visible,
                    ),
                    actions: [
                      CustomDialogAction(
                        onPressed: () => Navigator.of(context).pop(true),
                        text: loc.delete,
                      ),
                      CustomDialogAction(
                        onPressed: () => Navigator.of(context).pop(false),
                        buttonType: ButtonType.secondary,
                        text: loc.cancel,
                      ),
                    ],
                  ),
                ).then((confirmed) async {
                  if (confirmed! && context.mounted) {
                    deleteStatistic();
                  }
                }),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await updateCount();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              StatisticsTile(
                isFavourite: false,
                margin: EdgeInsets.zero,
                icon: widget.icon,
                title: title,
                width: MediaQuery.sizeOf(context).width * 0.95,
                values: widget.values,
                barColor: widget.barColor,
                selectedGroups: widget.statistic.selectedGroups,
                selectedGames: widget.statistic.selectedGames,
                displayCount: displayCount,
                showAllValues: true,
                showDisplayCountHighlighting: showHighlighting,
              ),
              const SizedBox(height: 12),

              InfoTile(
                leadingIcon: const Icon(Icons.filter_alt),
                width: MediaQuery.sizeOf(context).width * 0.95,
                title: loc.filter,
                content: Column(
                  spacing: 8,
                  children: [
                    // Scopes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.scope, style: style),
                          Text(
                            widget.statistic.scopes
                                .map(
                                  (scope) =>
                                      translateScopeToString(scope, context),
                                )
                                .join('\n'),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                    divider,

                    // Timeframe
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.timeframe, style: style),
                          Text(
                            translateTimeframeToString(
                              widget.statistic.timeframe,
                              context,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                    divider,

                    // Groups
                    if (widget.statistic.selectedGroups != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.groups, style: style),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                children: groupTextList,
                              ),
                            ),
                          ],
                        ),
                      ),
                      divider,
                    ],

                    // Games
                    if (widget.statistic.selectedGames != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.games, style: style),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                children: gameTextList,
                              ),
                            ),
                          ],
                        ),
                      ),
                      divider,
                    ],

                    if (widget.values.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.displayed_entries, style: style),
                            Row(
                              children: [
                                HapticIconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: displayCount <= 1
                                      ? null
                                      : () => updateDisplayCount(-1),
                                ),
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '$displayCount',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                HapticIconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed:
                                      displayCount >= widget.values.length
                                      ? null
                                      : () => updateDisplayCount(1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get gameTextList => widget.statistic.selectedGames!
      .mapIndexed(
        (i, game) => Text(
          i < widget.statistic.selectedGames!.length - 1
              ? '${game.name}, '
              : game.name,
        ),
      )
      .toList();

  List<Widget> get groupTextList => widget.statistic.selectedGroups!
      .mapIndexed(
        (i, group) => Text(
          i < widget.statistic.selectedGroups!.length - 1
              ? '${group.name}, '
              : group.name,
        ),
      )
      .toList();

  /// Handles updating the display count and starting the timer
  void updateDisplayCount(int delta) {
    final newValue = (displayCount + delta).clamp(1, widget.values.length);
    if (newValue == displayCount) return;

    setState(() {
      displayCount = newValue;
      showHighlighting = true;
    });

    restartDisplayCountTimer();
  }

  /// Restarts the timer
  void restartDisplayCountTimer() {
    timer?.cancel();

    timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        showHighlighting = false;
      });
    });
  }

  // Handles saving the display count and giving it to statistics view
  Future<void> updateCount() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.statisticDao.updateDisplayCount(widget.statistic.id, displayCount);
    await widget.refreshStatistic(widget.statistic.id);
    if (mounted) Navigator.of(context).pop(displayCount);
  }

  void deleteStatistic() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.statisticDao.deleteStatistic(widget.statistic.id);
    widget.refreshStatistic(widget.statistic.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void markAsFavourite(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.statisticDao.updateIsFavourite(widget.statistic.id, isFavourite);
    widget.refreshStatistic(widget.statistic.id);
  }
}
