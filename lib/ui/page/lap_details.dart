import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/core/duration_formatter.dart';
import 'package:stopwatch/logic/lap_details/lap_details_logic.dart';
import 'package:stopwatch/model/lap.dart';
import 'package:stopwatch/ui/widget/analog_clock.dart';

@RoutePage()
class LapDetailsPage extends ConsumerStatefulWidget {
  final LapModel lap;
  final Rect itemRect;
  const LapDetailsPage(this.lap, this.itemRect, {super.key});

  @override
  ConsumerState<LapDetailsPage> createState() => _LapDetailsPageState();
}

class _LapDetailsPageState extends ConsumerState<LapDetailsPage> {
  late LapDetailsLogic logic;

  @override
  initState() {
    super.initState();
    logic = ref.read(lapDetailsLogic.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => logic.initalize(widget.lap, context));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(lapDetailsLogic.select((value) => value.isInitialized));
    final animation = logic.controller ?? const AlwaysStoppedAnimation<double>(0);

    final fullRect = Offset.zero & MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rect = Rect.lerp(widget.itemRect, fullRect, animation.value)!;

        return ClipPath(
          clipper: _RectClipper(rect, BorderRadius.lerp(BorderRadius.circular(10).r, BorderRadius.zero, animation.value)!),
          child: GestureDetector(
            onVerticalDragUpdate: (details) => logic.handleDragUpdate(details, context),
            onVerticalDragEnd: (details) => logic.handleDragEnd(details, context),
            child: _Page(animation),
          ),
        );
      },
    );
  }
}

class _RectClipper extends CustomClipper<Path> {
  final Rect rect;
  final BorderRadius borderRadius;

  _RectClipper(this.rect, this.borderRadius);

  @override
  Path getClip(Size size) {
    return Path()..addRRect(borderRadius.toRRect(rect));
  }

  @override
  bool shouldReclip(covariant _RectClipper oldClipper) {
    return oldClipper.rect != rect || oldClipper.borderRadius != borderRadius;
  }
}

class _Page extends ConsumerWidget {
  final Animation<double> opacity;
  const _Page(this.opacity);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(lapDetailsLogic.select((value) => value.lap?.time ?? Duration.zero));
    final totalTime = ref.watch(lapDetailsLogic.select((value) => value.lap?.totalTime ?? Duration.zero));

    return Scaffold(
      appBar: AppBar(title: const Text('Kör idő')),
      body: SizedBox(
        width: double.infinity,
        child: FadeTransition(
          opacity: opacity,
          child: Column(
            children: [
              SizedBox(height: 40.h),
              AnalogClock(elapsed: time),
              SizedBox(height: 20.h),
              Text(DurationElapsedFormatter.toElapsedTime(time), style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontFeatures: [FontFeature.tabularFigures()])),
              Text(
                DurationElapsedFormatter.toElapsedTime(totalTime),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontFeatures: [FontFeature.tabularFigures()]),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
