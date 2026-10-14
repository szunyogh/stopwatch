import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
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
    final theme = Theme.of(context);

    final bottomPadding = MediaQuery.of(context).padding.bottom + 10;
    final stopwatchButtonRect = ref.watch(homeLogic.select((value) => value.stopwatchButtonRect));
    final position = ref.read(homeLogic.select((value) => context.watchTabsRouter.activeIndex == 0 ? value.stopwatchButtonRect : value.timerButtonRect));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 15, 20, bottomPadding).r,
          padding: EdgeInsets.all(5).r,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(30).r,
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08), width: 1),
            boxShadow: [
              BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.12), blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 8)),
              BoxShadow(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: -1, offset: const Offset(0, 2)),
            ],
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconButton(
                    key: GlobalObjectKey('stopwatch_icon_button'),
                    onTap: () => logic.navigateStopwatch(),
                    icon: Icon(CupertinoIcons.stopwatch, color: theme.colorScheme.onSurface),
                    label: 'Stopperóra',
                  ),
                  _IconButton(
                    key: GlobalObjectKey('timer_icon_button'),
                    onTap: () => logic.navigateTimer(),
                    icon: Icon(CupertinoIcons.hourglass, color: theme.colorScheme.onSurface),
                    label: 'Időzítő',
                  ),
                ],
              ),
              if (stopwatchButtonRect != Rect.zero)
                AnimatedPositioned.fromRect(
                  rect: position,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: .3), borderRadius: BorderRadius.circular(position.size.height / 2)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({super.key, required this.icon, required this.label, required this.onTap});
  final Widget icon;
  final String label;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(30).r,
      child: Container(
        width: 84.w,
        padding: EdgeInsets.all(6).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
