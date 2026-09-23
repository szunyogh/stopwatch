// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lap_details_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LapDetailsState {

 LapModel? get lap;
/// Create a copy of LapDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LapDetailsStateCopyWith<LapDetailsState> get copyWith => _$LapDetailsStateCopyWithImpl<LapDetailsState>(this as LapDetailsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LapDetailsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LapDetailsState&&(identical(other.lap, _this.lap) || other.lap == _this.lap));
}


@override
int get hashCode {
  final _this = this as LapDetailsState;
  return Object.hash(runtimeType,_this.lap);
}

@override
String toString() {
  final _this = this as LapDetailsState;
  return 'LapDetailsState(lap: ${_this.lap})';
}


}

/// @nodoc
abstract mixin class $LapDetailsStateCopyWith<$Res>  {
  factory $LapDetailsStateCopyWith(LapDetailsState value, $Res Function(LapDetailsState) _then) = _$LapDetailsStateCopyWithImpl;
@useResult
$Res call({
 LapModel? lap
});


$LapModelCopyWith<$Res>? get lap;

}
/// @nodoc
class _$LapDetailsStateCopyWithImpl<$Res>
    implements $LapDetailsStateCopyWith<$Res> {
  _$LapDetailsStateCopyWithImpl(this._self, this._then);

  final LapDetailsState _self;
  final $Res Function(LapDetailsState) _then;

/// Create a copy of LapDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lap = freezed,}) {
  return _then(LapDetailsState(
lap: freezed == lap ? _self.lap : lap // ignore: cast_nullable_to_non_nullable
as LapModel?,
  ));
}
/// Create a copy of LapDetailsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LapModelCopyWith<$Res>? get lap {
    if (_self.lap == null) {
    return null;
  }

  return $LapModelCopyWith<$Res>(_self.lap!, (value) {
    return _then(_self.copyWith(lap: value));
  });
}
}


/// Adds pattern-matching-related methods to [LapDetailsState].
extension LapDetailsStatePatterns on LapDetailsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LapDetailsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LapDetailsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LapDetailsState value)  $default,){
final _that = this;
switch (_that) {
case _LapDetailsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LapDetailsState value)?  $default,){
final _that = this;
switch (_that) {
case _LapDetailsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LapModel? lap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LapDetailsState() when $default != null:
return $default(_that.lap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LapModel? lap)  $default,) {final _that = this;
switch (_that) {
case _LapDetailsState():
return $default(_that.lap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LapModel? lap)?  $default,) {final _that = this;
switch (_that) {
case _LapDetailsState() when $default != null:
return $default(_that.lap);case _:
  return null;

}
}

}

/// @nodoc


class _LapDetailsState extends LapDetailsState {
  const _LapDetailsState({this.lap = null}): super._();
  

@override@JsonKey() final  LapModel? lap;

/// Create a copy of LapDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LapDetailsStateCopyWith<_LapDetailsState> get copyWith => __$LapDetailsStateCopyWithImpl<_LapDetailsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LapDetailsState&&(identical(other.lap, lap) || other.lap == lap));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lap);
}

@override
String toString() {
    return 'LapDetailsState(lap: $lap)';
}


}

/// @nodoc
abstract mixin class _$LapDetailsStateCopyWith<$Res> implements $LapDetailsStateCopyWith<$Res> {
  factory _$LapDetailsStateCopyWith(_LapDetailsState value, $Res Function(_LapDetailsState) _then) = __$LapDetailsStateCopyWithImpl;
@override @useResult
$Res call({
 LapModel? lap
});


@override $LapModelCopyWith<$Res>? get lap;

}
/// @nodoc
class __$LapDetailsStateCopyWithImpl<$Res>
    implements _$LapDetailsStateCopyWith<$Res> {
  __$LapDetailsStateCopyWithImpl(this._self, this._then);

  final _LapDetailsState _self;
  final $Res Function(_LapDetailsState) _then;

/// Create a copy of LapDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lap = freezed,}) {
  return _then(_LapDetailsState(
lap: freezed == lap ? _self.lap : lap // ignore: cast_nullable_to_non_nullable
as LapModel?,
  ));
}

/// Create a copy of LapDetailsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LapModelCopyWith<$Res>? get lap {
    if (_self.lap == null) {
    return null;
  }

  return $LapModelCopyWith<$Res>(_self.lap!, (value) {
    return _then(_self.copyWith(lap: value));
  });
}
}

// dart format on
