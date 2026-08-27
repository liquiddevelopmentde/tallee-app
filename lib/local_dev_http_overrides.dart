import 'dart:io';

/// Diese Klasse erlaubt es, SSL-Zertifikatsprüfungen zu umgehen.
/// Dies ist für die lokale Entwicklung nützlich, wenn mit selbstsignierten
/// Zertifikaten gearbeitet wird.
class LocalDevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
