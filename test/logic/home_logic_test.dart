import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/core/stopwatch_native_bridge.dart';
import 'package:stopwatch/logic/home/home_logic.dart';
import 'package:stopwatch/ui/page/stopwatch.dart';
import 'package:stopwatch/ui/page/timer.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => StopwatchNativeBridge.isAndroid = () => true);
  tearDown(() => StopwatchNativeBridge.isAndroid = () => Platform.isAndroid);

  Future<ProviderContainer> bootHomeLogic(WidgetTester tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    container.listen(homeLogic, (prev, next) {});

    tester.binding.scheduleFrame();
    await settleInit(tester);
    await tester.pump();

    return container;
  }

  group('HomeLogic Unit Tests', () {
    group('HomeLogic - permissions', () {
      testWidgets('1. Does not request the notification permission when it is already granted', (tester) async {
        setupMockNativeChannels(hasNotificationPermission: true);

        await bootHomeLogic(tester);

        expect(callsOf('hasNotificationPermission'), hasLength(1));
        expect(callsOf('requestNotificationPermission'), isEmpty);
      });

      testWidgets('2. Requests the notification permission when it is missing', (tester) async {
        setupMockNativeChannels(hasNotificationPermission: false);

        await bootHomeLogic(tester);

        expect(callsOf('hasNotificationPermission'), hasLength(1));
        expect(callsOf('requestNotificationPermission'), hasLength(1));
      });

      testWidgets('3. Full-screen intent settings are only checked on Android', (tester) async {
        setupMockNativeChannels();

        await bootHomeLogic(tester);

        expect(callsOf('canUseFullScreenIntent'), isEmpty);
        expect(callsOf('openFullScreenIntentSettings'), isEmpty);
      }, skip: Platform.isAndroid);

      testWidgets('4. Native errors during init are swallowed', (tester) async {
        setupMockNativeChannels();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('stopwatch/native'), (call) async {
          throw PlatformException(code: 'boom');
        });

        final container = await bootHomeLogic(tester);

        expect(tester.takeException(), isNull);
        expect(container.read(homeLogic).stopwatchButtonRect, Rect.zero);
      });
    });

    group('HomeLogic - pending tab without UI', () {
      testWidgets('5. Asks for the pending tab once and does not fail without a router', (tester) async {
        setupMockNativeChannels();

        await bootHomeLogic(tester);

        expect(callsOf('consumePendingTab'), hasLength(1));
        expect(tester.takeException(), isNull);
      });

      testWidgets('6. Gives up silently after the retries when no router is mounted', (tester) async {
        setupMockNativeChannels(pendingTab: 'timer');

        await bootHomeLogic(tester);
        for (var i = 0; i < 10; i++) {
          await tester.pump();
        }

        expect(callsOf('consumePendingTab'), hasLength(1));
        expect(tester.takeException(), isNull);
      });
    });

    group('HomeLogic - with UI', () {
      testWidgets('7. Measures the position of both navigation buttons after the first frame', (tester) async {
        setupMockNativeChannels();

        final container = await pumpAppReady(tester);
        final state = container.read(homeLogic);

        expect(state.stopwatchButtonRect, isNot(Rect.zero));
        expect(state.timerButtonRect, isNot(Rect.zero));
        expect(state.timerButtonRect.left, greaterThan(state.stopwatchButtonRect.left));
        expect(state.timerButtonRect.size, state.stopwatchButtonRect.size);

        await unmountApp(tester);
      });

      testWidgets('8. Stays on the stopwatch tab when there is no pending tab', (tester) async {
        setupMockNativeChannels();

        final container = await pumpAppReady(tester);

        expect(activeTab(container), 0);
        expect(find.byType(StopwatchPage), findsOneWidget);

        await unmountApp(tester);
      });

      testWidgets('9. Opens the pending timer tab on startup', (tester) async {
        setupMockNativeChannels(pendingTab: 'timer');

        final container = await pumpAppReady(tester);

        expect(activeTab(container), 1);
        expect(find.byType(TimerPage), findsOneWidget);
        expect(callsOf('consumePendingTab'), hasLength(1));

        await unmountApp(tester);
      });

      testWidgets('10. Opens the pending stopwatch tab when the app is resumed', (tester) async {
        setupMockNativeChannels();

        final container = await pumpAppReady(tester);
        container.read(homeLogic.notifier).navigateTimer();
        await tester.pump(const Duration(milliseconds: 300));
        expect(activeTab(container), 1);

        mockPendingTab = 'stopwatch';
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await waitRealTime(tester, 20);
        await tester.pump(const Duration(milliseconds: 300));

        expect(activeTab(container), 0);
        expect(callsOf('consumePendingTab'), hasLength(2));

        await unmountApp(tester);
      });

      testWidgets('11. Opens the pending timer tab when the app is resumed', (tester) async {
        setupMockNativeChannels();

        final container = await pumpAppReady(tester);
        expect(activeTab(container), 0);

        mockPendingTab = 'timer';
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await waitRealTime(tester, 20);
        await tester.pump(const Duration(milliseconds: 300));

        expect(activeTab(container), 1);

        await unmountApp(tester);
      });

      testWidgets('12. navigateTimer and navigateStopwatch switch the active tab', (tester) async {
        setupMockNativeChannels();

        final container = await pumpAppReady(tester);
        final logic = container.read(homeLogic.notifier);

        logic.navigateTimer();
        await tester.pump(const Duration(milliseconds: 300));
        expect(activeTab(container), 1);

        logic.navigateStopwatch();
        await tester.pump(const Duration(milliseconds: 300));
        expect(activeTab(container), 0);

        await unmountApp(tester);
      });
    });
  });
}
