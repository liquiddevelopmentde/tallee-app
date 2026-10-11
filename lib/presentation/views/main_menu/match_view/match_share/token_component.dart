import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/settings_view.dart';
import 'package:tallee/presentation/widgets/app_skeleton.dart';
import 'package:tallee/presentation/widgets/buttons/floating_animated_button.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';

class TokenComponent extends StatelessWidget {
  const TokenComponent({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.shareToken,
    required this.isLoading,
    required this.serverSharingEnabled,
    required this.onOnlineSharingPrefChanged,
    required this.renewToken,
  });

  final int secondsRemaining;
  final int totalSeconds;
  final String? shareToken;
  final bool isLoading;
  final bool serverSharingEnabled;
  final VoidCallback onOnlineSharingPrefChanged;
  final VoidCallback renewToken;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final double progress = secondsRemaining / totalSeconds;
    final int minutes = secondsRemaining ~/ 60;
    final int seconds = secondsRemaining % 60;

    final String displayCode = shareToken ?? 'ABC123';
    final List<String> chars = displayCode.split('');

    if (serverSharingEnabled) {
      return Column(
        spacing: 20,
        children: [
          const SizedBox(height: 30),

          // Info text
          Column(
            spacing: 20,
            children: [
              const Icon(Icons.cloud_upload, size: 50),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  loc.send_code_instruction,
                  style: const TextStyle(
                    color: CustomTheme.textColor,
                    fontSize: 16,
                    overflow: TextOverflow.visible,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ],
          ),

          // Char container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: AppSkeleton(
              enabled: isLoading,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 6; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: charContainer(
                        char: chars.length > i ? chars[i] : ' ',
                        active: secondsRemaining > 0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          Column(
            children: [
              // TTL progress bar
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

              SizedBox(height: secondsRemaining == 0 ? 10 : 20),

              // TTL remaining display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    secondsRemaining == 0
                        ? loc.token_expired
                        : loc.expires_in(
                            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          ),
                    style: const TextStyle(
                      color: CustomTheme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      overflow: TextOverflow.visible,
                    ),
                    softWrap: true,
                  ),

                  // Refresh countdown button
                  if (secondsRemaining == 0)
                    HapticIconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: CustomTheme.primaryColor,
                        size: 25,
                      ),
                      onPressed: renewToken,
                    ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Button row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              // Copy code button
              FloatingAnimatedButton(
                text: loc.copy_code,
                onPressed: isLoading
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: displayCode))
                            .then((_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  CustomSnackBar(message: loc.code_copied),
                                );
                              }
                            });
                      },
                icon: Icons.copy,
              ),

              // Share code button
              FloatingAnimatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: loc.share_match_text(displayCode),
                            title: loc.share_match_title,
                            subject: loc.share_match_title,
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

    // Online service deactivated
    return Column(
      spacing: 20,
      children: [
        const SizedBox(height: 30),

        // Icon + Message
        Column(
          spacing: 20,
          children: [
            // Icon
            const Icon(Icons.cloud_off, size: 50),

            // Message
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    loc.online_sharing_disabled,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Text(
                    loc.share_as_token_info,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      overflow: TextOverflow.visible,
                      color: CustomTheme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Char container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: charContainer(
                    active: false,
                    char: chars.length > i ? chars[i] : ' ',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 30),

        const Spacer(),

        // Open Settings button
        FloatingAnimatedButton(
          text: loc.open_settings,
          icon: Icons.settings,
          onPressed: () async {
            await Navigator.push(
              context,
              adaptivePageRoute(builder: (context) => const SettingsView()),
            );
            onOnlineSharingPrefChanged.call();
          },
        ),
      ],
    );
  }

  Widget charContainer({String char = '', required bool active}) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? CustomTheme.boxColor
            : CustomTheme.boxBorderColor.withAlpha(100),
        border: Border.all(color: CustomTheme.boxBorderColor),
        borderRadius: CustomTheme.standardBorderRadiusAll,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        char,
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.w400,
          color: active ? CustomTheme.textColor : CustomTheme.boxBorderColor,
        ),
      ),
    );
  }
}
