import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/core/router.dart';
import 'package:stopwatch/core/logger.dart';

abstract class BaseLogic<T> extends Notifier<T> with LoggerMixin {
  AppRouter get appRouter => ref.read(appRouterProvider);

  void changeState(T Function(T current) updater) => state = updater(state);
}
