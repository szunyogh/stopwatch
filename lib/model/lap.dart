import 'package:freezed_annotation/freezed_annotation.dart';

part 'lap.freezed.dart';
part 'lap.g.dart';

class DurationConverter implements JsonConverter<Duration, int> {
  const DurationConverter();

  @override
  Duration fromJson(int json) => Duration(microseconds: json);

  @override
  int toJson(Duration object) => object.inMicroseconds;
}

@freezed
abstract class LapModel with _$LapModel {
  const LapModel._();

  const factory LapModel({@DurationConverter() @Default(Duration.zero) Duration time, @DurationConverter() @Default(Duration.zero) Duration totalTime, @Default(0) int order}) = _LapModel;

  factory LapModel.fromJson(Map<String, dynamic> json) => _$LapModelFromJson(json);
}
