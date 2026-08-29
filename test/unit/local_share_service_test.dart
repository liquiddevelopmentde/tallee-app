import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/services/local_share_service.dart';
import 'package:tallee/services/shared_preferences_service.dart';

void main() {
  late AppDatabase database;
  final fixedDate = DateTime(2025, 11, 19, 0, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Proper Mocking for rootBundle.loadString
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final String assetPath =
              const StringCodec().decodeMessage(message) ?? '';
          final file = File(assetPath);
          final exists = file.existsSync();
          if (exists) {
            final content = file.readAsStringSync();
            return const StringCodec().encodeMessage(content);
          }
          return null;
        });

    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (methodCall) async => '.',
        );

    SharedPreferences.setMockInitialValues({});
    SharedPreferencesService.init();
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<BuildContext> getContext(WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AppDatabase>.value(
        value: database,
        child: MaterialApp(home: Builder(builder: (context) => Container())),
      ),
    );
    return tester.element(find.byType(Container));
  }

  group('LocalShareService Tests', () {
    testWidgets('deleteAllData() works correctly', (tester) async {
      await withClock(fakeClock, () async {
        final p = Player(name: 'Alice');
        final g = Game(
          name: 'Chess',
          ruleset: Ruleset.singleWinner,
          color: AppColor.blue,
          icon: 'icon',
        );
        final m = Match(name: 'Match', game: g, players: [p]);

        await database.playerDao.addPlayer(player: p);
        await database.gameDao.addGame(game: g);
        await database.matchDao.addMatch(match: m);

        final ctx = await getContext(tester);
        await LocalShareService.deleteAllData(ctx);

        expect(await database.playerDao.getPlayerCount(), 0);
      });
    });

    group('JSON Schema and Import', () {
      final validData = {
        'players': [Player(name: 'Alice').toNormalizedJson()],
        'games': [],
        'groups': [],
        'matches': [],
        'statistics': [],
      };
      final validJson = json.encode(validData);

      testWidgets('validateJsonSchema works correctly', (tester) async {
        final isValid = await validateJsonSchema(
          validJson,
          'assets/app_schema.json',
        );
        expect(isValid, true);
      });

      testWidgets('commitImport works correctly', (tester) async {
        final result = await LocalShareService.commitImport(
          database,
          validJson,
        );
        expect(result, ImportResult.success);
        final playerCount = await database.playerDao.getPlayerCount();
        expect(playerCount, 1);
      });

      testWidgets('getDataFromPath works correctly', (tester) async {
        final tempFile = File(
          '${Directory.systemTemp.path}/test_import.tallee',
        );
        await tempFile.writeAsString(validJson);

        try {
          final (result, content) = await LocalShareService.getDataFromPath(
            tempFile.path,
          );
          expect(result, ImportResult.success);
          expect(content, validJson);
        } finally {
          if (await tempFile.exists()) await tempFile.delete();
        }
      });
    });

    group('Parse Methods', () {
      test('parsePlayersFromJson()', () {
        final p = Player(name: 'Alice');
        final jsonMap = {
          'players': [p.toNormalizedJson()],
        };
        final players = LocalShareService.parsePlayersFromJson(jsonMap);
        expect(players[0].name, 'Alice');
      });
    });
  });
}
