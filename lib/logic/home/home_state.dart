import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();
  const factory HomeState({@Default(Rect.zero) Rect stopwatchButtonRect, @Default(Rect.zero) Rect timerButtonRect}) = _HomeState;
}
