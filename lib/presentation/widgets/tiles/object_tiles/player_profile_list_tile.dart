import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class PlayerProfileListTile extends StatelessWidget {
  const PlayerProfileListTile({
    super.key,
    required this.title,
    required this.count,
    this.onTap,
  });

  final String title;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = CustomTheme.onBoxColor;
    final fontColor = backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Flexible(
            child: Container(
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(fontSize: 14, color: fontColor),
              ),
            ),
          ),

          // Description
          Container(
            decoration: BoxDecoration(
              color: backgroundColor.withAlpha(180),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: 14, color: fontColor),
                ),
                const SizedBox(width: 5),
                Icon(Icons.people, size: 20, color: fontColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
