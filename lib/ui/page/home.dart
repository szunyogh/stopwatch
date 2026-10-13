import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/logic/home/home_logic.dart';

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
    return AutoTabsRouter(
      homeIndex: 0,
      routes: const [StopwatchRoute(), TimerRoute()],
      builder: (context, child) {
        return Scaffold(
          body: Padding(padding: EdgeInsets.fromLTRB(15, topPadding, 15, 0).r, child: child),
          bottomNavigationBar: const _BottomNavigationBar(),
        );
      },
    );
  }
}

class _BottomNavigationBar extends ConsumerWidget {
  const _BottomNavigationBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.read(homeLogic.notifier);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 10;
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 5 + bottomPadding).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(onPressed: () => logic.navigateStopwatch(), label: Icon(Icons.watch_later_outlined)),
          SizedBox(width: 15.w),
          ElevatedButton.icon(onPressed: () => logic.navigateTimer(), label: Icon(Icons.timer_sharp)),
        ],
      ),
    );
  }
}
