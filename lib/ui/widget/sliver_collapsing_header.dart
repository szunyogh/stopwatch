import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SliverCollapsingHeader extends StatefulWidget {
  const SliverCollapsingHeader({
    super.key,
    required this.children,
    this.spacing = 8,
    this.padding = const EdgeInsets.all(8),
    this.collapsedScale = 0.6,
    this.color,
    this.collapsedColorOpacity = 0.3,
    this.maxBlurSigma = 10,
    this.collapsedMainAxisAlignment,
    this.snap = true,
    this.snapThreshold = 0.5,
    this.snapDuration = const Duration(milliseconds: 350),
    this.snapCurve = Curves.easeOut,
  });

  final List<Widget> children;

  final double spacing;
  final EdgeInsets padding;

  final double collapsedScale;

  final Color? color;

  final double collapsedColorOpacity;

  final double maxBlurSigma;

  final MainAxisAlignment? collapsedMainAxisAlignment;

  final bool snap;

  final double snapThreshold;
  final Duration snapDuration;
  final Curve snapCurve;

  @override
  State<SliverCollapsingHeader> createState() => _SliverCollapsingHeaderState();
}

class _SliverCollapsingHeaderState extends State<SliverCollapsingHeader> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach();
  }

  @override
  void didUpdateWidget(SliverCollapsingHeader old) {
    super.didUpdateWidget(old);
    _attach();
  }

  @override
  void dispose() {
    _position?.isScrollingNotifier.removeListener(_onScrollingChanged);
    super.dispose();
  }

  void _attach() {
    final position = Scrollable.maybeOf(context, axis: Axis.vertical)?.position;
    if (position == _position) return;
    _position?.isScrollingNotifier.removeListener(_onScrollingChanged);
    _position = position;
    _position?.isScrollingNotifier.addListener(_onScrollingChanged);
  }

  void _onScrollingChanged() {
    final position = _position;
    if (position == null || position.isScrollingNotifier.value) return;
    scheduleMicrotask(_snap);
  }

  void _snap() {
    if (!mounted || !widget.snap) return;
    final position = _position;
    if (position == null || !position.hasPixels) return;
    if (position.isScrollingNotifier.value) return;

    final render = context.findRenderObject();
    if (render is! RenderSliverCollapsingHeader || render.geometry == null) {
      return;
    }
    final range = render.shrinkRange;
    final offset = render.constraints.scrollOffset;
    if (range <= 0 || offset <= 0 || offset >= range) return;

    var collapse = offset / range >= widget.snapThreshold;
    if (collapse && position.pixels + (range - offset) > position.maxScrollExtent + 0.5) {
      collapse = false;
    }
    final target = clampDouble(position.pixels + (collapse ? range - offset : -offset), position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() < 0.5) return;
    position.animateTo(target, duration: widget.snapDuration, curve: widget.snapCurve);
  }

  @override
  Widget build(BuildContext context) {
    return _HeaderRenderWidget(
      spacing: widget.spacing,
      padding: widget.padding,
      collapsedScale: widget.collapsedScale,
      color: widget.color,
      collapsedColorOpacity: widget.collapsedColorOpacity,
      maxBlurSigma: widget.maxBlurSigma,
      collapsedMainAxisAlignment: widget.collapsedMainAxisAlignment,
      children: widget.children,
    );
  }
}

class _HeaderRenderWidget extends MultiChildRenderObjectWidget {
  const _HeaderRenderWidget({
    required super.children,
    required this.spacing,
    required this.padding,
    required this.collapsedScale,
    required this.color,
    required this.collapsedColorOpacity,
    required this.maxBlurSigma,
    required this.collapsedMainAxisAlignment,
  });

  final double spacing;
  final EdgeInsets padding;
  final double collapsedScale;
  final Color? color;
  final double collapsedColorOpacity;
  final double maxBlurSigma;
  final MainAxisAlignment? collapsedMainAxisAlignment;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderSliverCollapsingHeader(
    spacing: spacing,
    padding: padding,
    collapsedScale: collapsedScale,
    color: color,
    collapsedColorOpacity: collapsedColorOpacity,
    maxBlurSigma: maxBlurSigma,
    collapsedMainAxisAlignment: collapsedMainAxisAlignment,
  );

  @override
  void updateRenderObject(BuildContext context, RenderSliverCollapsingHeader renderObject) {
    renderObject
      ..spacing = spacing
      ..padding = padding
      ..collapsedScale = collapsedScale
      ..color = color
      ..collapsedColorOpacity = collapsedColorOpacity
      ..maxBlurSigma = maxBlurSigma
      ..collapsedMainAxisAlignment = collapsedMainAxisAlignment;
  }
}

class _ParentData extends ContainerBoxParentData<RenderBox> {
  double scale = 1;
}

class RenderSliverCollapsingHeader extends RenderSliver with ContainerRenderObjectMixin<RenderBox, _ParentData> {
  RenderSliverCollapsingHeader({
    required this._spacing,
    required this._padding,
    required this._collapsedScale,
    required this._color,
    required this._collapsedColorOpacity,
    required this._maxBlurSigma,
    required this._collapsedMainAxisAlignment,
  });

  double _spacing;
  double get spacing => _spacing;
  set spacing(double v) {
    if (v == _spacing) return;
    _spacing = v;
    markNeedsLayout();
  }

  EdgeInsets _padding;
  EdgeInsets get padding => _padding;
  set padding(EdgeInsets v) {
    if (v == _padding) return;
    _padding = v;
    markNeedsLayout();
  }

  double _collapsedScale;
  double get collapsedScale => _collapsedScale;
  set collapsedScale(double v) {
    if (v == _collapsedScale) return;
    _collapsedScale = v;
    markNeedsLayout();
  }

  MainAxisAlignment? _collapsedMainAxisAlignment;
  MainAxisAlignment? get collapsedMainAxisAlignment => _collapsedMainAxisAlignment;
  set collapsedMainAxisAlignment(MainAxisAlignment? v) {
    if (v == _collapsedMainAxisAlignment) return;
    _collapsedMainAxisAlignment = v;
    markNeedsLayout();
  }

  Color? _color;
  Color? get color => _color;
  set color(Color? v) {
    if (v == _color) return;
    _color = v;
    markNeedsPaint();
  }

  double _collapsedColorOpacity;
  double get collapsedColorOpacity => _collapsedColorOpacity;
  set collapsedColorOpacity(double v) {
    if (v == _collapsedColorOpacity) return;
    _collapsedColorOpacity = v;
    markNeedsPaint();
  }

  double _maxBlurSigma;
  double get maxBlurSigma => _maxBlurSigma;
  set maxBlurSigma(double v) {
    if (v == _maxBlurSigma) return;
    final wasCompositing = alwaysNeedsCompositing;
    _maxBlurSigma = v;
    if (wasCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  double _t = 0;
  double get collapseProgress => _t;

  double _shrinkRange = 0;

  double get shrinkRange => _shrinkRange;

  final LayerHandle<BackdropFilterLayer> _blurLayer = LayerHandle<BackdropFilterLayer>();
  final LayerHandle<ClipRectLayer> _clipLayer = LayerHandle<ClipRectLayer>();

  @override
  bool get alwaysNeedsCompositing => _maxBlurSigma > 0;

  @override
  void dispose() {
    _blurLayer.layer = null;
    _clipLayer.layer = null;
    super.dispose();
  }

  @override
  void setupParentData(covariant RenderBox child) {
    if (child.parentData is! _ParentData) child.parentData = _ParentData();
  }

  @override
  void performLayout() {
    final cross = constraints.crossAxisExtent;
    final innerW = math.max(0.0, cross - padding.horizontal);

    final boxes = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      child.layout(BoxConstraints(maxWidth: innerW), parentUsesSize: true);
      boxes.add(child);
      child = childAfter(child);
    }
    if (boxes.isEmpty) {
      _t = 0;
      _shrinkRange = 0;
      geometry = SliverGeometry.zero;
      return;
    }

    final n = boxes.length;
    double sumW = 0, sumH = 0, maxH = 0;
    for (final b in boxes) {
      sumW += b.size.width;
      sumH += b.size.height;
      maxH = math.max(maxH, b.size.height);
    }
    final gaps = spacing * (n - 1);

    final maxE = padding.vertical + sumH + gaps;
    final fit = sumW == 0 ? 1.0 : (innerW - gaps) / sumW;
    final s = math.max(0.0, math.min(collapsedScale, fit));
    final minE = math.min(maxE, padding.vertical + maxH * s);
    _shrinkRange = maxE - minE;

    final scrollOffset = constraints.scrollOffset;
    final childExtent = math.max(minE, maxE - scrollOffset);
    final rawT = maxE == minE ? 1.0 : clampDouble((maxE - childExtent) / (maxE - minE), 0, 1);
    final t = rawT >= 0.999 ? 1.0 : (rawT <= 0.001 ? 0.0 : rawT);
    _t = t;

    final free = math.max(0.0, innerW - sumW * s - gaps);
    final (double leading, double between) = switch (collapsedMainAxisAlignment) {
      null || MainAxisAlignment.center => (free / 2, spacing),
      MainAxisAlignment.start => (0.0, spacing),
      MainAxisAlignment.end => (free, spacing),
      MainAxisAlignment.spaceBetween => (0.0, spacing + (n > 1 ? free / (n - 1) : 0.0)),
      MainAxisAlignment.spaceAround => (free / n / 2, spacing + free / n),
      MainAxisAlignment.spaceEvenly => (free / (n + 1), spacing + free / (n + 1)),
    };

    var yExpanded = padding.top;
    var xCollapsed = padding.left + leading;
    for (final b in boxes) {
      final w = b.size.width, h = b.size.height;
      final expanded = Offset(padding.left + (innerW - w) / 2, yExpanded);
      final collapsed = Offset(xCollapsed, padding.top + (minE - padding.vertical - h * s) / 2);
      final pd = b.parentData as _ParentData;
      pd.offset = Offset.lerp(expanded, collapsed, t)!;
      pd.scale = lerpDouble(1, s, t)!;
      yExpanded += h + spacing;
      xCollapsed += w * s + between;
    }

    final remaining = math.max(0.0, constraints.remainingPaintExtent - constraints.overlap);
    final layoutExtent = clampDouble(maxE - scrollOffset, 0, remaining);
    geometry = SliverGeometry(
      scrollExtent: maxE,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, remaining),
      layoutExtent: layoutExtent,
      maxPaintExtent: maxE,
      maxScrollObstructionExtent: minE,
      cacheExtent: layoutExtent > 0 ? -constraints.cacheOrigin + layoutExtent : layoutExtent,
      hasVisualOverflow: true,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final geo = geometry!;
    if (firstChild == null || !geo.visible) return;
    final bounds = Offset.zero & Size(constraints.crossAxisExtent, geo.paintExtent);

    final animating = _t > 0 && _t < 1;

    void paintContent(PaintingContext ctx, Offset off) {
      final c = color;
      if (c != null) {
        final alpha = c.a * lerpDouble(1, collapsedColorOpacity, _t)!;
        ctx.canvas.drawRect(off & bounds.size, Paint()..color = c.withValues(alpha: clampDouble(alpha, 0, 1)));
      }
      var child = firstChild;
      while (child != null) {
        final current = child;
        final pd = current.parentData as _ParentData;
        final target = off + pd.offset;

        if (animating) {
          final q = off;
          final m = Matrix4.translationValues(target.dx, target.dy, 0)
            ..scaleByDouble(pd.scale, pd.scale, 1, 1)
            ..translateByDouble(-q.dx, -q.dy, 0, 1);
          ctx.pushLayer(ImageFilterLayer(imageFilter: ImageFilter.matrix(m.storage, filterQuality: FilterQuality.high)), (c, o) => c.paintChild(current, o), q);
        } else {
          ctx.pushTransform(needsCompositing, target, Matrix4.diagonal3Values(pd.scale, pd.scale, 1), (c, o) => c.paintChild(current, o));
        }
        child = childAfter(current);
      }
    }

    if (animating) {
      _clipLayer.layer = null;
      paintContent(context, offset);
      return;
    }

    final sigma = lerpDouble(0, maxBlurSigma, _t)!;
    final blur = sigma > 0.5 && constraints.scrollOffset >= _shrinkRange - 0.5;

    if (blur) {
      final layer = _blurLayer.layer ??= BackdropFilterLayer();
      layer.filter = ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
      _clipLayer.layer = context.pushClipRect(needsCompositing, offset, bounds, (ctx, off) => ctx.pushLayer(layer, paintContent, off), oldLayer: _clipLayer.layer);
    } else {
      _clipLayer.layer = context.pushClipRect(needsCompositing, offset, bounds, paintContent, oldLayer: _clipLayer.layer);
    }
  }

  @override
  bool hitTestChildren(SliverHitTestResult result, {required double mainAxisPosition, required double crossAxisPosition}) {
    final position = Offset(crossAxisPosition, mainAxisPosition);
    var child = lastChild;
    while (child != null) {
      final current = child;
      final pd = current.parentData as _ParentData;
      final hit = BoxHitTestResult.wrap(result).addWithPaintTransform(
        transform: Matrix4.translationValues(pd.offset.dx, pd.offset.dy, 0)..scaleByDouble(pd.scale, pd.scale, 1.0, 1.0),
        position: position,
        hitTest: (r, p) => current.hitTest(r, position: p),
      );
      if (hit) return true;
      child = childBefore(current);
    }
    return false;
  }

  @override
  void applyPaintTransform(covariant RenderBox child, Matrix4 transform) {
    final pd = child.parentData as _ParentData;
    transform.translateByDouble(pd.offset.dx, pd.offset.dy, 0.0, 1.0);
    transform.scaleByDouble(pd.scale, pd.scale, 1.0, 1.0);
  }

  @override
  double childMainAxisPosition(covariant RenderBox child) => 0;
}

class SliverCollapsingHeaderFooter extends LeafRenderObjectWidget {
  const SliverCollapsingHeaderFooter({super.key});

  @override
  RenderObject createRenderObject(BuildContext context) => RenderSliverCollapsingHeaderFooter();
}

class RenderSliverCollapsingHeaderFooter extends RenderSliver {
  RenderSliverCollapsingHeader? _findHeader() {
    final p = parent;
    if (p is! RenderViewportBase) return null;
    var sliver = p.childBefore(this);
    while (sliver != null) {
      if (sliver is RenderSliverCollapsingHeader) return sliver;
      sliver = p.childBefore(sliver);
    }
    return null;
  }

  @override
  void performLayout() {
    final range = _findHeader()?.shrinkRange ?? 0.0;
    final extent = math.max(0.0, constraints.viewportMainAxisExtent + range - constraints.precedingScrollExtent);
    final paintExtent = calculatePaintOffset(constraints, from: 0, to: extent);
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: paintExtent,
      maxPaintExtent: extent,
      cacheExtent: calculateCacheOffset(constraints, from: 0, to: extent),
    );
  }
}
