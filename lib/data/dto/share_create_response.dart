import 'package:tallee/core/share_exceptions.dart';

class ShareCreateResponse {
  final String token;
  final int ttlSeconds;
  final DateTime expiresAt;

  const ShareCreateResponse({
    required this.token,
    required this.ttlSeconds,
    required this.expiresAt,
  });

  factory ShareCreateResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    final ttlSeconds = json['ttl_seconds'] as int?;
    final expiresAtRaw = json['expires_at'] as String?;

    if (token == null || ttlSeconds == null || expiresAtRaw == null) {
      throw ParsingException();
    }

    final DateTime expiresAt;
    try {
      expiresAt = DateTime.parse(expiresAtRaw).toLocal();
    } catch (_) {
      throw ParsingException();
    }

    return ShareCreateResponse(
      token: token,
      ttlSeconds: ttlSeconds,
      expiresAt: expiresAt,
    );
  }
}
