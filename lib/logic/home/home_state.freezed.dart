// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeState {
  Duration get time;
  bool get isRunning;
  List<LapModel> get laps;
  Duration? get currentTime;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HomeStateCopyWith<HomeState> get copyWith =>
      _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HomeState &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.isRunning, isRunning) ||
                other.isRunning == isRunning) &&
            const DeepCollectionEquality().equals(other.laps, laps) &&
            (identical(other.currentTime, currentTime) ||
                other.currentTime == currentTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, time, isRunning,
      const DeepCollectionEquality().hash(laps), currentTime);

  @override
  String toString() {
    return 'HomeState(time: $time, isRunning: $isRunning, laps: $laps, currentTime: $currentTime)';
  }
}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) =
      _$HomeStateCopyWithImpl;
  @useResult
  $Res call(
      {Duration time,
      bool isRunning,
      List<LapModel> laps,
      Duration? currentTime});
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res> implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? isRunning = null,
    Object? laps = null,
    Object? currentTime = freezed,
  }) {
    return _then(_self.copyWith(
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as Duration,
      isRunning: null == isRunning
          ? _self.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      laps: null == laps
          ? _self.laps
          : laps // ignore: cast_nullable_to_non_nullable
              as List<LapModel>,
      currentTime: freezed == currentTime
          ? _self.currentTime
          : currentTime // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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
    TResult Function(_HomeState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HomeState() when $default != null:
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
    TResult Function(_HomeState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HomeState():
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
    TResult? Function(_HomeState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HomeState() when $default != null:
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
    TResult Function(Duration time, bool isRunning, List<LapModel> laps,
            Duration? currentTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HomeState() when $default != null:
        return $default(
            _that.time, _that.isRunning, _that.laps, _that.currentTime);
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
    TResult Function(Duration time, bool isRunning, List<LapModel> laps,
            Duration? currentTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HomeState():
        return $default(
            _that.time, _that.isRunning, _that.laps, _that.currentTime);
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
    TResult? Function(Duration time, bool isRunning, List<LapModel> laps,
            Duration? currentTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HomeState() when $default != null:
        return $default(
            _that.time, _that.isRunning, _that.laps, _that.currentTime);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _HomeState extends HomeState {
  const _HomeState(
      {this.time = Duration.zero,
      this.isRunning = false,
      final List<LapModel> laps = const [],
      this.currentTime = null})
      : _laps = laps,
        super._();

  @override
  @JsonKey()
  final Duration time;
  @override
  @JsonKey()
  final bool isRunning;
  final List<LapModel> _laps;
  @override
  @JsonKey()
  List<LapModel> get laps {
    if (_laps is EqualUnmodifiableListView) return _laps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_laps);
  }

  @override
  @JsonKey()
  final Duration? currentTime;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HomeStateCopyWith<_HomeState> get copyWith =>
      __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HomeState &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.isRunning, isRunning) ||
                other.isRunning == isRunning) &&
            const DeepCollectionEquality().equals(other._laps, _laps) &&
            (identical(other.currentTime, currentTime) ||
                other.currentTime == currentTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, time, isRunning,
      const DeepCollectionEquality().hash(_laps), currentTime);

  @override
  String toString() {
    return 'HomeState(time: $time, isRunning: $isRunning, laps: $laps, currentTime: $currentTime)';
  }
}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(
          _HomeState value, $Res Function(_HomeState) _then) =
      __$HomeStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Duration time,
      bool isRunning,
      List<LapModel> laps,
      Duration? currentTime});
}

/// @nodoc
class __$HomeStateCopyWithImpl<$Res> implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? time = null,
    Object? isRunning = null,
    Object? laps = null,
    Object? currentTime = freezed,
  }) {
    return _then(_HomeState(
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as Duration,
      isRunning: null == isRunning
          ? _self.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      laps: null == laps
          ? _self._laps
          : laps // ignore: cast_nullable_to_non_nullable
              as List<LapModel>,
      currentTime: freezed == currentTime
          ? _self.currentTime
          : currentTime // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

// dart format on
