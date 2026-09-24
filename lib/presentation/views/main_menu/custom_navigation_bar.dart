import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_version_plus/model/version_status.dart';
import 'package:once/once.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_sheet_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/game_view/game_view.dart';
import 'package:tallee/presentation/views/main_menu/group_view/group_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/match_receive_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_view.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/settings_view.dart';
import 'package:tallee/presentation/views/main_menu/statistic_view/statistic_view.dart';
import 'package:tallee/presentation/views/news/news_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/navbar_item.dart';
import 'package:tallee/state/data_refresh_provider.dart';
import 'package:tallee/state/game_search_provider.dart';
import 'package:tallee/state/group_search_provider.dart';
import 'package:tallee/state/match_search_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomNavigationBar extends StatefulWidget {
  /// A custom navigation bar widget that provides tabbed navigation
  /// between different views: Home, Matches, Groups, and Statistics.
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar>
    with SingleTickerProviderStateMixin {
  /// Currently selected tab index
  int currentIndex = 0;

  /// Key count to force rebuild of tab views
  int tabKeyCount = 0;

  @override
  void initState() {
    super.initState();

    addExampleStats();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkVersionAndUpdate(context);
      openNewsDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final matchSearchProvider = context.read<MatchSearchProvider>();
    final groupSearchProvider = context.read<GroupSearchProvider>();
    final gameSearchProvider = context.read<GameSearchProvider>();

    final refreshRevision = context.watch<DataRefreshProvider>().revision;

    // Pretty ugly but works
    final List<Widget> tabs = [
      KeyedSubtree(
        key: ValueKey('matches_${tabKeyCount}_$refreshRevision'),
        child: const MatchView(),
      ),
      KeyedSubtree(
        key: ValueKey('groups_${tabKeyCount}_$refreshRevision'),
        child: const GroupView(),
      ),
      KeyedSubtree(
        key: ValueKey('games_${tabKeyCount}_$refreshRevision'),
        child: const GameView(),
      ),
      KeyedSubtree(
        key: ValueKey('stats_${tabKeyCount}_$refreshRevision'),
        child: const StatisticsView(),
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          currentTabTitle(context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: CustomTheme.backgroundColor,
        scrolledUnderElevation: 0,
        leading: currentIndex == 0
            ? HapticIconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    adaptivePageRoute(builder: (_) => const MatchReceiveView()),
                  );
                  if (mounted) {
                    setState(() {
                      tabKeyCount++;
                    });
                  }
                },
                icon: const Icon(Icons.qr_code_scanner),
              )
            : null,
        actions: [
          // Only in MatchView
          if (currentIndex == 0)
            HapticIconButton(
              key: ValueKey(
                matchSearchProvider.isSearching
                    ? 'match_search_close_button'
                    : 'match_search_open_button',
              ),
              icon: matchSearchProvider.isSearching
                  ? const Icon(Icons.close)
                  : const Icon(Icons.search),
              onPressed: () => matchSearchProvider.toggleSearch(),
            ),

          // Only in GroupView
          if (currentIndex == 1)
            HapticIconButton(
              key: ValueKey(
                groupSearchProvider.isSearching
                    ? 'group_search_close_button'
                    : 'group_search_open_button',
              ),
              icon: Icon(
                groupSearchProvider.isSearching ? Icons.close : Icons.search,
              ),
              onPressed: () => groupSearchProvider.toggleSearch(),
            ),

          // Only in GameView
          if (currentIndex == 2)
            HapticIconButton(
              key: ValueKey(
                gameSearchProvider.isSearching
                    ? 'game_search_close_button'
                    : 'game_search_open_button',
              ),
              icon: Icon(
                gameSearchProvider.isSearching ? Icons.close : Icons.search,
              ),
              onPressed: () => gameSearchProvider.toggleSearch(),
            ),

          HapticIconButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await navigator.push(
                adaptivePageRoute(
                  settings: const RouteSettings(name: RouteNames.settingsView),
                  builder: (_) => const SettingsView(),
                ),
              );
              setState(() {
                tabKeyCount++;
              });
            },
            icon: const Icon(Icons.settings),
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: CustomTheme.backgroundColor,
      body: tabs[currentIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        height: 115,
        decoration: BoxDecoration(
          color: CustomTheme.navBarBackgroundColor,
          border: Border.all(
            strokeAlign: BorderSide.strokeAlignOutside,
            color: CustomTheme.boxBorderColor,
            width: 2,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              NavbarItem(
                index: 0,
                isSelected: currentIndex == 0,
                icon: MATCH_ICON,
                label: loc.matches,
                onTabTapped: onTabTapped,
              ),
              NavbarItem(
                index: 1,
                isSelected: currentIndex == 1,
                icon: GROUP_ICON,
                label: loc.groups,
                onTabTapped: onTabTapped,
              ),
              NavbarItem(
                index: 2,
                isSelected: currentIndex == 2,
                icon: GAME_ICON,
                label: loc.games,
                onTabTapped: onTabTapped,
              ),
              NavbarItem(
                index: 3,
                isSelected: currentIndex == 3,
                icon: Icons.bar_chart_rounded,
                label: loc.statistics,
                onTabTapped: onTabTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles tab tap events. Updates the current [index] state.
  void onTabTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      currentIndex = index;
    });
  }

  /// Returns the title of the current tab based on [currentIndex].
  String currentTabTitle(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (currentIndex) {
      case 0:
        return loc.matches;
      case 1:
        return loc.groups;
      case 2:
        return loc.games;
      case 3:
        return loc.statistics;
      default:
        return '';
    }
  }

  /// Opens the [NewsView] when the user installs a new version
  void openNewsDialog() {
    Once.runOnEveryNewVersion(
      key: 'whats-new-screen',
      callback: () {
        Future.delayed(OPEN_WITH_NAVIGATION_DELAY, () {
          if (!mounted) return;
          Navigator.of(
            context,
            rootNavigator: true,
          ).push(adaptiveSheetRoute(builder: (context) => const NewsView()));
        });
      },
    );
  }

  /// Checks for a new version and shows an update dialog if available.
  Future<void> checkVersionAndUpdate(BuildContext context) async {
    final loc = AppLocalizations.of(context);

    VersionStatus? status;

    try {
      status = await newVersionPlus.getVersionStatus();
    } catch (error, stacktrace) {
      if (isNetworkError(error)) return;
      Sentry.captureException(
        error,
        stackTrace: stacktrace,
        hint: Hint.withMap({'skipSnackBar': true}),
        withScope: (scope) {
          scope.level = SentryLevel.error;
        },
      );
    }

    if (status != null && status.canUpdate) {
      if (!context.mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: loc.update_available,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.update_available_content,
                  style: const TextStyle(
                    color: CustomTheme.textColor,
                    overflow: TextOverflow.visible,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.update_features_fixes_desc,
                  style: const TextStyle(
                    color: CustomTheme.textColor,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            actions: [
              CustomDialogAction(
                text: loc.update_now,
                buttonType: ButtonType.primary,
                onPressed: () async {
                  final Uri url = Uri.parse(status!.appStoreLink);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              CustomDialogAction(
                text: loc.later,
                buttonType: ButtonType.secondary,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  /// Adds example statistics to the database the first time the user opens the app
  void addExampleStats() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Once.runOnce(
        'example-stats',
        callback: () async {
          final db = context.read<AppDatabase>();
          final stat1 = Statistic(
            type: StatisticType.totalWins,
            color: AppColor.orange,
            displayCount: 3,
            scopes: [StatisticScope.allPlayers],
          );
          final stat2 = Statistic(
            type: StatisticType.averageScore,
            color: AppColor.pink,
            displayCount: 5,
            scopes: [StatisticScope.allPlayers],
          );
          final stat3 = Statistic(
            type: StatisticType.averageScore,
            color: AppColor.green,
            displayCount: 8,
            scopes: [StatisticScope.allPlayers],
          );

          await db.statisticDao.addStatisticsAsList(
            statistics: [stat1, stat2, stat3],
          );
        },
      );
    });
  }
}
