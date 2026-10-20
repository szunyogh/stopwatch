import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
import 'package:stopwatch/logic/home/home_logic.dart';
import 'package:stopwatch/logic/stopwatch/stopwatch_logic.dart';
import 'package:stopwatch/logic/timer/timer_logic.dart';
import 'package:stopwatch/ui/widget/inner_shadow_container.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      homeIndex: 0,
      routes: const [StopwatchRoute(), TimerRoute()],
      builder: (context, child) {
        return Scaffold(extendBody: true, body: child, bottomNavigationBar: const _BottomNavigationBar());
      },
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    final index = context.watchTabsRouter.activeIndex;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: .3),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15).r,
          child: Column(mainAxisSize: MainAxisSize.min, children: [if (index == 0) const _StopwatchBottomButtons() else const _TimerBottomButtons(), const _NavigationBar()]),
        ),
      ),
    );
  }
}

class _NavigationBar extends ConsumerWidget {
  const _NavigationBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.read(homeLogic.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bottomPadding = MediaQuery.of(context).padding.bottom + 10;
    final stopwatchButtonRect = ref.watch(homeLogic.select((value) => value.stopwatchButtonRect));
    final index = context.watchTabsRouter.activeIndex;
    final position = ref.read(homeLogic.select((value) => index == 0 ? value.stopwatchButtonRect : value.timerButtonRect));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 15, 20, bottomPadding).r,
          padding: const EdgeInsets.all(5).r,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(30).r,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              if (!isDark) BoxShadow(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: -1, offset: const Offset(0, 2)),
            ],
          ),
          child: Stack(
            children: [
              if (stopwatchButtonRect != Rect.zero)
                AnimatedPositioned.fromRect(
                  rect: position,
                  duration: const Duration(milliseconds: 250),
                  child: InnerShadowContainer(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(position.size.height / 2),
                    shadows: isDark
                        ? [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: .3), blurRadius: 6, offset: const Offset(0, 1))]
                        : [
                            BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 3)),
                            BoxShadow(color: theme.colorScheme.onSurface.withValues(alpha: .3), blurRadius: 6, offset: const Offset(0, 1)),
                          ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconButton(
                    key: GlobalObjectKey('stopwatch_icon_button'),
                    isSelected: index == 0,
                    onTap: () => logic.navigateStopwatch(),
                    icon: CupertinoIcons.stopwatch,
                    label: AppLocalizations.of(context)?.stopwatch ?? '',
                  ),
                  _IconButton(
                    key: GlobalObjectKey('timer_icon_button'),
                    isSelected: index == 1,
                    onTap: () => logic.navigateTimer(),
                    icon: CupertinoIcons.hourglass,
                    label: AppLocalizations.of(context)?.timer ?? '',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StopwatchBottomButtons extends ConsumerWidget {
  const _StopwatchBottomButtons();
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

class _TimerBottomButtons extends ConsumerWidget {
  const _TimerBottomButtons();
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

class _IconButton extends StatelessWidget {
  const _IconButton({super.key, required this.icon, required this.label, required this.onTap, required this.isSelected});

  final bool isSelected;
  final IconData icon;
  final String label;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(30).r,
      child: Container(
        width: 84.w,
        padding: const EdgeInsets.all(6).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
