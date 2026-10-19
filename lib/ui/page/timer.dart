import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(timerLogic.select((value) => value.time));
    final isRunning = ref.watch(timerLogic.select((value) => value.isRunning));
    ref.listen(timerLogic.select((value) => value.isRunning), (previous, next) {
      if (next) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Row(
              children: [
                _SlidingIconButton(
                  animation: _animationController,
                  icon: IconButton(onPressed: () => logic.removeTime(), icon: Icon(Icons.remove_circle_outline_rounded)),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final s = lerpDouble(55.sp / 70.sp, 1.0, Curves.easeInOut.transform(_animationController.value))!;
                        return Transform.scale(scale: s, filterQuality: FilterQuality.high, child: child);
                      },
                      child: OverflowBox(
                        maxWidth: double.infinity,
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
        ),
        SizedBox(height: 10.h),
        const _BottomButtons(),
      ],
    );
  }
}

class _BottomButtons extends ConsumerWidget {
  const _BottomButtons();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.read(timerLogic.notifier);

    final isRunning = ref.watch(timerLogic.select((value) => value.isRunning));
    final enabledReset = ref.watch(timerLogic.select((value) => value.time != logic.startTime && !value.isRunning));

    return Row(
      children: [
        Expanded(
          child: TextButton(onPressed: enabledReset ? () => logic.reset() : null, child: Text(AppLocalizations.of(context)?.reset ?? '')),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: TextButton(onPressed: () => logic.startStopPressed(), child: Text(isRunning ? AppLocalizations.of(context)?.stop ?? '' : AppLocalizations.of(context)?.start ?? '')),
        ),
      ],
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

    final position = direction == Direction.left ? const Offset(-1, 0) : const Offset(1, 0);

    final offset = Tween<Offset>(begin: Offset.zero, end: position).transform(animation.value);

    return Align(
      widthFactor: lerpDouble(1, 0, value),
      child: FractionalTranslation(translation: offset, child: icon),
    );
  }
}
