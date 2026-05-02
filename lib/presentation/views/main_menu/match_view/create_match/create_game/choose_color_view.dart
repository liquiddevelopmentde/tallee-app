import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/tiles/game_tile.dart';

class ChooseColorView extends StatefulWidget {
  /// A view that allows the user to choose a color from a list of available game colors
  /// - [initialColor]: The initially selected color
  const ChooseColorView({super.key, this.initialColor});

  /// The initially selected color
  final GameColor? initialColor;

  @override
  State<ChooseColorView> createState() => _ChooseColorViewState();
}

class _ChooseColorViewState extends State<ChooseColorView> {
  /// Currently selected color
  GameColor? selectedColor;

  @override
  void initState() {
    selectedColor = widget.initialColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    const colors = GameColor.values;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop(selectedColor);
          },
        ),
        title: Text(loc.choose_color),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          Navigator.of(context).pop(selectedColor);
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 85),
          itemCount: colors.length,
          itemBuilder: (BuildContext context, int index) {
            final color = colors[index];
            return GameTile(
              onTap: () {
                setState(() {
                  if (selectedColor == color) {
                    selectedColor = null;
                  } else {
                    selectedColor = color;
                  }
                });
              },
              title: translateGameColorToString(color, context),
              description: '',
              isHighlighted: selectedColor == color,
              badgeText: '          ', //Breite für Color Badge
              badgeColor: getColorFromGameColor(color),
            );
          },
        ),
      ),
    );
  }
}
