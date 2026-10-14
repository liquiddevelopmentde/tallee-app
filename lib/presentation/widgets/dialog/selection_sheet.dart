import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/constants/value_constants.dart';
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
  }) : selectedValues = const [],
       onValuesUpdated = null,
       isMultiSelection = false;

  /// Generic sheet to select multiple values from a list.
  ///
  /// - [title]: The title shown on the top of the sheet
  /// - [description]: The description shown under the title
  /// - [values]: The values to choose from
  /// - [selectedValues]: A list of pre selected values when opening the sheet
  /// - [onValuesUpdated]: A callback when values are selected
  /// - [labelBuilder]: The builder for the text label
  /// - [leadingBuilder]: The builder for the leading Widget
  const SelectionSheet.multiple({
    super.key,
    required this.title,
    required this.description,
    required this.values,
    required this.selectedValues,
    required this.onValuesUpdated,
    required this.labelBuilder,
    this.leadingBuilder,
  }) : selectedValue = null,
       onValueUpdated = null,
       isMultiSelection = true;

  final String title;
  final String description;
  final List<T> values;

  final String Function(BuildContext context, T value) labelBuilder;
  final Widget Function(T value)? leadingBuilder;

  final T? selectedValue;
  final ValueChanged<T?>? onValueUpdated;

  final List<T> selectedValues;
  final ValueChanged<List<T>>? onValuesUpdated;

  // To decide between single and multi selection
  final bool isMultiSelection;

  static void show({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) {
    showModalBottomSheet(
      context: context,
      builder: builder,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOutCubicEmphasized,
        reverseCurve: Curves.easeInOut,
        reverseDuration: Duration(milliseconds: 300),
      ),
      showDragHandle: true,
      backgroundColor: CustomTheme.boxColor,
      isScrollControlled: true,
    );
  }

  @override
  State<SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<SelectionSheet<T>> {
  T? selectedValue;
  List<T> selectedValues = [];

  @override
  void initState() {
    selectedValue = widget.selectedValue;
    selectedValues = widget.selectedValues;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(right: 6, left: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          // Title & description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              spacing: 5,
              children: [
                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
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
                    onTap: () => valueChangeFunction(value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: CustomTheme.boxColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CustomTheme.boxBorderColor,
                          width: 2,
                        ),
                      ),
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

                          if (!widget.isMultiSelection)
                            // Radio
                            Radio<T>(
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return CustomTheme.textColor;
                                  }
                                  return CustomTheme.hintColor;
                                },
                              ),
                              value: value,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            )
                          else
                            // Checkbox
                            Checkbox(
                              value: selectedValues.contains(value),
                              onChanged: (_) => onValuesChanged(value),
                              checkColor: CustomTheme.backgroundColor,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return CustomTheme.textColor;
                                  }
                                  return Colors.transparent;
                                },
                              ),
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
      ),
    );
  }

  void onValueChanged(T? value) {
    setState(() => selectedValue = value);
    widget.onValueUpdated?.call(value);
  }

  void onValuesChanged(T value) {
    setState(
      () => selectedValues.contains(value)
          ? selectedValues.remove(value)
          : selectedValues.add(value),
    );
    widget.onValuesUpdated?.call(selectedValues);
  }

  Future<void> valueChangeFunction(T value) async {
    widget.isMultiSelection ? onValuesChanged(value) : onValueChanged(value);
    if (!widget.isMultiSelection) {
      await Future.delayed(MINIMUM_SKELETON_DURATION).then((_) {
        if (!mounted) return;
        Navigator.of(context)
            .pop(selectedValues.isEmpty ? null : selectedValues.first);
      });
    }
  }
}
