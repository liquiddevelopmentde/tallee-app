import 'package:package_info_plus/package_info_plus.dart';

export 'package:package_info_plus/package_info_plus.dart';

class PackageInfoService {
  static PackageInfo? _info;

  static PackageInfo get info => _info ?? _placeholder;

  static PackageInfo get _placeholder => PackageInfo(
    appName: 'n.A.',
    packageName: 'n.A.',
    version: 'n.A.',
    buildNumber: 'n.A.',
  );

  static Future<void> init() async {
    _info = await PackageInfo.fromPlatform();
  }
}
