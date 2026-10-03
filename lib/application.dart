import 'l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/core/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stopwatch/ui/theme/dark_theme.dart';
import 'package:stopwatch/ui/theme/light_theme.dart';

class Application extends ConsumerStatefulWidget {
  const Application({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ApplicationState();
}

class _ApplicationState extends ConsumerState<Application> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) {
        return MaterialApp.router(
          theme: appLightTheme,
          darkTheme: appDarkTheme,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: ref.read(appRouterProvider).config(),
          builder: (context, child) => child ?? Container(),
        );
      },
    );
  }
}
