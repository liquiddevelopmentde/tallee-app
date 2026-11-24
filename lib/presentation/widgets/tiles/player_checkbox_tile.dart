import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/name_display.dart';

class PlayerCheckboxTile extends StatelessWidget {
  /// A player (or pair) list tile with a checkbox on the right that reflects
  /// the current selection.
  /// - [unit]: The player or pair to display.
  /// - [checked]: Whether the unit is currently selected.
  /// - [onTileTap]: The callback invoked when the tile itself is tapped.
  /// - [onCheckboxChanged]: The callback invoked with the new value whenever
  ///   the checkbox is tapped.
  /// - [onLongPress]: An optional callback invoked when the tile is long
  ///   pressed, e.g. to pair players.
  /// - [highlighted]: Whether the tile is highlighted, e.g. while it is
  ///   selected for pairing.
  /// - [showLinkIcon]: Whether a link icon should be shown, e.g. while
  ///   pairing mode is active.
  const PlayerCheckboxTile({
    super.key,
    required this.unit,
    required this.checked,
    required this.onTileTap,
    required this.onCheckboxChanged,
    this.onLongPress,
    this.highlighted = false,
    this.showLinkIcon = false,
  });

  final Team unit;
  final bool checked;
  final VoidCallback onTileTap;
  final ValueChanged<bool> onCheckboxChanged;
  final VoidCallback? onLongPress;
  final bool highlighted;
  final bool showLinkIcon;

  bool get isDeleted =>
      unit.members.isNotEmpty &&
      (unit.isPair
          ? unit.members.every((player) => player.deleted)
          : unit.members.first.deleted);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTileTap,
    onLongPress: onLongPress,
    child: Container(
      padding: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        color: context.talleeColors.boxColor,
        border: Border.all(
          color: highlighted
              ? AppColors.primaryColor
              : context.talleeColors.boxBorderColor,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
        borderRadius: AppColors.standardBorderRadiusAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              child: Row(
                children: [
                  if (isDeleted)
                    Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: context.talleeColors.hintColor,
                    ),
                  if (unit.members.isNotEmpty)
                    Flexible(
                      child: buildUnitNameWidget(
                        context,
                        unit.isPair ? unit : unit.members.first,
                        pairIconLeft: true,
                        mainStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        countStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.talleeColors.textColor.withAlpha(100),
                        ),
                        muted: unit.members
                            .map((player) => player.deleted)
                            .toList(),
                      ),
                    ),
                  if (showLinkIcon) ...[
                    const SizedBox(width: 5),
                    const Icon(Icons.add_link, size: 18),
                  ],
                ],
              ),
            ),
          ),
          Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            value: checked,
            onChanged: (bool? value) {
              if (value == null) return;
              onCheckboxChanged(value);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
    ),
  );
}
