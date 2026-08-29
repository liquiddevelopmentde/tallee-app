import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

/// A bordered form panel used by the create/edit views, matching the look of
/// the create statistics view.
class FormPanel extends StatelessWidget {
  const FormPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: CustomTheme.boxColor,
        border: Border.all(color: CustomTheme.boxBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
