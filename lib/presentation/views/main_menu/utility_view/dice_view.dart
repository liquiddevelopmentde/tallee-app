import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class DiceView extends StatefulWidget {
  const DiceView({super.key});

  @override
  State<DiceView> createState() => _DiceViewState();
}

class _DiceViewState extends State<DiceView> {
  static const Map<int, List<int>> pipPositions = {
    1: [4],
    2: [0, 8],
    3: [0, 4, 8],
    4: [0, 2, 6, 8],
    5: [0, 2, 4, 6, 8],
    6: [0, 2, 3, 5, 6, 8],
  };

  final Random random = Random();
  late int result = random.nextInt(6) + 1;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.dice)),
      backgroundColor: CustomTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildDie(result),
            const SizedBox(height: 40),

            // Throw button
            BottomAnimatedButton(
              buttonText: loc.throw_dice,
              sizeRelativeToWidth: 0.6,
              onPressed: () {
                setState(() => result = random.nextInt(6) + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the die face with pips for [value].
  Widget buildDie(int value) {
    return Container(
      width: 140,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            Expanded(
              child: Row(
                children: [
                  for (var col = 0; col < 3; col++)
                    Expanded(
                      child: pipPositions[value]!.contains(row * 3 + col)
                          ? const Center(child: _Pip())
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Pip extends StatelessWidget {
  const _Pip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: CustomTheme.textColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
