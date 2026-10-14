import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/home/home_state.dart';

final homeLogic = NotifierProvider<HomeLogic, HomeState>(HomeLogic.new);

class HomeLogic extends BaseLogic<HomeState> {
  @override
  HomeState build() {
    _init();

    ref.onDispose(() {
      logger.i('[HomeLogic] disposed');
    });

    return const HomeState();
  }

  void _init() {
    try {
      logger.i('[HomeLogic] _init');

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final stopwatchButtonRect = _getRectFromTag('stopwatch_icon_button');
        final timerButtonRect = _getRectFromTag('timer_icon_button');
        changeState((state) => state.copyWith(stopwatchButtonRect: stopwatchButtonRect, timerButtonRect: timerButtonRect));
      });
    } catch (error, stack) {
      logger.e('[HomeLogic] _init error', error: error, stackTrace: stack);
    }
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
