// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LapModel {
  Duration get time;
  Duration get totalTime;
  int get order;

  /// Create a copy of LapModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LapModelCopyWith<LapModel> get copyWith =>
      _$LapModelCopyWithImpl<LapModel>(this as LapModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LapModel &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.totalTime, totalTime) ||
                other.totalTime == totalTime) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, time, totalTime, order);

  @override
  String toString() {
    return 'LapModel(time: $time, totalTime: $totalTime, order: $order)';
  }
}

/// @nodoc
abstract mixin class $LapModelCopyWith<$Res> {
  factory $LapModelCopyWith(LapModel value, $Res Function(LapModel) _then) =
      _$LapModelCopyWithImpl;
  @useResult
  $Res call({Duration time, Duration totalTime, int order});
}

/// @nodoc
class _$LapModelCopyWithImpl<$Res> implements $LapModelCopyWith<$Res> {
  _$LapModelCopyWithImpl(this._self, this._then);

  final LapModel _self;
  final $Res Function(LapModel) _then;

  /// Create a copy of LapModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? totalTime = null,
    Object? order = null,
  }) {
    return _then(_self.copyWith(
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as Duration,
      totalTime: null == totalTime
          ? _self.totalTime
          : totalTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [LapModel].
extension LapModelPatterns on LapModel {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LapModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LapModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LapModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LapModel():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LapModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LapModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(Duration time, Duration totalTime, int order)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LapModel() when $default != null:
        return $default(_that.time, _that.totalTime, _that.order);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(Duration time, Duration totalTime, int order) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LapModel():
        return $default(_that.time, _that.totalTime, _that.order);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(Duration time, Duration totalTime, int order)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LapModel() when $default != null:
        return $default(_that.time, _that.totalTime, _that.order);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LapModel extends LapModel {
  const _LapModel(
      {this.time = Duration.zero,
      this.totalTime = Duration.zero,
      this.order = 0})
      : super._();

  @override
  @JsonKey()
  final Duration time;
  @override
  @JsonKey()
  final Duration totalTime;
  @override
  @JsonKey()
  final int order;

  /// Create a copy of LapModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LapModelCopyWith<_LapModel> get copyWith =>
      __$LapModelCopyWithImpl<_LapModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LapModel &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.totalTime, totalTime) ||
                other.totalTime == totalTime) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, time, totalTime, order);

  @override
  String toString() {
    return 'LapModel(time: $time, totalTime: $totalTime, order: $order)';
  }
}

/// @nodoc
abstract mixin class _$LapModelCopyWith<$Res>
    implements $LapModelCopyWith<$Res> {
  factory _$LapModelCopyWith(_LapModel value, $Res Function(_LapModel) _then) =
      __$LapModelCopyWithImpl;
  @override
  @useResult
  $Res call({Duration time, Duration totalTime, int order});
}

/// @nodoc
class __$LapModelCopyWithImpl<$Res> implements _$LapModelCopyWith<$Res> {
  __$LapModelCopyWithImpl(this._self, this._then);

  final _LapModel _self;
  final $Res Function(_LapModel) _then;

  /// Create a copy of LapModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? time = null,
    Object? totalTime = null,
    Object? order = null,
  }) {
    return _then(_LapModel(
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as Duration,
      totalTime: null == totalTime
          ? _self.totalTime
          : totalTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
