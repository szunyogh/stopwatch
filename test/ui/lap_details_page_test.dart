import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'package:stopwatch/logic/logger.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/ui/page/lap_details.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LapDetailsPage Widget Tests', () {
    testWidgets('1. LapDetailsPage displays correct lap information', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      final testLap = LapModel(time: const Duration(seconds: 12, milliseconds: 345), totalTime: const Duration(minutes: 1, seconds: 5), order: 3);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [loggerProvider.overrideWithValue(Logger(level: Level.nothing))],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => MaterialApp(home: LapDetailsPage(testLap, 'tag_3')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Kör idő'), findsOneWidget);

      expect(find.byType(LapDetailsPage), findsOneWidget);
    });
  });
}
