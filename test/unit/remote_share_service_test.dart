import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/share_exceptions.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/services/remote_share_service.dart';
import 'package:tallee/services/shared.dart';

class TestRemoteShareService extends RemoteShareService {
  TestRemoteShareService({super.httpClient});

  @override
  String getApiBaseUrl() => 'https://api.tallee.test';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock asset loading for validateJsonSchema
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final String assetPath =
            const StringCodec().decodeMessage(message) ?? '';
        final file = File(assetPath);
        if (await file.exists()) {
          final content = await file.readAsString();
          return const StringCodec().encodeMessage(content);
        }
        return null;
      });
  group('RemoteShareService', () {
    late Player player1;
    late Player player2;
    late Game game;
    late Match match;

    setUp(() {
      player1 = Player(
        id: 'player-1',
        name: 'Alice',
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );
      player2 = Player(
        id: 'player-2',
        name: 'Bob',
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );
      game = Game(
        id: 'game-1',
        name: 'Uno',
        ruleset: Ruleset.highestScore,
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );
      match = Match(
        id: 'match-1',
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        name: 'Friday Session',
        game: game,
        players: [player1, player2],
        scores: {
          player1.id: ScoreEntry(score: 42),
          player2.id: ScoreEntry(score: 24),
        },
      );
    });

    group('getShareToken', () {
      test('returns token for status 201 and valid payload', () async {
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.toString(), 'https://api.tallee.test/v1/shares/');
          expect(request.headers['content-type'], 'application/json');
          expect(jsonDecode(request.body), equals(match.toJson()));
          return http.Response(
            '{"token":"A1B2C3","ttl_seconds":600,"expires_at":"2026-09-07T22:38:37.065Z"}',
            201,
          );
        });
        final service = TestRemoteShareService(httpClient: client);

        final shareResponse = await service.getShareToken(match);

        expect(shareResponse.token, 'A1B2C3');
        expect(shareResponse.ttlSeconds, 600);
        expect(
          shareResponse.expiresAt,
          DateTime.parse('2026-09-07T22:38:37.065Z').toLocal(),
        );
      });

      test('throws ServerException on non-201 responses', () async {
        final client = MockClient((_) async => http.Response('error', 500));
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getShareToken(match),
          throwsA(
            isA<ServerException>().having(
              (e) => e.statusCode,
              'statusCode',
              500,
            ),
          ),
        );
      });

      test('throws ParsingException when token key is missing', () async {
        final client = MockClient(
          (_) async => http.Response('{"foo":"bar"}', 201),
        );
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getShareToken(match),
          throwsA(isA<ParsingException>()),
        );
      });

      test('throws ParsingException when ttl_seconds is missing', () async {
        final client = MockClient(
          (_) async => http.Response(
            '{"token":"A1B2C3","expires_at":"2026-09-07T22:38:37.065Z"}',
            201,
          ),
        );
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getShareToken(match),
          throwsA(isA<ParsingException>()),
        );
      });

      test('throws ParsingException when expires_at is missing', () async {
        final client = MockClient(
          (_) async =>
              http.Response('{"token":"A1B2C3","ttl_seconds":600}', 201),
        );
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getShareToken(match),
          throwsA(isA<ParsingException>()),
        );
      });

      test('throws ParsingException for malformed JSON', () async {
        final client = MockClient((_) async => http.Response('{not-json', 201));
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getShareToken(match),
          throwsA(isA<ParsingException>()),
        );
      });

      test('throws NetworkException on socket errors', () async {
        final client = MockClient((_) async {
          throw const SocketException('No internet');
        });
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getShareToken(match),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getMatchByToken', () {
      test('returns match for status 200 and valid payload', () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'https://api.tallee.test/v1/shares/share-token',
          );
          return http.Response(jsonEncode({'payload': match.toJson()}), 200);
        });
        final service = TestRemoteShareService(httpClient: client);

        final result = await service.getMatchByToken('share-token');
        final loadedMatch = result.match!;

        expect(loadedMatch.id, match.id);
        expect(loadedMatch.name, match.name);
        expect(loadedMatch.game, match.game);
        expect(loadedMatch.players, match.players);
        expect(loadedMatch.scores, match.scores);
      });

      test('throws ServerException on non-200 responses', () async {
        final client = MockClient((_) async => http.Response('error', 404));
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getMatchByToken('share-token'),
          throwsA(
            isA<ServerException>().having(
              (e) => e.statusCode,
              'statusCode',
              404,
            ),
          ),
        );
      });

      test('throws ParsingException when payload key is missing', () async {
        final client = MockClient(
          (_) async => http.Response('{"token":"abc"}', 200),
        );
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getMatchByToken('share-token'),
          throwsA(isA<ParsingException>()),
        );
      });

      test('throws ParsingException for malformed JSON', () async {
        final client = MockClient((_) async => http.Response('{bad-json', 200));
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getMatchByToken('share-token'),
          throwsA(isA<ParsingException>()),
        );
      });

      test('throws NetworkException on socket errors', () async {
        final client = MockClient((_) async {
          throw const SocketException('Host unreachable');
        });
        final service = TestRemoteShareService(httpClient: client);

        expect(
          () => service.getMatchByToken('share-token'),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });

  group('RemoteShareService.validateContent', () {
    test('returns true for valid content', () {
      final decoded = {
        'name': 'Valid Match',
        'game': {'name': 'Valid Game', 'description': 'Valid Description'},
        'players': [
          {'name': 'Alice'},
        ],
        'group': {'name': 'Valid Group'},
        'teams': [
          {'name': 'Valid Team'},
        ],
      };

      expect(RemoteShareService.validateContent(decoded), isTrue);
    });

    test('returns false when a field exceeds max length', () {
      final decoded = {'name': 'A' * (Constants.MAX_MATCH_NAME_LENGTH + 1)};

      expect(RemoteShareService.validateContent(decoded), isFalse);
    });
  });

  group('validateJsonSchema', () {
    test('validates a conforming match against match_schema.json', () async {
      final p1 = Player(
        id: 'p1',
        name: 'Alice',
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );
      final p2 = Player(
        id: 'p2',
        name: 'Bob',
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );
      final game = Game(
        id: 'g1',
        name: 'Game',
        ruleset: Ruleset.highestScore,
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );

      final matchObj = Match(
        id: 'm1',
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        name: 'Valid Match',
        game: game,
        players: [p1, p2],
        notes: '',
        isTeamMatch: false,
        scores: {
          p1.id: ScoreEntry(roundNumber: 0, score: 0, change: 0),
          p2.id: ScoreEntry(roundNumber: 0, score: 0, change: 0),
        },
      );

      final jsonString = jsonEncode(matchObj.toJson());

      final isValid = await validateJsonSchema(
        jsonString: jsonString,
        schemaAssetPath: 'assets/match_schema.json',
      );
      expect(isValid, isTrue);
    });
  });

  group('RemoteShareService.parseAndValidateMatch', () {
    test(
      'returns invalidSchema when filename is correct but json is not',
      () async {
        final service = RemoteShareService();
        final result = await service.parseAndValidateMatch(
          '{"invalid": true}',
          'test.${Constants.MATCH_FILE_EXTENSION}',
        );

        expect(result.result, ImportResult.invalidSchema);
      },
    );
  });

  group('RemoteShareService.loadMatchFromFile', () {
    test('returns invalidExtension for wrong file extension', () async {
      final service = RemoteShareService();
      final result = await service.loadMatchFromFile('test.json');

      expect(result.result, ImportResult.invalidExtension);
    });
  });
}
