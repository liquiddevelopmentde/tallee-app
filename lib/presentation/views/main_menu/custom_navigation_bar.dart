import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/create_player_view.dart';
import 'package:tallee/presentation/views/main_menu/group_view/create_group_view.dart';
import 'package:tallee/presentation/views/main_menu/group_view/group_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_game_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_match_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_view.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/settings_view.dart';
import 'package:tallee/presentation/views/main_menu/statistic_view/statistic_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/navbar_item.dart';
import 'package:tallee/state/data_refresh_provider.dart';
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
        key: ValueKey('stats_${tabKeyCount}_$refreshRevision'),
        child: const StatisticsView(),
      ),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _currentTabTitle(context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: CustomTheme.backgroundColor,
        scrolledUnderElevation: 0,
        actions: [
          if (currentIndex == 0) // Only in MatchView
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

          if (currentIndex == 0) // Only in MatchView
            CustomPopup(
              key: const ValueKey('match_create_button'),
              showArrow: true,
              arrowColor: CustomTheme.boxBorderColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 10,
              ),
              barrierColor: Colors.transparent,
              contentDecoration: CustomTheme.standardBoxDecoration,
              onBeforePopup: () async {
                await HapticFeedback.selectionClick();
              },
              content: _buildCreateMenu(loc),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.add),
              ),
            ),

          if (currentIndex == 1) // Only in GroupView
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

  /// Builds the dropdown menu content for creating new entities.
  Widget _buildCreateMenu(AppLocalizations loc) {
    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.person_add,
        label: loc.create_player,
        onTap: () => _openCreateView(builder: (_) => const CreatePlayerView()),
      ),
      (
        icon: Icons.group_add,
        label: loc.create_group,
        onTap: () => _openCreateView(builder: (_) => const CreateGroupView()),
      ),
      (
        icon: RpgAwesome.clovers_card,
        label: loc.create_match,
        onTap: () => _openCreateView(builder: (_) => const CreateMatchView()),
      ),
      (
        icon: Icons.videogame_asset_rounded,
        label: loc.create_game,
        onTap: () => _openCreateView(
          builder: (_) => CreateGameView(onGameChanged: () {}),
        ),
      ),
    ];

    return SizedBox(
      width: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          for (final item in items)
            GestureDetector(
              onTap: item.onTap,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: CustomTheme.textColor.withAlpha(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(item.icon, size: 16),
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: CustomTheme.textColor,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Closes the create dropdown, opens the create view built by [builder] and
  /// refreshes the tab views so newly created data shows up.
  Future<void> _openCreateView({required WidgetBuilder builder}) async {
    Navigator.of(context).pop();
    await Navigator.of(context).push(adaptivePageRoute(builder: builder));
    if (mounted) {
      Provider.of<DataRefreshProvider>(context, listen: false).refresh();
    }
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
