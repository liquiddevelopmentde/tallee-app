import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';

class CodeView extends StatelessWidget {
  const CodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: charContainer('A')),
              const SizedBox(width: 8),
              Expanded(child: charContainer('A')),
              const SizedBox(width: 8),
              Expanded(child: charContainer('A')),
              const SizedBox(width: 8),
              Expanded(child: charContainer('A')),
              const SizedBox(width: 8),
              Expanded(child: charContainer('A')),
              const SizedBox(width: 8),
              Expanded(child: charContainer('A')),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomTheme.boxColor,
            border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: const Text(
            'Send this code to a person who also has Tallee to share the current match.',
            style: TextStyle(
              color: CustomTheme.textColor,
              fontSize: 14,
              overflow: TextOverflow.visible,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimatedButton(
              text: 'Copy Code',
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'A6K1FJ')).then((
                  _,
                ) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(message: 'Code copied to clipboard'),
                    );
                  }
                });
              },
              icon: Icons.copy,
            ),
            SizedBox(width: 5),
            FloatingAnimatedButton(
              text: "",
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text: "Copy my Tallee match! Code: A6K1FJ",
                    title: "Talle Match Share",
                    subject: "Talle Match Share",
                  ),
                );
              },
              icon: Icons.share,
            ),
          ],
        ),
      ],
    );
  }

  Widget charContainer(String char) {
    return Container(
      alignment: Alignment.center,
      decoration: CustomTheme.standardBoxDecoration,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        char,
        style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
      ),
    );
  }
}
