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

class _TimerPageState extends ConsumerState<TimerPage> {
  late TimerLogic logic;

  @override
  void initState() {
    super.initState();
    logic = ref.read(timerLogic.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(timerLogic.select((value) => value.time));
    final isRunning = ref.watch(timerLogic.select((value) => value.isRunning));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: SlidingTimeDisplay(
              elapsed: time,
              countdown: true,
              onPicked: isRunning ? null : logic.setTime,
              textStyle: (Theme.of(context).textTheme.headlineLarge ?? TextStyle()).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
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
