import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/core/stopwatch_native_bridge.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/home/home_state.dart';
import 'package:stopwatch/model/stopwatch_native_state.dart';

final homeLogic = NotifierProvider<HomeLogic, HomeState>(HomeLogic.new);

class HomeLogic extends BaseLogic<HomeState> {
  final _bridge = StopwatchNativeBridge.instance;

  late final AppLifecycleListener _lifecycle;

  @override
  HomeState build() {
    _init();

    _lifecycle = AppLifecycleListener(onResume: _openPendingTab);

    ref.onDispose(() {
      _lifecycle.dispose();
      logger.i('[HomeLogic] disposed');
    });

    return const HomeState();
  }

  Future<void> _init() async {
    try {
      logger.i('[HomeLogic] _init');

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final stopwatchButtonRect = _getRectFromTag('stopwatch_icon_button');
        final timerButtonRect = _getRectFromTag('timer_icon_button');
        changeState((state) => state.copyWith(stopwatchButtonRect: stopwatchButtonRect, timerButtonRect: timerButtonRect));

        _openPendingTab();
      });

      final hasPermission = await _bridge.hasNotificationPermission();

      logger.i('[HomeLogic] _init hasPermission: $hasPermission');

      if (!hasPermission) await _bridge.requestNotificationPermission();

      _ensureAlarmPermission();
    } catch (error, stack) {
      logger.e('[HomeLogic] _init error', error: error, stackTrace: stack);
    }
  }

  Future<void> _ensureAlarmPermission() async {
    if (!Platform.isAndroid) return;

    try {
      if (!await _bridge.canUseFullScreenIntent()) await _bridge.openFullScreenIntentSettings();
    } catch (error, stack) {
      logger.e('[TimerLogic] _ensureAlarmPermission error', error: error, stackTrace: stack);
    }
  }

  Future<void> _openPendingTab() async {
    try {
      final kind = await _bridge.consumePendingTab();
      if (kind == null) return;

      logger.i('[HomeLogic] _openPendingTab: ${kind.name}');

      _openTab(kind);
    } catch (error, stack) {
      logger.e('[HomeLogic] _openPendingTab error', error: error, stackTrace: stack);
    }
  }

  void _openTab(NativeKind kind, {int retries = 5}) {
    TabsRouter? router;
    try {
      router = rout;
    } catch (_) {
      router = null;
    }

    if (router == null) {
      if (retries <= 0) return;

      WidgetsBinding.instance.addPostFrameCallback((_) => _openTab(kind, retries: retries - 1));
      WidgetsBinding.instance.scheduleFrame();
      return;
    }

    router.setActiveIndex(kind == NativeKind.timer ? 1 : 0);
  }

  Rect _getRectFromTag(Object tag) {
    final renderBox = GlobalObjectKey(tag).currentContext?.findRenderObject() as RenderBox?;
    final parent = renderBox?.parent;

    if (renderBox == null) return Rect.zero;

    return renderBox.localToGlobal(Offset.zero, ancestor: parent) & renderBox.size;
  }

  TabsRouter? get rout => appRouter.innerRouterOf<TabsRouter>(HomeRoute.name);

  void navigateStopwatch() => rout?.setActiveIndex(0);

  void navigateTimer() => rout?.setActiveIndex(1);
}
