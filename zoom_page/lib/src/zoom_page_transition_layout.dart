import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Identifies the two children laid out by [ZoomPageTransitionLayout].
enum ZoomSlot { target, source }

/// Progress fraction (of the whole transition) over which the source and
/// target children cross-fade into/out of view.
const double _kCrossfadeThreshold = 0.35;

/// Lays out the incoming page ([ZoomSlot.target]) at full size and the
/// (optional) source widget ([ZoomSlot.source]) at its original on-screen
/// size, so [RenderZoomTransitionLayout] can morph between the two rects.
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

/// Render object that paints and interpolates between the source rect and
/// the full-screen target rect, cross-fading the two children as it goes.
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

    final sourceOpacity = (1.0 - (progress / _kCrossfadeThreshold)).clamp(0.0, 1.0);

    final targetOpacity = (progress / _kCrossfadeThreshold).clamp(0.0, 1.0);

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

      if (sourceChild != null && sourceOpacity > 0.0 && _sourceRect.width > 0 && _sourceRect.height > 0) {
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
