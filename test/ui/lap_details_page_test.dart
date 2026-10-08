import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/core/duration_formatter.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/ui/page/lap_details.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('hu'));
  });

  void useTestScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Widget buildTestableWidget(LapModel lap) {
    return ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
          locale: const Locale('hu'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LapDetailsPage(lap, 'tag_${lap.order}'),
        ),
      ),
    );
  }

  group('LapDetailsPage Widget Tests', () {
    final testLap = LapModel(time: const Duration(seconds: 12, milliseconds: 345), totalTime: const Duration(minutes: 1, seconds: 5), order: 3);

    testWidgets('1. LapDetailsPage displays correct lap information', (WidgetTester tester) async {
      useTestScreen(tester);

      await tester.pumpWidget(buildTestableWidget(testLap));
      await tester.pumpAndSettle();

      expect(find.byType(LapDetailsPage), findsOneWidget);

      expect(find.text(l10n.lapDetails), findsOneWidget);
      expect(find.text(DurationElapsedFormatter.toElapsedTime(testLap.time)), findsOneWidget);
      expect(find.text(DurationElapsedFormatter.toElapsedTime(testLap.totalTime)), findsOneWidget);
    });

    testWidgets('2. The lap is loaded into the logic after the first frame', (WidgetTester tester) async {
      useTestScreen(tester);

      await tester.pumpWidget(buildTestableWidget(testLap));

      final zeroText = DurationElapsedFormatter.toElapsedTime(Duration.zero);
      expect(find.text(zeroText), findsNWidgets(2));
      expect(find.text(DurationElapsedFormatter.toElapsedTime(testLap.time)), findsNothing);

      await tester.pump();

      expect(find.text(DurationElapsedFormatter.toElapsedTime(testLap.time)), findsOneWidget);
      expect(find.text(DurationElapsedFormatter.toElapsedTime(testLap.totalTime)), findsOneWidget);
    });
  });
}
