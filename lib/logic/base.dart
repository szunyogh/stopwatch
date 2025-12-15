import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:stopwatch/logic/logger.dart';

abstract class BaseLogic<T> extends Notifier<T> {
  late final Logger _logger;

  void initLogger() {
    _logger = ref.read(loggerProvider);
  }

  Logger get logger => _logger;

  void changeState(T Function(T current) updater) => state = updater(state);
}
