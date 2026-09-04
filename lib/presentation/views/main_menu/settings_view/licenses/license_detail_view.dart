import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/licenses/oss_licenses.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:url_launcher/url_launcher.dart';

class LicenseDetailView extends StatelessWidget {
  /// A detailed view displaying information about a software package license.
  /// - [package]: The package data to be displayed.
  const LicenseDetailView({super.key, required this.package});

  /// The package data to be displayed.
  final Package package;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lizenzdetails')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  const ColoredIconContainer(
                    icon: Icons.description,
                    containerSize: 60,
                    iconSize: 30,
                  ),
                  Column(
                    spacing: 2,
                    children: [
                      Text(
                        package.name,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          height: 0,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (package.version != null) ...[
                        Text(
                          'Version ${package.version}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (package.authors.isNotEmpty) ...[
                    SelectableText(
                      package.authors.join(', '),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],

                  if (package.homepage != null &&
                      package.homepage!.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(package.homepage!);
                        await launchUrl(uri, mode: LaunchMode.platformDefault);
                      },
                      child: SizedBox(
                        width: 300,
                        child: Text(
                          package.homepage!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CustomTheme.secondaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: CustomTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (package.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SelectableText(
                  package.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                    height: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: CustomTheme.standardBoxDecoration,
              child: (package.license != null && package.license!.isNotEmpty)
                  ? SelectableText(
                      package.license!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade300,
                        height: 1.5,
                        fontFamily: 'monospace',
                      ),
                    )
                  : Center(
                      heightFactor: 25,
                      child: Text(
                        loc.no_license_text_available,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
