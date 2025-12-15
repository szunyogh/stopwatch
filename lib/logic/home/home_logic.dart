import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/logic/base.dart';
import 'package:stopwatch/logic/home/home_state.dart';

final homeLogic = NotifierProvider<HomeLogic, HomeState>(HomeLogic.new);

class HomeLogic extends BaseLogic<HomeState> {
  @override
  HomeState build() => HomeState();

  @override
  Future<void> initialize() async => await _init();

  Future<void> _init() async {
    try {
      //
    } catch (e, stack) {
      logger.e('[HomeLogic] initialize', error: e, stackTrace: stack);
    }
  }
}
