import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/settings_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';
import 'package:tallee/presentation/widgets/top_centered_message.dart';

class TokenView extends StatelessWidget {
  const TokenView({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.shareToken,
    required this.isLoading,
    required this.serverSharingEnabled,
    required this.onOnlineSharingPrefChanged,
  });

  final int secondsRemaining;
  final int totalSeconds;
  final String? shareToken;
  final bool isLoading;
  final bool serverSharingEnabled;
  final VoidCallback onOnlineSharingPrefChanged;

  @override
  Widget build(BuildContext context) {
    final double progress = secondsRemaining / totalSeconds;
    final int minutes = secondsRemaining ~/ 60;
    final int seconds = secondsRemaining % 60;

    final String displayCode = shareToken ?? 'XXXXXX';
    final List<String> chars = displayCode.split('');

    return !serverSharingEnabled
        ? Column(
            children: [
              const TopCenteredMessage(
                title: 'Online sharing is disabled',
                message: 'Go to the settings to manually enable it.',
                icon: Icons.close,
              ),
              const SizedBox(height: 20),
              FloatingAnimatedButton(
                text: 'Open Settings',
                icon: Icons.settings,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    adaptivePageRoute(
                      builder: (context) => const SettingsView(),
                    ),
                  );
                  onOnlineSharingPrefChanged.call();
                },
              ),
            ],
          )
        : Column(
            children: [
              const SizedBox(height: 50),
              Column(
                children: [
                  const Icon(Icons.cloud_upload, size: 50),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: const Text(
                      'Send this code to a person who also has Tallee to share the current match.',
                      style: TextStyle(
                        color: CustomTheme.textColor,
                        fontSize: 16,
                        overflow: TextOverflow.visible,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: AppSkeleton(
                  enabled: isLoading,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 6; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: charContainer(
                            chars.length > i ? chars[i] : ' ',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: CustomTheme.onBoxColor,
                    color: CustomTheme.primaryColor,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                minutes == 0 && seconds == 0
                    ? 'Code expired'
                    : 'Expires in ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: CustomTheme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingAnimatedButton(
                    text: 'Copy Code',
                    onPressed: isLoading
                        ? null
                        : () {
                            Clipboard.setData(
                              ClipboardData(text: displayCode),
                            ).then((_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  CustomSnackBar(
                                    message: 'Code copied to clipboard',
                                  ),
                                );
                              }
                            });
                          },
                    icon: Icons.copy,
                  ),
                  const SizedBox(width: 5),
                  FloatingAnimatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            SharePlus.instance.share(
                              ShareParams(
                                text:
                                    'Here is the match data for our game! Enter code $displayCode in Tallee.',
                                title: 'Tallee Match Share',
                                subject: 'Tallee Match Share',
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
        style: const TextStyle(
          fontSize: 35, //war mal 45
          fontWeight: FontWeight.w400,
          color: CustomTheme.textColor,
        ),
      ),
    );
  }
}
