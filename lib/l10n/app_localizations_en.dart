// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get lap => 'Lap';

  @override
  String get reset => 'Reset';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get lapTime => 'Lap time';

  @override
  String get lapTotalTime => 'Total time';

  @override
  String get lapDetails => 'Lap time';

  @override
  String get stopwatch => 'Stopwatch';

  @override
  String get timer => 'Timer';

  @override
  String get timerDialogTitle => 'Timer Tip';

  @override
  String get timerDialogContent =>
      'Did you know? You can swipe individual digits on the display to fine-tune the time, or use the + and - buttons to quickly add or remove 10 seconds.';

  @override
  String get timerDialogButton => 'Try it out';
}
