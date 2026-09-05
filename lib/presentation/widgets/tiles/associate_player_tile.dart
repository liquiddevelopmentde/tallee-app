import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/name_display.dart';

/// A Tile for matching a [player] to an [associatedPlayer]. This is used during the association process in the remote match sharing feature.
///
/// [player] - The player being matched.
/// [onTap] - Called when the associated-player area is tapped.
/// [associatedPlayer] - The player currently associated with [player], if any.
/// [borderColor] - Optional override for the tile border color.
class AssociatePlayerTile extends StatefulWidget {
  const AssociatePlayerTile({
    required this.player,
    required this.onTap,
    this.associatedPlayer,
    this.isNew = false,
    this.borderColor,
    super.key,
  });

  final Player player;

  final Player? associatedPlayer;

  final bool isNew;

  final VoidCallback onTap;

  final Color? borderColor;

  @override
  State<AssociatePlayerTile> createState() => _AssociatePlayerTileState();
}

class _AssociatePlayerTileState extends State<AssociatePlayerTile> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: CustomTheme.standardBoxDecoration.copyWith(
        border: Border.all(
          color: widget.borderColor ?? CustomTheme.boxBorderColor,
        ),
      ),
      margin: CustomTheme.standardMargin,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: buildUnitNameWidget(
              widget.player,
              mainStyle: const TextStyle(
                fontSize: 18,
                color: CustomTheme.textColor,
                fontWeight: FontWeight.w500,
              ),
              countStyle: TextStyle(
                fontSize: 16,
                color: CustomTheme.textColor.withAlpha(100),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_right),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () async {
                      widget.onTap.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 6,
                      ),
                      decoration: CustomTheme.standardBoxDecoration.copyWith(
                        color: CustomTheme.onBoxColor,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.associatedPlayer != null)
                            Flexible(
                              child: widget.isNew
                                  ? Text(
                                      AppLocalizations.of(context)
                                          .create_as_new,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    )
                                  : buildUnitNameWidget(
                                      widget.associatedPlayer!,
                                      mainStyle: const TextStyle(fontSize: 17),
                                      countStyle: TextStyle(
                                        fontSize: 15,
                                        color: CustomTheme.textColor.withAlpha(
                                          100,
                                        ),
                                      ),
                                    ),
                            )
                          else
                            const Icon(Icons.search, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
