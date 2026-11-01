import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';

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
    final backgroundColor = context.talleeColors.onBoxColor;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
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
                style: TextStyle(
                  fontSize: 14,
                  color: context.talleeColors.textColor,
                ),
              ),
            ),
          ),

          // Count
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
                  style: TextStyle(
                    fontSize: 14,
                    color: context.talleeColors.textColor,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.people,
                  size: 20,
                  color: context.talleeColors.textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
