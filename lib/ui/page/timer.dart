import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/logic/timer/timer_logic.dart';
import 'package:stopwatch/ui/widget/sliding_time_display.dart';

@RoutePage()
class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> with SingleTickerProviderStateMixin {
  late TimerLogic logic;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    logic = ref.read(timerLogic.notifier);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 240));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _isRunningListen(bool? previous, bool next) {
    if (next) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(timerLogic.select((value) => value.time));
    final isRunning = ref.watch(timerLogic.select((value) => value.isRunning));
    ref.listen(timerLogic.select((value) => value.isRunning), _isRunningListen);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15).r,
      child: Center(
        child: Row(
          children: [
            _SlidingIconButton(
              animation: _animationController,
              icon: IconButton(onPressed: () => logic.removeTime(), icon: Icon(Icons.remove_circle_outline_rounded)),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10).r,
                    child: SlidingTimeDisplay(
                      elapsed: time,
                      countdown: true,
                      onPicked: isRunning ? null : logic.setTime,
                      textStyle: (Theme.of(context).textTheme.displayLarge ?? const TextStyle()).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ),
                ),
              ),
            ),
            _SlidingIconButton(
              animation: _animationController,
              direction: Direction.right,
              icon: IconButton(onPressed: () => logic.addTime(), icon: Icon(Icons.add_circle_outline_rounded)),
            ),
          ],
        ),
      ),
    );
  }
}

enum Direction { left, right }

class _SlidingIconButton extends AnimatedWidget {
  final Widget icon;
  final Direction direction;

  const _SlidingIconButton({required Animation<double> animation, required this.icon, this.direction = Direction.left}) : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final value = animation.value;

    if (value == 1) {
      return const SizedBox.shrink();
    }

    final directionValue = switch (direction) {
      Direction.left => const Offset(-1, 0),
      Direction.right => const Offset(1, 0),
    };

    final offset = Tween<Offset>(begin: Offset.zero, end: directionValue).transform(animation.value);

    return Align(
      widthFactor: lerpDouble(1, 0, value),
      child: FractionalTranslation(translation: offset, child: icon),
    );
  }
}
