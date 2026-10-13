import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/core/duration_formatter.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
import 'package:stopwatch/logic/stopwatch/stopwatch_logic.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/ui/widget/analog_clock.dart';
import 'package:stopwatch/ui/widget/sliding_time_display.dart';

@RoutePage()
class StopwatchPage extends ConsumerStatefulWidget {
  const StopwatchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends ConsumerState<StopwatchPage> {
  @override
  Widget build(BuildContext context) {
    final logic = ref.read(stopwatchLogic.notifier);

    final time = ref.watch(stopwatchLogic.select((value) => value.time));
    final currentTime = ref.watch(stopwatchLogic.select((value) => value.currentTime));
    final laps = ref.watch(stopwatchLogic.select((value) => value.laps));

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnalogClock(elapsed: time),
              SizedBox(height: 20.h),
              SlidingTimeDisplay(
                elapsed: time,
                textStyle: (Theme.of(context).textTheme.headlineLarge ?? TextStyle()).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              if (currentTime != null)
                SlidingTimeDisplay(
                  elapsed: currentTime,
                  textStyle: (Theme.of(context).textTheme.headlineMedium ?? TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurface, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              SizedBox(height: 10.h),
              if (laps.isNotEmpty)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10).r,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      itemBuilder: (context, index) => _LapItem(laps[index], laps[index].order, onTap: (ctx) => logic.onTap(laps[index], laps[index].order)),
                      separatorBuilder: (context, index) => SizedBox(height: 10.h),
                      itemCount: laps.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const _BottomButtons(),
      ],
    );
  }
}

class _BottomButtons extends ConsumerWidget {
  const _BottomButtons();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.read(stopwatchLogic.notifier);

    final isRunning = ref.watch(stopwatchLogic.select((value) => value.isRunning));
    final enabledReset = ref.watch(stopwatchLogic.select((value) => value.time > Duration.zero));

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: enabledReset ? () => logic.lapResetPressed() : null,
            child: Text(isRunning ? AppLocalizations.of(context)?.lap ?? '' : AppLocalizations.of(context)?.reset ?? ''),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: TextButton(onPressed: () => logic.startStopPressed(), child: Text(isRunning ? AppLocalizations.of(context)?.stop ?? '' : AppLocalizations.of(context)?.start ?? '')),
        ),
      ],
    );
  }
}

class _LapItem extends StatelessWidget {
  final LapModel lap;
  final Function(BuildContext) onTap;
  final Object tag;
  const _LapItem(this.lap, this.tag, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: GlobalObjectKey(tag),
      borderRadius: BorderRadius.circular(10).r,
      onTap: () => onTap(context),
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10).r,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10).r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${lap.order}', style: Theme.of(context).textTheme.bodyMedium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)?.lapTime ?? '', style: Theme.of(context).textTheme.bodySmall),
                Text(DurationElapsedFormatter.toElapsedTime(lap.time), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)?.lapTotalTime ?? '', style: Theme.of(context).textTheme.bodySmall),
                Text(DurationElapsedFormatter.toElapsedTime(lap.totalTime), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
