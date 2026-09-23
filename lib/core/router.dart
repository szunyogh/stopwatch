import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:zoom_page/zoom_page.dart';

final appRouterProvider = Provider((ref) => AppRouter(ref));

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  Ref ref;
  AppRouter(this.ref);

  @override
  RouteType get defaultRouteType => const RouteType.adaptive(enablePredictiveBackGesture: true);

  @override
  List<AutoRoute> get routes => [
    AutoRoute(type: const RouteType.adaptive(), page: HomeRoute.page, initial: true, path: '/'),
    CustomRoute(
      page: LapDetailsRoute.page,
      customRouteBuilder: <T>(BuildContext context, Widget child, AutoRoutePage<T> page) {
        final args = page.arguments;
        Object? tag;

        if (args is LapDetailsRouteArgs) {
          tag = args.tag;
        }

        return ZoomGesturePageRoute<T>(settings: page, tag: tag, builder: (_) => child);
      },
    ),
  ];
}
