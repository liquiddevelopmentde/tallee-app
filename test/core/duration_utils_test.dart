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

  group('effectiveTimerMs', () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);

    test('returns only the base value when stopped', () {
      expect(
        effectiveTimerMs(baseMs: 12_000, timerStartedAt: null, now: now),
        12_000,
      );
    });

    test('adds the elapsed time when running', () {
      expect(
        effectiveTimerMs(
          baseMs: 5_000,
          timerStartedAt: now.subtract(const Duration(seconds: 90)),
          now: now,
        ),
        95_000,
      );
    });

    test('returns the base value when the timer just started', () {
      expect(
        effectiveTimerMs(baseMs: 5_000, timerStartedAt: now, now: now),
        5_000,
      );
    });
  });
}
