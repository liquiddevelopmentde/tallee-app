import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';

class SelectionSheet<T> extends StatefulWidget {
  /// Generic sheet to select a single value from a list.
  ///
  /// - [title]: The title shown on the top of the sheet
  /// - [description]: The description shown under the title
  /// - [values]: The values to choose from
  /// - [selectedValue]: A pre selected value when opening the sheet
  /// - [onValueUpdated]: A callback when a value is selected
  /// - [labelBuilder]: The builder for the text label
  /// - [leadingBuilder]: The builder for the leading Widget
  const SelectionSheet({
    super.key,
    required this.title,
    required this.description,
    required this.values,
    required this.selectedValue,
    required this.onValueUpdated,
    required this.labelBuilder,
    this.leadingBuilder,
  });

  final String title;
  final String description;
  final List<T> values;
  final T? selectedValue;
  final ValueChanged<T?> onValueUpdated;
  final String Function(BuildContext context, T value) labelBuilder;
  final Widget Function(T value)? leadingBuilder;

  @override
  State<SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<SelectionSheet<T>> {
  T? selectedValue;

  @override
  void initState() {
    selectedValue = widget.selectedValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        // Title & description
        Column(
          spacing: 5,
          children: [
            // Title
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            // Description
            Text(
              widget.description,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              style: const TextStyle(color: CustomTheme.hintColor),
            ),
          ],
        ),

        // Values
        Flexible(
          child: RadioGroup<T>(
            groupValue: selectedValue,
            onChanged: onValueChanged,
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: widget.values.length,
              itemBuilder: (BuildContext context, int index) {
                final value = widget.values[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onValueChanged(value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 14,
                    ),
                    decoration: CustomTheme.standardBoxDecoration,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 12,
                          children: [
                            // Leading widget
                            if (widget.leadingBuilder != null)
                              widget.leadingBuilder!(value),

                            // Label
                            Text(widget.labelBuilder(context, value)),
                          ],
                        ),

                        // Radio
                        Radio<T>(
                          fillColor: WidgetStateProperty.resolveWith<Color>((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return CustomTheme.textColor;
                            }
                            return CustomTheme.hintColor;
                          }),
                          value: value,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void onValueChanged(T? value) {
    setState(() => selectedValue = value);
    widget.onValueUpdated(value);
  }
}
