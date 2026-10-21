import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stopwatch/ui/theme/color.dart';

class DialogPopupRoute<T> extends PopupRoute<T> {
  final Widget child;

  DialogPopupRoute(this.child, {super.settings});

  @override
  Color? get barrierColor => AppColors.primaryColor.withValues(alpha: .05);

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'dialog';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: Center(child: child),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final blurSigma = lerpDouble(0, 10, animation.value) ?? 0.0;
    final color = Color.lerp(Colors.transparent, barrierColor, animation.value);
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(color: color),
        ),
        buildPage(context, animation, secondaryAnimation),
      ],
    );
  }
}
