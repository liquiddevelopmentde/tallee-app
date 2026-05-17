import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile.dart';

class TeamCreationTile extends StatefulWidget {
  const TeamCreationTile({
    super.key,
    required this.color,
    required this.controller,
    required this.players,
    required this.hintText,
    this.onDelete,
    this.onColorSelection,
    this.onPlayerTap,
  });

  final GameColor color;

  final List<Player> players;

  final TextEditingController controller;

  final String hintText;

  final VoidCallback? onDelete;

  final ValueChanged<GameColor>? onColorSelection;

  final void Function(Player player)? onPlayerTap;

  @override
  State<TeamCreationTile> createState() => _TeamCreationTileState();
}

class _TeamCreationTileState extends State<TeamCreationTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: CustomTheme.standardMargin,
      padding: const EdgeInsets.all(12),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextInputField(
                  controller: widget.controller,
                  hintText: widget.hintText,
                  maxLength: Constants.MAX_TEAM_NAME_LENGTH,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => widget.onDelete?.call(),
                icon: const Icon(Icons.delete, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Color',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CustomTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GameColor.values.map((color) {
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
          const Text(
            'Players',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CustomTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.players.isEmpty)
            const Text(
              'Keine Spieler:innen zugewiesen',
              style: TextStyle(color: CustomTheme.hintColor),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.players
                  .map(
                    (player) => GestureDetector(
                      onTap: () => widget.onPlayerTap?.call(player),
                      child: TextIconTile(
                        text: player.name,
                        suffixText: getNameCountText(player),
                        iconEnabled: widget.onPlayerTap != null,
                        onIconTap: () => widget.onPlayerTap?.call(player),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
