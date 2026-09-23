import 'package:flutter/material.dart';

import 'vertical_dismiss_gesture_recognizer.dart';
import 'zoom_page_transition_layout.dart';

/// Builds the animated transition used by [ZoomGesturePageRoute]:
/// a cross-fade + rect/border-radius morph between the source widget and
/// the destination page, plus a vertical swipe-to-dismiss gesture once the
/// transition has completed.
class ZoomPageTransition extends AnimatedWidget {
  final Rect sourceRect;
  final BorderRadius sourceBorderRadius;
  final Widget? sourceWidget;
  final Color backgroundColor;
  final Widget child;

  final VoidCallback onDismissStart;
  final ValueChanged<double> onDismissUpdate;
  final ValueChanged<Velocity> onDismissEnd;
  final bool Function() canStartDismiss;

  const ZoomPageTransition({
    super.key,
    required Animation<double> animation,
    required this.sourceRect,
    required this.sourceBorderRadius,
    required this.sourceWidget,
    required this.backgroundColor,
    required this.onDismissStart,
    required this.onDismissUpdate,
    required this.onDismissEnd,
    required this.canStartDismiss,
    required this.child,
  }) : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final progress = animation.value.clamp(0.0, 1.0);

    if (progress <= 0.0) return const SizedBox.shrink();

    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        VerticalDismissGestureRecognizer: GestureRecognizerFactoryWithHandlers<VerticalDismissGestureRecognizer>(
          () => VerticalDismissGestureRecognizer(onDismissStart: onDismissStart, onDismissUpdate: onDismissUpdate, onDismissEnd: onDismissEnd, canStart: canStartDismiss),
          (instance) {},
        ),
      },
      child: ZoomPageTransitionLayout(
        progress: progress,
        sourceRect: sourceRect,
        sourceBorderRadius: sourceBorderRadius,
        backgroundColor: backgroundColor,
        sourceWidget: sourceWidget != null
            ? Material(
                type: MaterialType.transparency,
                child: IgnorePointer(child: sourceWidget),
              )
            : null,
        child: child,
      ),
    );
  }
}
