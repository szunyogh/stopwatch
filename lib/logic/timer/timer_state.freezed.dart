// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimerState {

 Duration get time; bool get isRunning;
/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerStateCopyWith<TimerState> get copyWith => _$TimerStateCopyWithImpl<TimerState>(this as TimerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TimerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerState&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.isRunning, _this.isRunning) || other.isRunning == _this.isRunning));
}


@override
int get hashCode {
  final _this = this as TimerState;
  return Object.hash(runtimeType,_this.time,_this.isRunning);
}

@override
String toString() {
  final _this = this as TimerState;
  return 'TimerState(time: ${_this.time}, isRunning: ${_this.isRunning})';
}


}

/// @nodoc
abstract mixin class $TimerStateCopyWith<$Res>  {
  factory $TimerStateCopyWith(TimerState value, $Res Function(TimerState) _then) = _$TimerStateCopyWithImpl;
@useResult
$Res call({
 Duration time, bool isRunning
});




}
/// @nodoc
class _$TimerStateCopyWithImpl<$Res>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._self, this._then);

  final TimerState _self;
  final $Res Function(TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? isRunning = null,}) {
  return _then(TimerState(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as Duration,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TimerState].
extension TimerStatePatterns on TimerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerState value)  $default,){
final _that = this;
switch (_that) {
case _TimerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerState value)?  $default,){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration time,  bool isRunning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.time,_that.isRunning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration time,  bool isRunning)  $default,) {final _that = this;
switch (_that) {
case _TimerState():
return $default(_that.time,_that.isRunning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration time,  bool isRunning)?  $default,) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.time,_that.isRunning);case _:
  return null;

}
}

}

/// @nodoc


class _TimerState extends TimerState {
  const _TimerState({this.time = Duration.zero, this.isRunning = false}): super._();
  

@override@JsonKey() final  Duration time;
@override@JsonKey() final  bool isRunning;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerStateCopyWith<_TimerState> get copyWith => __$TimerStateCopyWithImpl<_TimerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerState&&(identical(other.time, time) || other.time == time)&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning));
}


@override
int get hashCode {
    return Object.hash(runtimeType,time,isRunning);
}

@override
String toString() {
    return 'TimerState(time: $time, isRunning: $isRunning)';
}


}

/// @nodoc
abstract mixin class _$TimerStateCopyWith<$Res> implements $TimerStateCopyWith<$Res> {
  factory _$TimerStateCopyWith(_TimerState value, $Res Function(_TimerState) _then) = __$TimerStateCopyWithImpl;
@override @useResult
$Res call({
 Duration time, bool isRunning
});




}
/// @nodoc
class __$TimerStateCopyWithImpl<$Res>
    implements _$TimerStateCopyWith<$Res> {
  __$TimerStateCopyWithImpl(this._self, this._then);

  final _TimerState _self;
  final $Res Function(_TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? isRunning = null,}) {
  return _then(_TimerState(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as Duration,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
