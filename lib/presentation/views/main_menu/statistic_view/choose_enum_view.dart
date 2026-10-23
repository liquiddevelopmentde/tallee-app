import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/constants.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

class ChooseEnumView<T extends Enum> extends StatefulWidget {
  /// A view that allows the user to choose an enum value from a list of enum values.
  /// - [enumValue]: A list of available enum values to choose from
  /// - [initialEnum]: The initially selected enum value
  /// - [enableMultiSelection]: Whether multiple enum values can be selected
  const ChooseEnumView({
    super.key,
    required this.enumValue,
    this.initialEnums,
    this.enableMultiSelection = false,
  });

  final List<T> enumValue;
  final List<T>? initialEnums;
  final bool enableMultiSelection;

  @override
  State<ChooseEnumView<T>> createState() => _ChooseEnumViewState<T>();
}

class _ChooseEnumViewState<T extends Enum> extends State<ChooseEnumView<T>> {
  final TextEditingController controller = TextEditingController();

  late List<T> selectedValues;

  @override
  void initState() {
    selectedValues = widget.initialEnums ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.talleeColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(getTitle(widget.enumValue.first, loc))),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop(popResult);
        },
        child: RadioGroup(
          onChanged: (T? value) => onChanged(value!),
          child: ListView.separated(
            padding: const EdgeInsets.only(
              bottom: 85,
              top: 10,
              right: 10,
              left: 10,
            ),
            itemCount: widget.enumValue.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) => GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: context.talleeColors.boxColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.talleeColors.boxBorderColor,
                    width: 2,
                  ),
                ),
                duration: const Duration(milliseconds: 150),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        if (widget.enumValue is List<StatisticType>)
                          Icon(
                            getTypeIcon(
                              type: widget.enumValue[index] as StatisticType,
                            ),
                          ),
                        Text(
                          getValName(widget.enumValue[index], context),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    if (!isMultiSelect)
                      // Radio
                      Radio<T>(
                        fillColor: WidgetStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return context.talleeColors.textColor;
                          }
                          return context.talleeColors.hintColor;
                        }),
                        value: widget.enumValue[index],
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )
                    else
                      // Checkbox
                      Checkbox(
                        value: selectedValues.contains(widget.enumValue[index]),
                        onChanged: (_) => onChanged(widget.enumValue[index]),
                        checkColor: context.talleeColors.backgroundColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        fillColor: WidgetStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return context.talleeColors.textColor;
                          }
                          return Colors.transparent;
                        }),
                      ),
                  ],
                ),
              ),
              onTap: () => onChanged(widget.enumValue[index]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onChanged(T value) async {
    setState(() {
      if (selectedValues.contains(value)) {
        selectedValues.removeWhere((val) => val == value);
      } else {
        // In single select mode only allow one item
        if (!isMultiSelect) {
          selectedValues.clear();
        }
        selectedValues.add(value);
      }
    });

    // Navigate back to create match view instantly
    if (!isMultiSelect) {
      await Future.delayed(MINIMUM_SKELETON_DURATION).then((_) {
        if (!mounted) return;
        Navigator.of(context)
            .pop(selectedValues.isEmpty ? null : selectedValues.first);
      });
    }
  }

  bool get isMultiSelect => widget.enableMultiSelection;

  Object? get popResult {
    if (isMultiSelect) return selectedValues;
    return selectedValues.isEmpty ? null : selectedValues.first;
  }

  /// Calls the correct translation function depending on the enum.
  /// Returns the localized string translation of the value
  String getValName(T value, BuildContext context) {
    if (value is StatisticScope) {
      return translateScopeToString(value, context);
    } else if (value is StatisticType) {
      return translateStatisticTypeToString(value, context);
    } else if (value is Timeframe) {
      return translateTimeframeToString(value, context);
    } else {
      return value.toString();
    }
  }

  /// Returns the correct view title depending on the enum.
  String getTitle(T value, AppLocalizations loc) {
    if (value is StatisticScope) {
      return loc.choose_scopes;
    } else if (value is StatisticType) {
      return loc.choose_types;
    } else if (value is Timeframe) {
      return loc.choose_timeframes;
    } else {
      return '';
    }
  }

  String getHintText(T value, AppLocalizations loc) {
    if (value is StatisticScope) {
      return loc.search_for_scopes;
    } else if (value is StatisticType) {
      return loc.search_for_types;
    } else if (value is Timeframe) {
      return loc.search_for_timeframes;
    } else {
      return '';
    }
  }
}
