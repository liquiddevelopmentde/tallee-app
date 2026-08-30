import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/dropdown/dropdown_option.dart';

export 'dropdown_option.dart';

/// A titled dropdown section with a consistent style.
///
/// Supports both single-select (default constructor) and multi-select
/// (checkbox) mode via [LabeledDropdown.multi].
///
/// In multi-select mode the widget only renders the current selection from
/// [multiValueListenable] and reports the tapped value through [onItemTap];
/// the caller is responsible for updating the listenable. This keeps any
/// domain-specific selection rules (e.g. mutually exclusive options) in the
/// owning view.
class LabeledDropdown<T> extends StatelessWidget {
  /// Creates a single-select dropdown.
  const LabeledDropdown({
    super.key,
    required this.title,
    required this.description,
    required this.hintText,
    required this.options,
    required ValueListenable<T> this.valueListenable,
    required void Function(T?) this.onChanged,
    this.enabled = true,
    this.selectedItemBuilder,
    this.bottomPadding,
  }) : isMultiSelect = false,
       multiValueListenable = null,
       onItemTap = null;

  /// Creates a multi-select (checkbox) dropdown.
  const LabeledDropdown.multi({
    super.key,
    required this.title,
    required this.description,
    required this.hintText,
    required this.options,
    required ValueListenable<List<T>> this.multiValueListenable,
    required void Function(T) this.onItemTap,
    this.enabled = true,
    this.bottomPadding,
  }) : isMultiSelect = true,
       valueListenable = null,
       onChanged = null,
       selectedItemBuilder = null;

  /// The bold section title.
  final String title;

  /// The smaller description below the [title].
  final String description;

  /// The placeholder shown when nothing is selected.
  final String hintText;

  /// The available options.
  final List<DropdownOption<T>> options;

  /// Whether the dropdown can be interacted with.
  final bool enabled;

  /// Whether this dropdown is in multi-select mode.
  final bool isMultiSelect;

  /// The current value in single-select mode.
  final ValueListenable<T>? valueListenable;

  /// Called with the new value in single-select mode.
  final void Function(T?)? onChanged;

  /// The current selection in multi-select mode.
  final ValueListenable<List<T>>? multiValueListenable;

  /// Called with the tapped value in multi-select mode.
  final void Function(T)? onItemTap;

  /// Optional builder for the selected item(s) shown in the button.
  final DropdownButtonBuilder? selectedItemBuilder;

  /// Optional padding at the bottom of the dropdown.
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final listenable = multiValueListenable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: CustomTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.visible,
                ),
              ),
              Text(
                description,
                textAlign: TextAlign.start,
                softWrap: true,
                style: const TextStyle(
                  color: CustomTheme.textColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Dropdown
        Padding(
          padding: EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
            bottom: bottomPadding ?? 8,
          ),
          child: DropdownButtonHideUnderline(
            child: isMultiSelect
                ? DropdownButton2<T>(
                    isExpanded: true,
                    hint: Text(hintText, style: hintStyle),
                    multiValueListenable: listenable,
                    items: options
                        .map(
                          (option) => DropdownItem<T>(
                            value: option.value,
                            height: 44,
                            closeOnTap: false,
                            child: ValueListenableBuilder<List<T>>(
                              valueListenable: listenable!,
                              builder: (context, values, _) {
                                final isSelected = values.contains(
                                  option.value,
                                );
                                return Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_box_outlined
                                          : Icons.check_box_outline_blank,
                                      color: CustomTheme.textColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: optionRow(option)),
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: enabled
                        ? (value) {
                            if (value != null) onItemTap!(value);
                          }
                        : null,
                    selectedItemBuilder: (context) {
                      return options
                          .map(
                            (_) => ValueListenableBuilder<List<T>>(
                              valueListenable: listenable!,
                              builder: (context, values, _) {
                                final selectedLabels = options
                                    .where((o) => values.contains(o.value))
                                    .map((o) => o.label)
                                    .join(', ');
                                return Text(
                                  selectedLabels,
                                  style: values.isEmpty
                                      ? hintStyle
                                      : headerStyle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                );
                              },
                            ),
                          )
                          .toList();
                    },
                    buttonStyleData: buttonStyle,
                    iconStyleData: iconStyle,
                    dropdownStyleData: dropdownStyle,
                    menuItemStyleData: menuStyle,
                  )
                : DropdownButton2<T>(
                    isExpanded: true,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(hintText, style: hintStyle),
                    ),
                    valueListenable: valueListenable,
                    items: options
                        .map(
                          (option) => DropdownItem<T>(
                            value: option.value,
                            height: 44,
                            child: optionRow(option),
                          ),
                        )
                        .toList(),
                    onChanged: enabled ? onChanged : null,
                    buttonStyleData: buttonStyle,
                    iconStyleData: iconStyle,
                    dropdownStyleData: dropdownStyle,
                    menuItemStyleData: menuStyle,
                    selectedItemBuilder: selectedItemBuilder,
                  ),
          ),
        ),
      ],
    );
  }

  Widget optionRow(DropdownOption<T> option) {
    if (option.leading == null) {
      return Text(option.label, style: itemStyle);
    }
    return Row(
      children: [
        option.leading!,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            option.label,
            style: itemStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  TextStyle get headerStyle => const TextStyle(
    color: CustomTheme.textColor,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  TextStyle get itemStyle =>
      const TextStyle(color: CustomTheme.textColor, fontSize: 14);

  TextStyle get hintStyle =>
      const TextStyle(color: CustomTheme.hintColor, fontSize: 14);

  ButtonStyleData get buttonStyle => ButtonStyleData(
    height: 54,
    decoration: BoxDecoration(
      color: CustomTheme.onBoxColor,
      borderRadius: BorderRadius.circular(12),
    ),
  );

  IconStyleData get iconStyle => const IconStyleData(
    iconEnabledColor: CustomTheme.textColor,
    iconDisabledColor: CustomTheme.hintColor,
  );

  MenuItemStyleData get menuStyle =>
      const MenuItemStyleData(padding: EdgeInsets.zero);

  DropdownStyleData get dropdownStyle => DropdownStyleData(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: CustomTheme.boxColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CustomTheme.boxBorderColor, width: 1),
    ),
  );
}
