import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

@freezed
abstract class TimerState with _$TimerState {
  const TimerState._();
  const factory TimerState({@Default(Duration.zero) Duration time, @Default(false) bool isRunning}) = _TimerState;
}
