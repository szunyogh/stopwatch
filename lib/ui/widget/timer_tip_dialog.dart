import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/l10n/app_localizations.dart';

@RoutePage()
class TimerTipDialog extends StatelessWidget {
  const TimerTipDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded),
          SizedBox(width: 5.w),
          Text(AppLocalizations.of(context)?.timerDialogTitle ?? ''),
        ],
      ),
      content: Text(AppLocalizations.of(context)?.timerDialogContent ?? ''),
      actions: [
        SizedBox(
          width: double.maxFinite,
          child: TextButton(onPressed: () => context.router.maybePop(), child: Text(AppLocalizations.of(context)?.timerDialogButton ?? '')),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
