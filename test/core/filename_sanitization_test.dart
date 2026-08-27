import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/common.dart';

void main() {
  group('FilenameSanitization extension', () {
    test('should replace spaces with underscores', () {
      expect('Match Name'.toSafeFilename(), 'Match_Name');
    });

    test('should normalize German umlauts', () {
      expect('Mätch mit Ümläuten'.toSafeFilename(), 'Maetch_mit_Uemlaeuten');
      expect('Großes Spiel'.toSafeFilename(), 'Grosses_Spiel');
    });

    test('should remove illegal filesystem characters', () {
      expect('Match/Name?'.toSafeFilename(), 'MatchName');
      expect('File: <*|*>?'.toSafeFilename(), 'File_');
    });

    test('should keep dots, underscores, and hyphens', () {
      expect('file.name_v1-final'.toSafeFilename(), 'file.name_v1-final');
    });

    test('should handle empty or special character only strings with fallback', () {
      expect(''.toSafeFilename(), 'match');
      expect('!@#%^&*()'.toSafeFilename(), 'match');
      expect('🔥🔥🔥'.toSafeFilename(fallback: 'custom'), 'custom');
    });

    test('should strip emojis from mixed strings', () {
      expect('Match 🔥'.toSafeFilename(), 'Match_');
    });

    test('should handle mixed cases correctly', () {
      expect('ÄÖÜß'.toSafeFilename(), 'AeOeUess');
    });
  });
}
