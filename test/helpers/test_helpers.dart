import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stopwatch/core/router.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/ui/widget/sliding_time_display.dart';

final List<MethodCall> nativeCalls = [];

final List<MockStreamHandlerEventSink> _eventSinks = [];

/// A következő `consumePendingTab` hívás ezt adja vissza (hívás után null).
/// Teszt közben is átállítható, pl. az "app resume" teszthez.
String? mockPendingTab;

Iterable<MethodCall> callsOf(String method) => nativeCalls.where((call) => call.method == method);

/// Egy hívás `kind` paramétere (Map argumentumból vagy sima String-ből).
String? callKind(MethodCall call) => _kindOf(call.arguments);

Iterable<MethodCall> callsOfKind(String method, String kind) => callsOf(method).where((call) => callKind(call) == kind);

Map argsOf(MethodCall call) => call.arguments as Map;

int nowMs() => DateTime.now().millisecondsSinceEpoch;

Map<String, Object?> nativeStateOf({String? kind, bool isRunning = false, int? startedAtEpochMs, int accumulatedMs = 0, int? totalMs}) => {
  if (kind != null) 'kind': kind,
  'isRunning': isRunning,
  'startedAtEpochMs': startedAtEpochMs,
  'accumulatedMs': accumulatedMs,
  if (totalMs != null) 'totalMs': totalMs,
};

/// Időzítő natív állapota. Álló időzítőnél `accumulatedMs` = hátralévő idő,
/// futónál a `startedAtEpochMs` időpontban hátralévő idő.
Map<String, Object?> timerNativeStateOf({bool isRunning = false, int? startedAtEpochMs, required int accumulatedMs, required int totalMs}) =>
    nativeStateOf(kind: 'timer', isRunning: isRunning, startedAtEpochMs: startedAtEpochMs, accumulatedMs: accumulatedMs, totalMs: totalMs);

String? _kindOf(Object? arguments) {
  if (arguments is Map) return arguments['kind']?.toString();
  if (arguments is String) return arguments;
  return null;
}

final testLaps = [
  LapModel(time: const Duration(seconds: 5), totalTime: const Duration(seconds: 5), order: 1),
  LapModel(time: const Duration(seconds: 10), totalTime: const Duration(seconds: 15), order: 2),
];

String lapsToJson(List<LapModel> laps) => jsonEncode(laps.map((lap) => lap.toJson()).toList());

void setupMockNativeChannels({
  String lapsJson = '[]',

  Map<String, Object?>? nativeState,

  Map<String, Object?>? timerNativeState,
  bool hasNotificationPermission = true,

  /// Minden kind-ra true-t ad az `isFirstUse`.
  bool isFirstUse = false,

  /// Csak a megadott kind-okra ad true-t az `isFirstUse` (pl. {'timer'}).
  Set<String> firstUseKinds = const {},

  String? pendingTab,
}) {
  nativeCalls.clear();
  _eventSinks.clear();

  mockPendingTab = pendingTab;

  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(const MethodChannel('stopwatch/native'), (MethodCall methodCall) async {
    nativeCalls.add(methodCall);

    switch (methodCall.method) {
      case 'hasNotificationPermission':
        return hasNotificationPermission;
      case 'requestNotificationPermission':
        return true;
      case 'canUseFullScreenIntent':
        return true;
      case 'isFirstUse':
        return isFirstUse || firstUseKinds.contains(_kindOf(methodCall.arguments));
      case 'consumePendingTab':
        final value = mockPendingTab;
        mockPendingTab = null;
        return value;
      case 'getState':
        if (_kindOf(methodCall.arguments) == 'timer') return timerNativeState ?? nativeStateOf(totalMs: 0);
        return nativeState ?? nativeStateOf();
      case 'getLaps':
        return lapsJson;
      default:
        return null;
    }
  });

  messenger.setMockStreamHandler(
    const EventChannel('stopwatch/native_events'),
    MockStreamHandler.inline(onListen: (arguments, events) => _eventSinks.add(events), onCancel: (arguments) => _eventSinks.clear()),
  );
}

Future<void> emitNativeEvent(WidgetTester tester, Map<String, Object?> event) async {
  for (final sink in List.of(_eventSinks)) {
    sink.success(event);
  }
  await waitRealTime(tester, 20);
}

Future<void> settleInit(WidgetTester tester) => waitRealTime(tester, 20);

Future<void> waitRealTime(WidgetTester tester, int ms) async {
  await tester.runAsync(() async => await Future.delayed(Duration(milliseconds: ms)));
  await tester.pump();
}

ProviderContainer createTestContainer() => ProviderContainer(overrides: [appRouterProvider.overrideWith((ref) => AppRouter(ref))]);

Future<AppLocalizations> loadL10n() => AppLocalizations.delegate.load(const Locale('hu'));

Future<ProviderContainer> pumpApp(WidgetTester tester, {bool settle = true}) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = createTestContainer();
  addTearDown(container.dispose);

  final router = container.read(appRouterProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp.router(
          locale: const Locale('hu'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router.config(),
        ),
      ),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 100));
  }

  return container;
}

/// Mint a `pumpApp`, de megvárja a logikák `_init`-jét és a post-frame callbackeket is.
/// Szándékosan NEM `pumpAndSettle`-t használ: futó Ticker mellett az sosem fejeződne be.
Future<ProviderContainer> pumpAppReady(WidgetTester tester) async {
  final container = await pumpApp(tester, settle: false);
  await settleInit(tester);
  await tester.pump(const Duration(milliseconds: 300));
  return container;
}

/// A widget fa lebontása a teszt végén, hogy ne maradjon futó Ticker / Timer.
Future<void> unmountApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

/// Alsó tab-sávon a címkére koppint, majd kivárja az animációt.
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

int activeTab(ProviderContainer container) => container.read(appRouterProvider).innerRouterOf<TabsRouter>(HomeRoute.name)!.activeIndex;

Finder lapItem(int order) => find.byKey(GlobalObjectKey(order));

Duration displayedTime(WidgetTester tester, {int index = 0}) => tester.widget<SlidingTimeDisplay>(find.byType(SlidingTimeDisplay).at(index)).elapsed;

/// Egy adott oldalon (pl. `StopwatchPage`, `TimerPage`) lévő időkijelző.
/// Tab váltás után mindkét oldal a fában lehet, ezért kell az oldalra szűkíteni.
SlidingTimeDisplay timeDisplayIn(WidgetTester tester, Type page, {int index = 0}) =>
    tester.widget<SlidingTimeDisplay>(find.descendant(of: find.byType(page), matching: find.byType(SlidingTimeDisplay)).at(index));

Duration displayedTimeIn(WidgetTester tester, Type page, {int index = 0}) => timeDisplayIn(tester, page, index: index).elapsed;

TextButton textButton(WidgetTester tester, String label) => tester.widget<TextButton>(find.widgetWithText(TextButton, label));
