import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/animated_dialog_button.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';

class TeamCreationTile extends StatefulWidget {
  const TeamCreationTile({
    super.key,
    required this.color,
    required this.controller,
    required this.hintText,
    this.onDelete,
    this.onColorSelection,
  });

  final GameColor color;

  final TextEditingController controller;

  final String hintText;

  final VoidCallback? onDelete;

  final ValueChanged<GameColor>? onColorSelection;

  @override
  State<TeamCreationTile> createState() => _TeamCreationTileState();
}

class _TeamCreationTileState extends State<TeamCreationTile> {
  final teamColors = List.generate(
    GameColor.values.length,
    (index) => getTeamColor(index),
  );
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      margin: CustomTheme.standardMargin,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextInputField(
                  controller: widget.controller,
                  hintText: widget.hintText,
                  maxLength: Constants.MAX_TEAM_NAME_LENGTH,
                ),
              ),
              const SizedBox(width: 12),
              AnimatedDialogButton(
                content: const Icon(Icons.delete),
                isDescructive: true,
                onPressed: widget.onDelete,
                buttonText: '',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.color,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CustomTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: teamColors.map((color) {
              final isSelected = widget.color == color;
              return GestureDetector(
                onTap: () {
                  widget.onColorSelection?.call(color);
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: getColorFromGameColor(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
