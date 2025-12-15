import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stopwatch/model/lap.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();
  const factory HomeState({
    @Default(Duration.zero) Duration time,
    @Default(false) bool isRunning,
    @Default([]) List<LapModel> laps,
    @Default(null) Duration? currentTime,
  }) = _HomeState;
}
