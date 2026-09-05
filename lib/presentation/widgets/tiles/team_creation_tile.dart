import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';

class TeamCreationTile extends StatefulWidget {
  const TeamCreationTile({
    super.key,
    required this.color,
    required this.controller,
    required this.hintText,
    this.onDelete,
    this.onColorSelection,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final AppColor color;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onDelete;
  final ValueChanged<AppColor>? onColorSelection;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<TeamCreationTile> createState() => _TeamCreationTileState();
}

class _TeamCreationTileState extends State<TeamCreationTile> {
  final teamColors = List.generate(
    AppColor.values.length,
    (index) => getTeamColor(index),
  );

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      margin: CustomTheme.standardMargin,
      decoration: CustomTheme.standardBoxDecoration,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name input + delete icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextInputField(
                            controller: widget.controller,
                            hintText: widget.hintText,
                            maxLength: Constants.MAX_TEAM_NAME_LENGTH,
                            focusNode: widget.focusNode,
                            textInputAction: widget.textInputAction,
                            onSubmitted: widget.onSubmitted,
                          ),
                        ),
                        HapticIconButton(
                          icon: const Icon(FontAwesome.trash),
                          onPressed: widget.onDelete,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Color label
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        loc.color,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: CustomTheme.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Color picker
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: teamColors.map((color) {
                          final isSelected = widget.color == color;
                          return GestureDetector(
                            onTap: () {
                              widget.onColorSelection?.call(color);
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: getColorFromAppColor(color),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
