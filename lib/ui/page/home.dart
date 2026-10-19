import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/l10n/app_localizations.dart';
import 'package:stopwatch/logic/home/home_logic.dart';
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
