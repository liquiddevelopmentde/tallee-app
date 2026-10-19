import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/licenses/oss_licenses.dart';
import 'package:tallee/presentation/widgets/tiles/license_tile.dart';

class LicensesView extends StatelessWidget {
  /// A view that displays a list of open source licenses used in the app
  const LicensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.licenses),
        backgroundColor: context.talleeColors.backgroundColor,
      ),
      backgroundColor: context.talleeColors.backgroundColor,
      body: ListView.builder(
        itemCount: allDependencies.length,
        itemBuilder: (context, index) {
          final package = allDependencies[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: LicenseTile(package: package),
          );
        },
      ),
    );
  }
}
