import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PredictiveBackEvent;

import 'zoom_page_transition.dart';

/// Factor by which raw predictive-back progress is dampened before being
/// applied to the transition controller.
const double _kBackGestureDampening = 4.0;

/// Minimum downward fling velocity (logical px/s) that counts as a "quick
/// flick" dismiss, regardless of how far the page was dragged.
const double _kDismissFlickVelocity = 500.0;

/// Fraction of the starting animation value the user must drag past before
/// a slower (non-flick) drag still counts as a dismiss.
const double _kDismissDistanceFactor = 0.7;

/// A [PageRoute] that transitions into the new page with a "zoom"
/// (container-transform style) animation originating from a source widget,
/// identified via [tag].
///
/// Supports:
/// - Predictive back gesture (Android) via [PredictiveBackEvent], forwarded
///   from [WidgetsBindingObserver] by [_PredictiveBackForwarder] into this
///   route's own handleStartBackGesture/handleUpdateBackGestureProgress/
///   handleCommitBackGesture/handleCancelBackGesture.
/// - Vertical swipe-to-dismiss once the page transition has completed.
class ZoomGesturePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Object? tag;

  ZoomGesturePageRoute({required this.builder, this.tag, super.settings});

  late final _predictiveBackForwarder = _PredictiveBackForwarder(this);

  @override
  void install() {
    super.install();
    WidgetsBinding.instance.addObserver(_predictiveBackForwarder);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_predictiveBackForwarder);
    super.dispose();
  }

  late final Rect sourceRect = _getRectFromTag(tag);
  late final BorderRadius sourceBorderRadius = _getBorderRadiusFromTag(tag);
  late final Widget? sourceWidget = _getWidgetFromTag(tag);

  static BuildContext? _findContextByTag(Object? tag) {
    if (tag == null) return null;
    final context = GlobalObjectKey(tag).currentContext;
    if (context != null && context.mounted) return context;
    return null;
  }

  static Rect _getRectFromTag(Object? tag) {
    final context = _findContextByTag(tag);

    if (context == null) return Rect.zero;

    final renderBox = context.findRenderObject() as RenderBox?;

    if (renderBox != null && renderBox.hasSize) {
      return renderBox.localToGlobal(Offset.zero) & renderBox.size;
    }

    return Rect.zero;
  }

  static BorderRadius _getBorderRadiusFromTag(Object? tag) {
    final context = _findContextByTag(tag);

    if (context == null) return BorderRadius.zero;

    BorderRadius? foundRadius;

    void checkWidget(Widget widget) {
      if (widget is ClipRRect && widget.borderRadius is BorderRadius) {
        foundRadius = widget.borderRadius as BorderRadius;
      } else if (widget is Container && widget.decoration is BoxDecoration) {
        final dec = widget.decoration as BoxDecoration;

        if (dec.borderRadius is BorderRadius) {
          foundRadius = dec.borderRadius as BorderRadius;
        }
      } else if (widget is Card && widget.shape is RoundedRectangleBorder) {
        final shape = widget.shape as RoundedRectangleBorder;

        if (shape.borderRadius is BorderRadius) {
          foundRadius = shape.borderRadius as BorderRadius;
        }
      } else if (widget is Material && widget.borderRadius is BorderRadius) {
        foundRadius = widget.borderRadius as BorderRadius;
      }
    }

    void visitChildren(Element element) {
      if (foundRadius != null) return;

      checkWidget(element.widget);
      element.visitChildren(visitChildren);
    }

    bool visitAncestor(Element element) {
      checkWidget(element.widget);
      return foundRadius == null;
    }

    if (context is Element) {
      visitChildren(context);

      if (foundRadius == null) {
        context.visitAncestorElements(visitAncestor);
      }
    }

    return foundRadius ?? BorderRadius.zero;
  }

  static Widget? _getWidgetFromTag(Object? tag) {
    final context = _findContextByTag(tag);

    if (context == null) return null;

    Widget widget = context.widget;

    if (widget.key is GlobalKey) {
      Element? firstChildElement;

      (context as Element).visitChildren((element) {
        firstChildElement ??= element;
      });

      if (firstChildElement != null) {
        widget = firstChildElement!.widget;
      }
    }

    return widget;
  }

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.5);

  @override
  String? get barrierLabel => 'zoom_page_route';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 240);

  @override
  bool get maintainState => true;

  @override
  bool get popGestureEnabled => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  double _remapProgress(double raw) => (raw / _kBackGestureDampening).clamp(0.0, 1.0);

  @override
  void handleStartBackGesture({double progress = 0.0}) {
    assert(isCurrent);

    controller?.stop();

    controller?.value = (1.0 - _remapProgress(progress)).clamp(0.0, 1.0);

    navigator?.didStartUserGesture();
  }

  @override
  void handleUpdateBackGestureProgress({required double progress}) {
    if (!isCurrent) return;

    controller?.value = (1.0 - _remapProgress(progress)).clamp(0.0, 1.0);
  }

  @override
  void handleCancelBackGesture() {
    if (isCurrent) {
      controller?.animateTo(1.0, duration: transitionDuration, curve: Curves.easeOutCubic);
    }

    navigator?.didStopUserGesture();
  }

  @override
  void handleCommitBackGesture() {
    navigator?.didStopUserGesture();

    navigator?.pop();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    double startAnimationValue = 1.0;

    return ZoomPageTransition(
      animation: animation,
      sourceRect: sourceRect,
      sourceBorderRadius: sourceBorderRadius,
      sourceWidget: sourceWidget,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      canStartDismiss: () => controller?.status == AnimationStatus.completed,

      onDismissStart: () {
        navigator?.didStartUserGesture();

        controller?.stop();

        startAnimationValue = controller?.value ?? 1.0;
      },

      onDismissUpdate: (deltaY) {
        final maxHeight = MediaQuery.sizeOf(context).height;

        final progress = (startAnimationValue - (deltaY / maxHeight)).clamp(0.0, 1.0);

        controller?.value = progress;
      },

      onDismissEnd: (velocity) {
        navigator?.didStopUserGesture();

        final currentVal = controller?.value ?? 0.0;

        final isQuickFlick = velocity.pixelsPerSecond.dy > _kDismissFlickVelocity;

        final isDraggedFarEnough = currentVal < (startAnimationValue * _kDismissDistanceFactor);

        if (isQuickFlick || isDraggedFarEnough || currentVal < 0.5) {
          navigator?.pop();
        } else {
          controller?.animateTo(1.0, curve: Curves.easeOutCubic);
        }
      },

      child: child,
    );
  }
}

/// Forwards platform predictive-back gesture callbacks (delivered to
/// [WidgetsBindingObserver]s) to the [ZoomGesturePageRoute] that owns this
/// observer. The route's own handleStartBackGesture/etc. overrides only
/// drive its animation controller — they are never invoked directly by the
/// framework, so this forwarder is what actually wires the route into the
/// system predictive-back gesture.
class _PredictiveBackForwarder with WidgetsBindingObserver {
  final ZoomGesturePageRoute route;
  _PredictiveBackForwarder(this.route);

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (!route.isCurrent || !route.popGestureEnabled) return false;
    route.handleStartBackGesture(progress: backEvent.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) => route.handleUpdateBackGestureProgress(progress: backEvent.progress);

  @override
  void handleCommitBackGesture() => route.handleCommitBackGesture();

  @override
  void handleCancelBackGesture() => route.handleCancelBackGesture();
}
