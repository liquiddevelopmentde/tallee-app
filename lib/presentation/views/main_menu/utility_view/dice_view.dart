import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

class DiceView extends StatelessWidget {
  /// The dice throwing menu. Currently empty, will hold the dice utilities.
  const DiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.dice)),
      backgroundColor: CustomTheme.backgroundColor,
      body: const SizedBox.shrink(),
    );
  }
}
