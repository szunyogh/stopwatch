import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/ui/page/home.dart';

void main() {
  testWidgets('HomePage widget test - button interactions', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const HomePage(),
          builder: (context, child) {
            ScreenUtil.init(context);
            return child!;
          },
        ),
      ),
    );

    // Initial state: time should be 00:00.000, button should say 'Indítás'
    expect(find.text('00:00.000'), findsOneWidget);
    expect(find.text('Indítás'), findsOneWidget);
    expect(find.text('Visszaállítás'), findsOneWidget);

    // Tap start button
    await tester.tap(find.text('Indítás'));
    await tester.pump(); // Rebuild after state change

    // After start: button should say 'Leállítás'
    expect(find.text('Leállítás'), findsOneWidget);

    // Wait for timer to tick - use pumpAndSettle or multiple pumps with duration
    await tester.pump(const Duration(milliseconds: 100));

    // Time should have increased
    expect(find.text('00:00.000'), findsNothing);

    // Tap stop button
    await tester.tap(find.text('Leállítás'));
    await tester.pump(); // Rebuild after state change

    // After stop: button should say 'Indítás'
    expect(find.text('Indítás'), findsOneWidget);

    // Reset button should be enabled (not null onPressed)
    final resetButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Visszaállítás'),
    );
    expect(resetButton.onPressed, isNotNull);

    // Tap reset
    await tester.tap(find.text('Visszaállítás'));
    await tester.pump(); // Rebuild after state change

    // After reset: time back to 00:00.000
    expect(find.text('00:00.000'), findsOneWidget);
  });
}
