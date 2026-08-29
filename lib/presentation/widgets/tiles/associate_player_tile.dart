import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/presentation/utils/name_display.dart';

class AssociatePlayerTile extends StatefulWidget {
  const AssociatePlayerTile({
    required this.player,
    this.associatedPlayer,
    required this.onTap,
    this.borderColor,
    super.key,
  });

  final Player player;

  final Player? associatedPlayer;

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
          Expanded(
            child: Row(
              children: [
                const Spacer(),
                GestureDetector(
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
                          buildUnitNameWidget(
                            widget.associatedPlayer!,
                            mainStyle: const TextStyle(fontSize: 17),
                            countStyle: TextStyle(
                              fontSize: 15,
                              color: CustomTheme.textColor.withAlpha(100),
                            ),
                          )
                        else
                          const Icon(Icons.add, color: Colors.red),
                      ],
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
