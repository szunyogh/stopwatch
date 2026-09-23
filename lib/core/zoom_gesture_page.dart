import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ZoomGesturePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Object? tag;

  ZoomGesturePageRoute({required this.builder, this.tag, super.settings});

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
      Element? childElement;
      (context as Element).visitChildren((element) {
        childElement = element;
      });
      if (childElement != null) {
        widget = childElement!.widget;
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
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
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
        final isQuickFlick = velocity.pixelsPerSecond.dy > 500;
        final isDraggedFarEnough = currentVal < (startAnimationValue * 0.7);

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

enum ZoomSlot { target, source }

class ZoomPageTransitionLayout extends SlottedMultiChildRenderObjectWidget<ZoomSlot, RenderBox> {
  final double progress;
  final Rect sourceRect;
  final BorderRadius sourceBorderRadius;
  final Color backgroundColor;
  final Widget child;
  final Widget? sourceWidget;

  const ZoomPageTransitionLayout({
    super.key,
    required this.progress,
    required this.sourceRect,
    required this.sourceBorderRadius,
    required this.backgroundColor,
    required this.child,
    this.sourceWidget,
  });

  @override
  Iterable<ZoomSlot> get slots => [ZoomSlot.target, if (sourceWidget != null) ZoomSlot.source];

  @override
  Widget? childForSlot(ZoomSlot slot) {
    switch (slot) {
      case ZoomSlot.target:
        return child;
      case ZoomSlot.source:
        return sourceWidget;
    }
  }

  @override
  RenderZoomTransitionLayout createRenderObject(BuildContext context) {
    return RenderZoomTransitionLayout(progress: progress, sourceRect: sourceRect, sourceBorderRadius: sourceBorderRadius, backgroundColor: backgroundColor);
  }

  @override
  void updateRenderObject(BuildContext context, RenderZoomTransitionLayout renderObject) {
    renderObject
      ..progress = progress
      ..sourceRect = sourceRect
      ..sourceBorderRadius = sourceBorderRadius
      ..backgroundColor = backgroundColor;
  }
}

class RenderZoomTransitionLayout extends RenderBox with SlottedContainerRenderObjectMixin<ZoomSlot, RenderBox> {
  double _progress;
  Rect _sourceRect;
  BorderRadius _sourceBorderRadius;
  Color _backgroundColor;

  RenderZoomTransitionLayout({required this._progress, required this._sourceRect, required this._sourceBorderRadius, required this._backgroundColor});

  set progress(double value) {
    if (_progress == value) return;
    _progress = value;
    markNeedsPaint();
  }

  set sourceRect(Rect value) {
    if (_sourceRect == value) return;
    _sourceRect = value;
    markNeedsLayout();
  }

  set sourceBorderRadius(BorderRadius value) {
    if (_sourceBorderRadius == value) return;
    _sourceBorderRadius = value;
    markNeedsPaint();
  }

  set backgroundColor(Color value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  RenderBox? get targetChild => childForSlot(ZoomSlot.target);
  RenderBox? get sourceChild => childForSlot(ZoomSlot.source);

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (targetChild != null) {
      return targetChild!.hitTest(result, position: position);
    }
    return false;
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    if (targetChild != null) {
      targetChild!.layout(BoxConstraints.tight(size), parentUsesSize: false);
    }

    if (sourceChild != null && _sourceRect.width > 0 && _sourceRect.height > 0) {
      sourceChild!.layout(BoxConstraints.tight(_sourceRect.size), parentUsesSize: false);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final progress = _progress.clamp(0.0, 1.0);
    if (progress <= 0.0) return;

    final fullRect = offset & size;
    final currentRect = Rect.lerp(_sourceRect, fullRect, progress)!;
    final currentRadius = BorderRadius.lerp(_sourceBorderRadius, BorderRadius.zero, progress)!;
    final clipRRect = currentRadius.toRRect(currentRect);

    final sourceOpacity = (1.0 - (progress / 0.35)).clamp(0.0, 1.0);
    final targetOpacity = (progress / 0.35).clamp(0.0, 1.0);

    final bgPaint = Paint()..color = _backgroundColor;
    context.canvas.drawRRect(clipRRect, bgPaint);

    context.pushClipRRect(needsCompositing, offset, currentRect, clipRRect, (PaintingContext context, Offset offset) {
      if (targetChild != null && targetOpacity > 0.0) {
        final scale = currentRect.width / size.width;

        context.pushOpacity(offset, (targetOpacity * 255).round().clamp(0, 255), (PaintingContext context, Offset offset) {
          context.canvas.save();
          context.canvas.translate(currentRect.left, currentRect.top);
          context.canvas.scale(scale, scale);
          context.paintChild(targetChild!, Offset.zero);
          context.canvas.restore();
        });
      }

      if (sourceChild != null && sourceOpacity > 0.0 && _sourceRect.width > 0) {
        final scale = currentRect.width / _sourceRect.width;

        context.pushOpacity(offset, (sourceOpacity * 255).round().clamp(0, 255), (PaintingContext context, Offset offset) {
          context.canvas.save();
          context.canvas.translate(currentRect.left, currentRect.top);
          context.canvas.scale(scale, scale);
          context.paintChild(sourceChild!, Offset.zero);
          context.canvas.restore();
        });
      }
    });
  }
}

class VerticalDismissGestureRecognizer extends OneSequenceGestureRecognizer {
  final VoidCallback onDismissStart;
  final ValueChanged<double> onDismissUpdate;
  final ValueChanged<Velocity> onDismissEnd;
  final bool Function() canStart;

  int? _primaryPointer;
  double _initialY = 0.0;
  bool _isAccepted = false;
  VelocityTracker? _velocityTracker;

  VerticalDismissGestureRecognizer({required this.onDismissStart, required this.onDismissUpdate, required this.onDismissEnd, required this.canStart});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!canStart()) return;

    startTrackingPointer(event.pointer, event.transform);
    if (_primaryPointer == null) {
      _primaryPointer = event.pointer;
      _initialY = event.position.dy;
      _isAccepted = false;
      _velocityTracker = VelocityTracker.withKind(event.kind);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _primaryPointer) return;

    _velocityTracker?.addPosition(event.timeStamp, event.position);

    if (event is PointerMoveEvent) {
      final deltaY = event.position.dy - _initialY;

      if (!_isAccepted && deltaY > 15) {
        _isAccepted = true;
        resolve(GestureDisposition.accepted);
        onDismissStart();
      }

      if (_isAccepted) {
        onDismissUpdate(deltaY);
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      if (_isAccepted) {
        final velocity = _velocityTracker?.getVelocity() ?? Velocity.zero;
        onDismissEnd(velocity);
      }
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void acceptGesture(int pointer) {}

  @override
  void rejectGesture(int pointer) {
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _primaryPointer = null;
    _isAccepted = false;
    _velocityTracker = null;
  }

  @override
  String get debugDescription => 'vertical_dismiss';
}
