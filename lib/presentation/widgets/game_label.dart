import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/enums.dart';

class GameLabel extends StatelessWidget {
  const GameLabel({
    super.key,
    required this.title,
    required this.description,
    required this.color,
  });

  final String title;
  final String description;
  final AppColor color;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = getColorFromGameColor(color);
    final fontColor = backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Container(
            decoration: BoxDecoration(
              color: backgroundColor.withAlpha(230),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: fontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Description
          Container(
            decoration: BoxDecoration(
              color: backgroundColor.withAlpha(140),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: fontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
