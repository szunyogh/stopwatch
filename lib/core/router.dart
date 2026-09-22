import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/router.gr.dart';

final appRouterProvider = Provider((ref) => AppRouter(ref));

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  Ref ref;
  AppRouter(this.ref);

  @override
  RouteType get defaultRouteType => const RouteType.cupertino();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(type: const RouteType.adaptive(), page: HomeRoute.page, initial: true, path: '/'),
    //AutoRoute(type: const RouteType.adaptive(), page: LapDetailsRoute.page, path: '/lap-details'),
    CustomRoute(
      page: LapDetailsRoute.page,
      path: '/lap-details',
      customRouteBuilder: <T>(BuildContext context, Widget child, AutoRoutePage<T> page) => CustomPageRoute<T>(child, settings: page),
    ),
  ];
}

class CustomPageRoute<T> extends PageRoute<T> {
  final Widget child;

  CustomPageRoute(this.child, {super.settings});

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'custom_page_route';

  AnimationController? animationController;

  @override
  AnimationController createAnimationController() {
    return animationController ??= AnimationController(vsync: navigator!, duration: transitionDuration);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;
}
