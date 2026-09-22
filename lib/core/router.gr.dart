// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i3;
import 'package:flutter/material.dart' as _i5;
import 'package:stopwatch/model/lap.dart' as _i4;
import 'package:stopwatch/ui/page/home.dart' as _i1;
import 'package:stopwatch/ui/page/lap_details.dart' as _i2;

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i3.PageRouteInfo<void> {
  const HomeRoute({List<_i3.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomePage();
    },
  );
}

/// generated route for
/// [_i2.LapDetailsPage]
class LapDetailsRoute extends _i3.PageRouteInfo<LapDetailsRouteArgs> {
  LapDetailsRoute({
    required _i4.LapModel lap,
    required _i5.Rect itemRect,
    _i5.Key? key,
    List<_i3.PageRouteInfo>? children,
  }) : super(
         LapDetailsRoute.name,
         args: LapDetailsRouteArgs(lap: lap, itemRect: itemRect, key: key),
         initialChildren: children,
       );

  static const String name = 'LapDetailsRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LapDetailsRouteArgs>();
      return _i2.LapDetailsPage(args.lap, args.itemRect, key: args.key);
    },
  );
}

class LapDetailsRouteArgs {
  const LapDetailsRouteArgs({
    required this.lap,
    required this.itemRect,
    this.key,
  });

  final _i4.LapModel lap;

  final _i5.Rect itemRect;

  final _i5.Key? key;

  @override
  String toString() {
    return 'LapDetailsRouteArgs{lap: $lap, itemRect: $itemRect, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LapDetailsRouteArgs) return false;
    return lap == other.lap && itemRect == other.itemRect && key == other.key;
  }

  @override
  int get hashCode => lap.hashCode ^ itemRect.hashCode ^ key.hashCode;
}
