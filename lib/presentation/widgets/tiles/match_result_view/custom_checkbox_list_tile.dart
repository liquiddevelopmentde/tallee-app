import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/haptics.dart';
import 'package:tallee/core/theme/app_colors.dart';

class CustomCheckboxListTile extends StatelessWidget {
  const CustomCheckboxListTile({
    super.key,
    required this.content,
    required this.value,
    required this.onChanged,
  });

  final Widget content;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Haptics.selectionClick();
      onChanged(!value);
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.only(left: 2, right: 5),
      decoration: BoxDecoration(
        color: context.talleeColors.boxColor,
        border: Border.all(color: context.talleeColors.boxBorderColor),
        borderRadius: AppColors.standardBorderRadiusAll,
      ),
      child: Row(
        children: [
          Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            value: value,
            onChanged: (bool? v) {
              Haptics.selectionClick();
              if (v == null) return;
              onChanged(v);
            },
          ),
          Expanded(child: content),
        ],
      ),
    ),
  );
}
