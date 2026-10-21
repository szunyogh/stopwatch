// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get lap => 'Kör';

  @override
  String get reset => 'Visszaállítás';

  @override
  String get start => 'Indítás';

  @override
  String get stop => 'Leállítás';

  @override
  String get lapTime => 'Kör idő';

  @override
  String get lapTotalTime => 'Teljes idő';

  @override
  String get lapDetails => 'Kör idő';

  @override
  String get stopwatch => 'Stopperóra';

  @override
  String get timer => 'Időzítő';

  @override
  String get timerDialogTitle => 'Tipp az időzítőhöz';

  @override
  String get timerDialogContent =>
      'Tudtad? A kijelzőn lévő számokat egyenként is elcsúsztathatod az ujjaddal a finomhangoláshoz, a + és - gombokkal pedig gyorsan hozzáadhatsz vagy elvehetsz 10 másodpercet.';

  @override
  String get timerDialogButton => 'Kipróbálom';
}
