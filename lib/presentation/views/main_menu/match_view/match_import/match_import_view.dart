import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';

class MatchImportView extends StatefulWidget {
  const MatchImportView({super.key});

  @override
  State<MatchImportView> createState() => _MatchImportViewState();
}

final MobileScannerController controller = MobileScannerController();

class _MatchImportViewState extends State<MatchImportView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Scan'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: CustomTheme.standardBorderRadiusAll,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width - 10,
                height: MediaQuery.sizeOf(context).height * 0.4,
                child: Stack(
                  children: [
                    ///TODO: See if required or if scanner loads quickly enough
                    const Center(
                      child: CircularProgressIndicator(
                        color: CustomTheme.primaryColor,
                        strokeWidth: 4,
                      ),
                    ),
                    MobileScanner(
                      tapToFocus: true,
                      controller: controller,
                      onDetect: (result) {
                        print(result.barcodes.first.rawValue);
                        controller.pause();
                        showDialog<bool>(
                          context: context,
                          builder: (context) => CustomAlertDialog(
                            title: 'Save match to device?',
                            content: const Text(
                              'The match named x and the game, all x players and x groups attached to it will be saved to your Tallee instance.',
                            ),
                            actions: [
                              CustomDialogAction(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                text: 'Save',
                              ),
                              CustomDialogAction(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                buttonType: ButtonType.secondary,
                                text: 'Cancel',
                              ),
                            ],
                          ),
                        ).then((confirmed) async {
                          //save
                          if (confirmed == true && context.mounted) {
                            ///TODO: Handle Player/Group/Game/Match creation
                          } else {
                            ///TODO: Handle scan restart
                            await controller.start();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: CustomTheme.onBoxColor,
                border: Border.all(color: CustomTheme.boxBorderColor, width: 2),
                borderRadius: CustomTheme.standardBorderRadiusAll,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
              child: const Text(
                'Scan the QR Code of another Tallee instance to receive the shared match.',
                style: TextStyle(color: CustomTheme.textColor, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
