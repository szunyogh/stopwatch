import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/core/duration_formatter.dart';
import 'package:stopwatch/logic/home/home_logic.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/ui/widget/analog_clock.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 10;
    return Scaffold(
      body: Padding(padding: EdgeInsets.fromLTRB(15, topPadding, 15, 0).r, child: _Body()),
      bottomNavigationBar: _BottomButtons(),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(homeLogic.select((value) => value.time));
    final currentTime = ref.watch(homeLogic.select((value) => value.currentTime));
    final laps = ref.watch(homeLogic.select((value) => value.laps));

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnalogClock(elapsed: time),
          SizedBox(height: 20.h),
          Text(DurationElapsedFormatter.toElapsedTime(time), style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontFeatures: [FontFeature.tabularFigures()])),
          Text(
            DurationElapsedFormatter.toElapsedTime(currentTime),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontFeatures: [FontFeature.tabularFigures()]),
          ),
          SizedBox(height: 10.h),
          if (laps.isNotEmpty)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10).r,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  itemBuilder: (context, index) => _LapItem(laps[index]),
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemCount: laps.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomButtons extends ConsumerWidget {
  const _BottomButtons();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.read(homeLogic.notifier);

    final isRunning = ref.watch(homeLogic.select((value) => value.isRunning));
    final enabledReset = ref.watch(homeLogic.select((value) => value.time > Duration.zero));

    final bottomPadding = MediaQuery.of(context).padding.bottom + 10;

    return Padding(
      padding: EdgeInsets.fromLTRB(15, 15, 15, bottomPadding).r,
      child: Row(
        children: [
          Expanded(
            child: TextButton(onPressed: enabledReset ? () => logic.lapResetPressed() : null, child: Text(isRunning ? 'Kör' : 'Visszaállítás')),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextButton(onPressed: () => logic.startStopPressed(), child: Text(isRunning ? 'Leállítás' : 'Indítás')),
          ),
        ],
      ),
    );
  }
}

class _LapItem extends StatelessWidget {
  final LapModel lap;
  const _LapItem(this.lap);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10).r,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10).r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${lap.order}', style: Theme.of(context).textTheme.bodyMedium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kör idő', style: Theme.of(context).textTheme.bodySmall),
              Text(DurationElapsedFormatter.toElapsedTime(lap.time), style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Teljes idő', style: Theme.of(context).textTheme.bodySmall),
              Text(DurationElapsedFormatter.toElapsedTime(lap.totalTime), style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
