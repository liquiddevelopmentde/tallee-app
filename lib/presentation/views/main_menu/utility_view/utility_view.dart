import 'package:material_ui/material_ui.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/navigation/route_names.dart';
import 'package:tallee/presentation/views/main_menu/utility_view/dice_view.dart';
import 'package:tallee/presentation/widgets/tiles/settings_list_tile.dart';

class UtilityView extends StatelessWidget {
  /// A view that bundles small utilities for the physical game.
  const UtilityView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        spacing: 10,
        children: [
          SettingsListTile(
            title: loc.dice,
            description: loc.roll_dice,
            icon: Icons.casino_rounded,
            suffixWidget: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              Navigator.of(context).push(
                adaptivePageRoute(
                  settings: const RouteSettings(name: RouteNames.diceView),
                  builder: (context) => const DiceView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
