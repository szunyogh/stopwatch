import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stopwatch/model/lap.dart';

part 'stopwatch_state.freezed.dart';

@freezed
abstract class StopwatchState with _$StopwatchState {
  const StopwatchState._();
  const factory StopwatchState({@Default(Duration.zero) Duration time, @Default(false) bool isRunning, @Default([]) List<LapModel> laps, @Default(null) Duration? currentTime}) = _StopwatchState;
}
