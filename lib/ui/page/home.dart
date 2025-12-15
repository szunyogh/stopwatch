import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/core/duration_extension.dart';
import 'package:stopwatch/logic/home/home_logic.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late HomeLogic logic;

  @override
  void initState() {
    super.initState();
    logic = ref.read(homeLogic.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(homeLogic.select((value) => value.time));
    final isRunning = ref.watch(homeLogic.select((value) => value.isRunning));
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0).r,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(time.toElapsedTime(), style: Theme.of(context).textTheme.headlineLarge),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isRunning ? () => logic.stop() : null,
                    child: const Text('Leállítás'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextButton(
                    onPressed: () => logic.start(),
                    child: const Text('Indítás'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
