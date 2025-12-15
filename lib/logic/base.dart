import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:stopwatch/logic/logger.dart';

abstract class BaseLogic<T> extends Notifier<T> {
  Logger get logger => ref.read(loggerProvider);

  Future<void> initialize();

  void changeState(T Function(T current) updater) => state = updater(state);
}
