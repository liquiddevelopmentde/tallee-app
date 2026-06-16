import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';

class EnterTokenView extends StatefulWidget {
  const EnterTokenView({super.key});

  @override
  State<EnterTokenView> createState() => _EnterTokenViewState();
}

class _EnterTokenViewState extends State<EnterTokenView> {
  TextEditingController tokenInputFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Pinput(
            controller: tokenInputFieldController,
            length: 6,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            hapticFeedbackType: HapticFeedbackType.selectionClick,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: false,
            onCompleted: (pin) => print(pin),
            validator: (s) {
              return s == 'AAAA' ? null : 'pin incorrect';
            },
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomTheme.boxColor,
            border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
            borderRadius: CustomTheme.standardBorderRadiusAll,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: const Text(
            'Input a match share code another person created using Tallee to import the match.',
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
              text: 'Import match',
              onPressed: null,
              icon: Icons.cloud,
            ),
            const SizedBox(width: 5),
            FloatingAnimatedButton(
              onPressed: () async {
                ClipboardData? data = await Clipboard.getData('text/plain');
                if (data != null && data.text != null) {
                  tokenInputFieldController.text = data.text!;
                }
              },
              icon: Icons.paste,
            ),
          ],
        ),
      ],
    );
  }
}
