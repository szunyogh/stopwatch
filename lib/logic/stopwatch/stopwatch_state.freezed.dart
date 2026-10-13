// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stopwatch_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StopwatchState {

 Duration get time; bool get isRunning; List<LapModel> get laps; Duration? get currentTime;
/// Create a copy of StopwatchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StopwatchStateCopyWith<StopwatchState> get copyWith => _$StopwatchStateCopyWithImpl<StopwatchState>(this as StopwatchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StopwatchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StopwatchState&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.isRunning, _this.isRunning) || other.isRunning == _this.isRunning)&&const DeepCollectionEquality().equals(other.laps, _this.laps)&&(identical(other.currentTime, _this.currentTime) || other.currentTime == _this.currentTime));
}


@override
int get hashCode {
  final _this = this as StopwatchState;
  return Object.hash(runtimeType,_this.time,_this.isRunning,const DeepCollectionEquality().hash(_this.laps),_this.currentTime);
}

@override
String toString() {
  final _this = this as StopwatchState;
  return 'StopwatchState(time: ${_this.time}, isRunning: ${_this.isRunning}, laps: ${_this.laps}, currentTime: ${_this.currentTime})';
}


}

/// @nodoc
abstract mixin class $StopwatchStateCopyWith<$Res>  {
  factory $StopwatchStateCopyWith(StopwatchState value, $Res Function(StopwatchState) _then) = _$StopwatchStateCopyWithImpl;
@useResult
$Res call({
 Duration time, bool isRunning, List<LapModel> laps, Duration? currentTime
});




}
/// @nodoc
class _$StopwatchStateCopyWithImpl<$Res>
    implements $StopwatchStateCopyWith<$Res> {
  _$StopwatchStateCopyWithImpl(this._self, this._then);

  final StopwatchState _self;
  final $Res Function(StopwatchState) _then;

/// Create a copy of StopwatchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? isRunning = null,Object? laps = null,Object? currentTime = freezed,}) {
  return _then(StopwatchState(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as Duration,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,laps: null == laps ? _self.laps : laps // ignore: cast_nullable_to_non_nullable
as List<LapModel>,currentTime: freezed == currentTime ? _self.currentTime : currentTime // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [StopwatchState].
extension StopwatchStatePatterns on StopwatchState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StopwatchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StopwatchState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StopwatchState value)  $default,){
final _that = this;
switch (_that) {
case _StopwatchState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StopwatchState value)?  $default,){
final _that = this;
switch (_that) {
case _StopwatchState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration time,  bool isRunning,  List<LapModel> laps,  Duration? currentTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StopwatchState() when $default != null:
return $default(_that.time,_that.isRunning,_that.laps,_that.currentTime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration time,  bool isRunning,  List<LapModel> laps,  Duration? currentTime)  $default,) {final _that = this;
switch (_that) {
case _StopwatchState():
return $default(_that.time,_that.isRunning,_that.laps,_that.currentTime);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration time,  bool isRunning,  List<LapModel> laps,  Duration? currentTime)?  $default,) {final _that = this;
switch (_that) {
case _StopwatchState() when $default != null:
return $default(_that.time,_that.isRunning,_that.laps,_that.currentTime);case _:
  return null;

}
}

}

/// @nodoc


class _StopwatchState extends StopwatchState {
  const _StopwatchState({this.time = Duration.zero, this.isRunning = false,  List<LapModel> laps = const [], this.currentTime = null}): _laps = laps,super._();
  

@override@JsonKey() final  Duration time;
@override@JsonKey() final  bool isRunning;
 final  List<LapModel> _laps;
@override@JsonKey() List<LapModel> get laps {
  if (_laps is EqualUnmodifiableListView) return _laps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_laps);
}

@override@JsonKey() final  Duration? currentTime;

/// Create a copy of StopwatchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StopwatchStateCopyWith<_StopwatchState> get copyWith => __$StopwatchStateCopyWithImpl<_StopwatchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StopwatchState&&(identical(other.time, time) || other.time == time)&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&const DeepCollectionEquality().equals(other.laps, _laps)&&(identical(other.currentTime, currentTime) || other.currentTime == currentTime));
}


@override
int get hashCode {
    return Object.hash(runtimeType,time,isRunning,const DeepCollectionEquality().hash(_laps),currentTime);
}

@override
String toString() {
    return 'StopwatchState(time: $time, isRunning: $isRunning, laps: $laps, currentTime: $currentTime)';
}


}

/// @nodoc
abstract mixin class _$StopwatchStateCopyWith<$Res> implements $StopwatchStateCopyWith<$Res> {
  factory _$StopwatchStateCopyWith(_StopwatchState value, $Res Function(_StopwatchState) _then) = __$StopwatchStateCopyWithImpl;
@override @useResult
$Res call({
 Duration time, bool isRunning, List<LapModel> laps, Duration? currentTime
});




}
/// @nodoc
class __$StopwatchStateCopyWithImpl<$Res>
    implements _$StopwatchStateCopyWith<$Res> {
  __$StopwatchStateCopyWithImpl(this._self, this._then);

  final _StopwatchState _self;
  final $Res Function(_StopwatchState) _then;

/// Create a copy of StopwatchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? isRunning = null,Object? laps = null,Object? currentTime = freezed,}) {
  return _then(_StopwatchState(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as Duration,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,laps: null == laps ? _self._laps : laps // ignore: cast_nullable_to_non_nullable
as List<LapModel>,currentTime: freezed == currentTime ? _self.currentTime : currentTime // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
