import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:tallee/core/custom_theme.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.spacing = 0.0,
  });

  final IconData icon;
  final String title;
  final String message;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 100,
      ),
      child: Column(
        spacing: spacing,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: icon == RpgAwesome.clovers_card
                ? const EdgeInsets.only(left: 8.0)
                : EdgeInsets.zero,
            child: Icon(icon, size: 120, color: CustomTheme.hintColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              spacing: 3,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CustomTheme.hintColor,
                    overflow: TextOverflow.visible,
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
