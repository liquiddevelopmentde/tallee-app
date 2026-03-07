import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/licenses/license_detail_view.dart';
import 'package:tallee/presentation/views/main_menu/settings_view/licenses/oss_licenses.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';

class LicenseTile extends StatelessWidget {
  /// A tile widget that displays information about a software package license.
  /// - [package]: The package data to be displayed.
  const LicenseTile({super.key, required this.package});

  /// The package data to be displayed.
  final Package package;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LicenseDetailView(package: package),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: CustomTheme.standardBoxDecoration.copyWith(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const ColoredIconContainer(
              icon: Icons.description,
              containerSize: 50,
              iconSize: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          package.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (package.version != null &&
                          package.version!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CustomTheme.onBoxColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'v${package.version}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Arrow Icon
            Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 24),
          ],
        ),
      ),
    );
  }
}
