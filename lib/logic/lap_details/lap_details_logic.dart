import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/lap_details/lap_details_state.dart';
import 'package:stopwatch/model/lap.dart';

final lapDetailsLogic = NotifierProvider.autoDispose<LapDetailsLogic, LapDetailsState>(LapDetailsLogic.new);

class LapDetailsLogic extends BaseLogic<LapDetailsState> {
  AnimationController? controller;
  Animation<Offset>? offsetAnimation;

  double maxHeight = 0.0;

  @override
  LapDetailsState build() {
    initLogger();

    ref.onDispose(() => logger.i('[LapDetailsLogic] disposed'));

    return const LapDetailsState();
  }

  void initalize(LapModel lap, BuildContext context) {
    try {
      logger.i('[LapDetailsLogic] initalize');

      controller = ModalRoute.of(context)?.createAnimationController()?..forward();
      offsetAnimation = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(controller ?? const AlwaysStoppedAnimation<double>(0));

      maxHeight = MediaQuery.sizeOf(context).height;

      changeState((current) => current.copyWith(lap: lap, isInitialized: true));
    } catch (error, stack) {
      logger.e('[LapDetailsLogic] initalize error', error: error, stackTrace: stack);
    }
  }

  void handleDragUpdate(DragUpdateDetails details, BuildContext context) {
    try {
      final animation = controller;

      if (animation == null) return;

      final delta = details.primaryDelta ?? 0;

      animation.value = (animation.value - delta / maxHeight).clamp(0.0, 1.0);
    } catch (error, stack) {
      logger.e('[LapDetailsLogic] handleDragUpdate error', error: error, stackTrace: stack);
    }
  }

  void handleDragEnd(DragEndDetails details, BuildContext context) {
    try {
      final animation = controller;

      if (animation == null || animation.isAnimating) return;

      final flingVelocity = details.velocity.pixelsPerSecond.dy / maxHeight;

      if (flingVelocity < 0.0) {
        animation.fling(velocity: max(2.0, -flingVelocity));
      } else if (flingVelocity > 0.0) {
        _close();
      } else {
        if (animation.value < 0.5) {
          _close();
        } else {
          animation.fling(velocity: 2.0);
        }
      }
    } catch (error, stack) {
      logger.e('[LapDetailsLogic] handleDragEnd error', error: error, stackTrace: stack);
    }
  }

  void _close() {
    final animation = controller;

    if (animation == null) return;

    animation.reverse().whenCompleteOrCancel(() {
      if (animation.value <= 0.0) appRouter.maybePop();
    });
  }
}
