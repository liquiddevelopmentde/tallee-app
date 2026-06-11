import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/group_view/group_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_view.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/settings_view.dart';
import 'package:tallee/presentation/views/main_menu/statistics_view/statistics_view.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/navbar_item.dart';
import 'package:tallee/state/group_search_provider.dart';
import 'package:tallee/state/match_search_provider.dart';

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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final matchSearchProvider = Provider.of<MatchSearchProvider>(context);
    final groupSearchProvider = Provider.of<GroupSearchProvider>(context);
    // Pretty ugly but works
    final List<Widget> tabs = [
      KeyedSubtree(
        key: ValueKey('matches_$tabKeyCount'),
        child: const MatchView(),
      ),
      KeyedSubtree(
        key: ValueKey('groups_$tabKeyCount'),
        child: const GroupView(),
      ),
      KeyedSubtree(
        key: ValueKey('stats_$tabKeyCount'),
        child: const StatisticsView(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _currentTabTitle(context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: CustomTheme.backgroundColor,
        scrolledUnderElevation: 0,
        actions: [
          if (currentIndex == 0) // Nur im Matches-Tab
            matchSearchProvider.isSearching
                ? HapticIconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => matchSearchProvider.toggleSearch(),
                  )
                : HapticIconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => matchSearchProvider.toggleSearch(),
                  ),
          if (currentIndex == 1)
            HapticIconButton(
              icon: Icon(
                groupSearchProvider.isSearching ? Icons.close : Icons.search,
              ),
              onPressed: () => groupSearchProvider.toggleSearch(),
            ),
          HapticIconButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await navigator.push(
                adaptivePageRoute(builder: (_) => const SettingsView()),
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
                icon: Icons.gamepad_rounded,
                label: loc.matches,
                onTabTapped: onTabTapped,
              ),
              NavbarItem(
                index: 1,
                isSelected: currentIndex == 1,
                icon: Icons.group_rounded,
                label: loc.groups,
                onTabTapped: onTabTapped,
              ),
              NavbarItem(
                index: 2,
                isSelected: currentIndex == 2,
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
  void onTabTapped(int index) async {
    await HapticFeedback.selectionClick();
    setState(() {
      currentIndex = index;
    });
  }

  /// Returns the title of the current tab based on [currentIndex].
  String _currentTabTitle(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (currentIndex) {
      case 0:
        return loc.matches;
      case 1:
        return loc.groups;
      case 2:
        return loc.statistics;
      default:
        return '';
    }
  }
}
