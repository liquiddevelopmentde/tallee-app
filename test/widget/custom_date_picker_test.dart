import 'package:clock/clock.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/app_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/date_picker/custom_date_picker.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      flutter_localizations.GlobalMaterialLocalizations.delegate,
      flutter_localizations.GlobalWidgetsLocalizations.delegate,
      flutter_localizations.GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: darkTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  final fixedTime = DateTime(2026, 10, 15);

  testWidgets('CustomDatePicker single mode renders and selects date', (
    WidgetTester tester,
  ) async {
    await withClock(Clock.fixed(fixedTime), () async {
      DateTime? selectedDate;
      dynamic submittedValue;

      await tester.pumpWidget(
        createTestApp(
          CustomDatePicker(
            selectionMode: DatePickerSelectionMode.single,
            initialSelectedDate: DateTime(2026, 10, 10),
            onDateSelected: (date) => selectedDate = date,
            onDateSubmitted: (date) => submittedValue = date,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify month header shows 2026
      expect(find.textContaining('2026'), findsOneWidget);

      // Tap on day 20
      final day20 = find.text('20');
      expect(day20, findsOneWidget);
      await tester.tap(day20);
      await tester.pumpAndSettle();

      expect(selectedDate, equals(DateTime(2026, 10, 20)));

      // Tap Confirm button
      final confirmBtn = find.text('Bestätigen');
      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();
        expect(submittedValue, equals(DateTime(2026, 10, 20)));
      }
    });
  });

  testWidgets('CustomDatePicker range mode selects start and end dates', (
    WidgetTester tester,
  ) async {
    await withClock(Clock.fixed(fixedTime), () async {
      DatePickerRange? rangeResult;

      await tester.pumpWidget(
        createTestApp(
          CustomDatePicker(
            selectionMode: DatePickerSelectionMode.range,
            onRangeSelected: (range) => rangeResult = range,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap day 5 (start date)
      await tester.tap(find.text('5').first);
      await tester.pumpAndSettle();

      expect(rangeResult?.startDate, equals(DateTime(2026, 10, 5)));
      expect(rangeResult?.endDate, isNull);

      // Tap day 12 (end date)
      await tester.tap(find.text('12').first);
      await tester.pumpAndSettle();

      expect(rangeResult?.startDate, equals(DateTime(2026, 10, 5)));
      expect(rangeResult?.endDate, equals(DateTime(2026, 10, 12)));
    });
  });

  testWidgets('CustomDatePicker disables dates after maxDate', (
    WidgetTester tester,
  ) async {
    await withClock(Clock.fixed(fixedTime), () async {
      DateTime? selectedDate;

      await tester.pumpWidget(
        createTestApp(
          CustomDatePicker(
            selectionMode: DatePickerSelectionMode.single,
            maxDate: DateTime(2026, 10, 15),
            onDateSelected: (date) => selectedDate = date,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try tapping day 25 (after maxDate)
      await tester.tap(find.text('25').first);
      await tester.pumpAndSettle();

      // Selection should not happen
      expect(selectedDate, isNull);

      // Tap day 10 (before maxDate)
      await tester.tap(find.text('10').first);
      await tester.pumpAndSettle();

      expect(selectedDate, equals(DateTime(2026, 10, 10)));
    });
  });

  testWidgets('CustomDatePicker year selector toggles and changes year', (
    WidgetTester tester,
  ) async {
    await withClock(Clock.fixed(fixedTime), () async {
      await tester.pumpWidget(
        createTestApp(
          const CustomDatePicker(selectionMode: DatePickerSelectionMode.single),
        ),
      );

      await tester.pumpAndSettle();

      // Tap header to open year picker
      final header = find.textContaining('2026');
      await tester.tap(header);
      await tester.pumpAndSettle();

      // Verify year picker shows options like 2024, 2025
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);

      // Tap year 2025
      await tester.tap(find.text('2025'));
      await tester.pumpAndSettle();

      // Should return to month view showing 2025
      expect(find.textContaining('October 2025'), findsOneWidget);
    });
  });
}
