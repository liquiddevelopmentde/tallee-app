import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/duration_utils.dart';

void main() {
  group('formatTimer', () {
    test('formats seconds below one minute', () {
      expect(formatTimer(0), '0s');
      expect(formatTimer(1_000), '1s');
      expect(formatTimer(59_999), '59s');
    });

    test('rolls into minutes', () {
      expect(formatTimer(60_000), '1:00');
      expect(formatTimer(65_000), '1:05');
      expect(formatTimer(3_599_000), '59:59');
    });

    test('rolls into hours', () {
      expect(formatTimer(3_600_000), '1:00:00');
      expect(formatTimer(3_723_000), '1:02:03');
    });

    test('clamps negatives', () {
      expect(formatTimer(-5_000), '0s');
    });
  });
}
