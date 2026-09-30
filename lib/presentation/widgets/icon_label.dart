import 'package:flutter/cupertino.dart';
import 'package:tallee/core/custom_theme.dart';

class IconLabel extends StatelessWidget {
  const IconLabel({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  final String text;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.12) ?? CustomTheme.onBoxColor,
        border: Border.all(
          color: color?.withValues(alpha: 0.35) ?? CustomTheme.boxBorderColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Icon(icon, size: 20, color: color ?? CustomTheme.hintColor),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? CustomTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
