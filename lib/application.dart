import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/core/router.dart';
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
          title: 'Próba Stopper',
          theme: appLightTheme,
          darkTheme: appDarkTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: ref.read(appRouterProvider).config(),
          builder: (context, child) => child ?? Container(),
        );
      },
    );
  }
}
