import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/theme/app_spacing.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/data/statistics/statistic_calculator.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/dropdown/pull_down_menu/pull_down_menu_button.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/statistics_tile.dart';

class StatisticDetailView extends StatefulWidget {
  const StatisticDetailView({
    super.key,
    required this.statistic,
    required this.values,
    required this.refreshStatistic,
  });

  final Statistic statistic;
  final List<(Player, num)> values;
  final Future<void> Function(String) refreshStatistic;

  @override
  State<StatisticDetailView> createState() => _StatisticDetailViewState();
}

class _StatisticDetailViewState extends State<StatisticDetailView> {
  late int displayCount;
  late bool isFavourite;
  late StatisticSortOrder sortOrder;
  late List<(Player, num)> sortedValues;
  Timer? timer;
  bool showHighlighting = false;

  bool get hasData => sortedValues.any((entry) => entry.$2 != 0);

  @override
  void initState() {
    super.initState();
    sortOrder = widget.statistic.sortOrder;
    sortedValues = [...widget.values];
    StatisticCalculator.sortValues(sortedValues, sortOrder);
    displayCount = min(widget.statistic.displayCount, sortedValues.length);
    isFavourite = widget.statistic.isFavourite;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
          onPressed: updateCount,
        ),
        actions: [
          PullDownMenuButton(
            icon: Icon(
              sortOrder == StatisticSortOrder.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            items: [
              PullDownMenuTile(
                icon: Icons.arrow_upward,
                label: loc.ascending,
                enabled: sortOrder != StatisticSortOrder.ascending,
                onTap: () => updateSortOrder(StatisticSortOrder.ascending),
              ),
              PullDownMenuTile(
                icon: Icons.arrow_downward,
                label: loc.descending,
                enabled: sortOrder != StatisticSortOrder.descending,
                onTap: () => updateSortOrder(StatisticSortOrder.descending),
              ),
            ],
          ),
          HapticIconButton(
            icon: isFavourite
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border),
            onPressed: () => toggleIsFavourite(context),
          ),
          HapticIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
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
                      accent: ButtonAccent.destructive,
                    ),
                    CustomDialogAction(
                      onPressed: () => Navigator.of(context).pop(false),
                      buttonType: ButtonType.secondary,
                      text: loc.cancel,
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await deleteStatistic();
              }
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await updateCount();
        },
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    spacing: 12,
                    children: [
                      // Statistic
                      StatisticsTile(
                        statistic: widget.statistic,
                        margin: EdgeInsets.zero,
                        width:
                            MediaQuery.sizeOf(context).width *
                            AppSpacing.contentWidthFactor,
                        values: sortedValues,
                        displayCount: displayCount,
                        showAllValues: true,
                        showDisplayCountHighlighting: showHighlighting,
                      ),

                      // Details
                      InfoTile(
                        leadingWidget: const Icon(Icons.filter_alt),
                        width:
                            MediaQuery.sizeOf(context).width *
                            AppSpacing.contentWidthFactor,
                        title: loc.filter,
                        content: Column(
                          spacing: 8,
                          children: [
                            // Scopes
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(loc.scope, style: style),
                                  Text(
                                    widget.statistic.scopes
                                        .map(
                                          (scope) =>
                                              scope.toLocalizedString(context),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(loc.timeframe, style: style),
                                  Text(
                                    widget.statistic.timeframe ==
                                                Timeframe.custom &&
                                            widget.statistic.startDate !=
                                                null &&
                                            widget.statistic.endDate != null
                                        ? '${widget.statistic.startDate!.toShortDate(context)} - ${widget.statistic.endDate!.toShortDate(context)}'
                                        : widget.statistic.timeframe
                                              .toLocalizedString(context),
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                            ),

                            // Groups
                            if (widget.statistic.selectedGroups != null) ...[
                              divider,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(loc.groups, style: style),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Wrap(
                                        alignment: WrapAlignment.end,
                                        children: groupTextList,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Games
                            if (widget.statistic.selectedGames != null) ...[
                              divider,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(loc.games, style: style),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Wrap(
                                        alignment: WrapAlignment.end,
                                        children: gameTextList,
                                      ),
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
            ),
            Positioned(
              bottom: AppSpacing.floatingButtonBottom(context),
              child: Row(
                spacing: 10,
                children: [
                  FloatingAnimatedButton(
                    icon: Icons.remove,
                    onPressed: displayCount <= 1 || !hasData
                        ? null
                        : () => updateDisplayCount(-1),
                  ),

                  // Current display count
                  Container(
                    constraints: const BoxConstraints(minWidth: 90),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: context.talleeColors.boxColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: context.talleeColors.boxBorderColor,
                      ),
                    ),
                    child: Text(
                      loc.top_n(displayCount),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  FloatingAnimatedButton(
                    icon: Icons.add,
                    onPressed: displayCount >= sortedValues.length || !hasData
                        ? null
                        : () => updateDisplayCount(1),
                  ),
                ],
              ),
            ),
          ],
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
    final newValue = (displayCount + delta).clamp(1, sortedValues.length);
    if (newValue == displayCount) return;

    setState(() {
      displayCount = newValue;
      showHighlighting = true;
    });

    restartDisplayCountTimer();
  }

  /// Re-sorts the displayed values and persists the new sort order.
  Future<void> updateSortOrder(StatisticSortOrder newSortOrder) async {
    setState(() {
      sortOrder = newSortOrder;
      StatisticCalculator.sortValues(sortedValues, newSortOrder);
    });

    final db = context.read<AppDatabase>();
    await db.statisticDao.updateSortOrder(widget.statistic.id, newSortOrder);
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
    // Only save a changed and valid count, otherwise a statistic without
    // values would persist a display count of 0
    if (displayCount > 0 && displayCount != widget.statistic.displayCount) {
      final db = context.read<AppDatabase>();
      await db.statisticDao.updateDisplayCount(
        widget.statistic.id,
        displayCount,
      );
    }
    await widget.refreshStatistic(widget.statistic.id);
    if (mounted) Navigator.of(context).pop(displayCount);
  }

  Future<void> toggleIsFavourite(BuildContext context) async {
    final updatedIsFavourite = !isFavourite;
    final db = context.read<AppDatabase>();
    await db.statisticDao.updateIsFavourite(
      widget.statistic.id,
      updatedIsFavourite,
    );
    unawaited(widget.refreshStatistic(widget.statistic.id));
    setState(() {
      isFavourite = updatedIsFavourite;
    });
  }

  Future<void> deleteStatistic() async {
    final db = context.read<AppDatabase>();
    await db.statisticDao.deleteStatistic(widget.statistic.id);
    unawaited(widget.refreshStatistic(widget.statistic.id));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
