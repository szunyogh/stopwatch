import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stopwatch/model/lap.dart';

part 'lap_details_state.freezed.dart';

@freezed
abstract class LapDetailsState with _$LapDetailsState {
  const LapDetailsState._();
  const factory LapDetailsState({@Default(null) LapModel? lap}) = _LapDetailsState;
}
