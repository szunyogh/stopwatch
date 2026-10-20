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
import 'package:stopwatch/ui/widget/sliver_collapsing_header.dart';

@RoutePage()
class StopwatchPage extends ConsumerStatefulWidget {
  const StopwatchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends ConsumerState<StopwatchPage> {
  late StopwatchLogic logic;

  @override
  void initState() {
    super.initState();
    logic = ref.read(stopwatchLogic.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(stopwatchLogic.select((value) => value.time));
    final currentTime = ref.watch(stopwatchLogic.select((value) => value.currentTime));
    final laps = ref.watch(stopwatchLogic.select((value) => value.laps));

    final topPadding = MediaQuery.of(context).padding.top + 10;

    return CustomScrollView(
      controller: logic.controller,
      physics: laps.isEmpty ? const NeverScrollableScrollPhysics() : null,
      slivers: [
        SliverCollapsingHeader(
          color: Theme.of(context).scaffoldBackgroundColor,
          spacing: 10.r,
          padding: EdgeInsets.fromLTRB(15, topPadding, 15, 10).r,
          collapsedMainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AnalogClock(elapsed: time),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlidingTimeDisplay(
                  elapsed: time,
                  textStyle: (Theme.of(context).textTheme.headlineLarge ?? TextStyle()).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                ),
                if (currentTime != null)
                  SlidingTimeDisplay(
                    elapsed: currentTime,
                    textStyle: (Theme.of(context).textTheme.headlineMedium ?? TextStyle()).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
              ],
            ),
          ],
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15).r,
          sliver: SliverList.separated(
            itemBuilder: (context, index) => _LapItem(laps[index], laps[index].order, onTap: (ctx) => logic.onTap(laps[index], laps[index].order)),
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemCount: laps.length,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 170.h)),
        const SliverCollapsingHeaderFooter(),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15).r,
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10).r),
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
