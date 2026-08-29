import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

/// The header of a form section: a bold [title] with an optional smaller
/// [description] below it, aligned with the boxed control beneath.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.description = ''});

  /// The bold section title.
  final String title;

  /// The smaller description below the [title].
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CustomTheme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(
                color: CustomTheme.textColor,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

/// A titled form section in the style of the create statistics view: a bold
/// title with an optional description above a boxed control. All sections use
/// the same horizontal padding so they line up inside a [FormPanel].
class LabeledSection extends StatelessWidget {
  const LabeledSection({
    super.key,
    required this.title,
    this.description = '',
    required this.control,
    this.controlPadding,
  });

  /// The bold section title.
  final String title;

  /// The smaller description below the [title].
  final String description;

  /// The boxed control (dropdown, text field, value tile, ...).
  final Widget control;

  /// Padding around the [control]. Defaults to the standard 16/8 inset.
  final EdgeInsetsGeometry? controlPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, description: description),
        Padding(
          padding:
              controlPadding ??
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: control,
        ),
      ],
    );
  }
}
