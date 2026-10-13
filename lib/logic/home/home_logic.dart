import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/router.gr.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/home/home_state.dart';

final homeLogic = NotifierProvider<HomeLogic, HomeState>(HomeLogic.new);

class HomeLogic extends BaseLogic<HomeState> {
  @override
  HomeState build() {
    ref.onDispose(() {
      logger.i('[HomeLogic] disposed');
    });

    return const HomeState();
  }

  TabsRouter? get rout => appRouter.innerRouterOf<TabsRouter>(HomeRoute.name);

  void navigateStopwatch() => rout?.setActiveIndex(0);

  void navigateTimer() => rout?.setActiveIndex(1);
}
