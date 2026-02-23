import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
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
        backgroundColor: CustomTheme.backgroundColor,
      ),
      backgroundColor: CustomTheme.backgroundColor,
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
