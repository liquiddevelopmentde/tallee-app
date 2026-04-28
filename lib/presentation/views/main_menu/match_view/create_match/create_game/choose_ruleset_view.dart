import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/tiles/title_description_list_tile.dart';

class ChooseRulesetView extends StatefulWidget {
  /// A view that allows the user to choose a ruleset from a list of available rulesets
  /// - [rulesets]: A list of tuples containing the ruleset and its description
  /// - [initialRulesetIndex]: The index of the initially selected ruleset
  const ChooseRulesetView({
    super.key,
    required this.rulesets,
    required this.initialRulesetIndex,
  });

  /// A list of tuples containing the ruleset and its description
  final List<(Ruleset, String)> rulesets;

  /// The index of the initially selected ruleset
  final int initialRulesetIndex;
  @override
  State<ChooseRulesetView> createState() => _ChooseRulesetViewState();
}

class _ChooseRulesetViewState extends State<ChooseRulesetView> {
  /// Currently selected ruleset index
  late int selectedRulesetIndex;

  @override
  void initState() {
    selectedRulesetIndex = widget.initialRulesetIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: CustomTheme.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop(
                selectedRulesetIndex == -1
                    ? null
                    : widget.rulesets[selectedRulesetIndex].$1,
              );
            },
          ),
          title: Text(loc.choose_ruleset),
        ),
        body: PopScope(
          // This fixes that the Android Back Gesture didn't return the
          // selectedRulesetIndex and therefore the selected Ruleset wasn't saved
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) {
              return;
            }
            Navigator.of(context).pop(
              selectedRulesetIndex == -1
                  ? null
                  : widget.rulesets[selectedRulesetIndex].$1,
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 85),
            itemCount: widget.rulesets.length,
            itemBuilder: (BuildContext context, int index) {
              return TitleDescriptionListTile(
                onTap: () async {
                  setState(() {
                    if (selectedRulesetIndex == index) {
                      selectedRulesetIndex = -1;
                    } else {
                      selectedRulesetIndex = index;
                    }
                  });
                },
                title: translateRulesetToString(
                  widget.rulesets[index].$1,
                  context,
                ),
                description: widget.rulesets[index].$2,
                isHighlighted: selectedRulesetIndex == index,
              );
            },
          ),
        ),
      ),
    );
  }
}
