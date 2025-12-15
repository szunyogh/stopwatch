import 'package:freezed_annotation/freezed_annotation.dart';

part 'lap.freezed.dart';

@freezed
abstract class LapModel with _$LapModel {
  const LapModel._();
  const factory LapModel({
    @Default(Duration.zero) Duration time,
    @Default(Duration.zero) Duration totalTime,
    @Default(0) int order,
  }) = _LapModel;
}
