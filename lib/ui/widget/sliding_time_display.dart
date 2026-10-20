import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class SlidingTimeDisplay extends LeafRenderObjectWidget {
  const SlidingTimeDisplay({super.key, required this.elapsed, required this.textStyle, this.countdown = false, this.duration = const Duration(milliseconds: 300), this.onPicked});

  final Duration elapsed;

  final bool countdown;

  final TextStyle textStyle;

  final Duration duration;

  final ValueChanged<Duration>? onPicked;

  @override
  RenderSlidingTime createRenderObject(BuildContext context) => RenderSlidingTime(elapsed: elapsed, countdown: countdown, textStyle: textStyle, duration: duration, onPicked: onPicked);

  @override
  void updateRenderObject(BuildContext context, RenderSlidingTime renderObject) {
    renderObject
      ..textStyle = textStyle
      ..duration = duration
      ..countdown = countdown
      ..onPicked = onPicked
      ..elapsed = elapsed;
  }
}

class _GlyphSet {
  _GlyphSet(TextStyle style) {
    for (final t in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', '.']) {
      painters.add(
        TextPainter(
          text: TextSpan(text: t, style: style),
          textDirection: TextDirection.ltr,
        )..layout(),
      );
    }
    for (var i = 0; i < painters.length; i++) {
      if (painters[i].height > height) height = painters[i].height;
      if (i < 10 && painters[i].width > digitWidth) digitWidth = painters[i].width;
    }
    colonWidth = painters[colon].width;
    dotWidth = painters[dot].width;
    baseline = painters[0].computeDistanceToActualBaseline(TextBaseline.alphabetic);
  }

  static const int colon = 10;
  static const int dot = 11;

  final List<TextPainter> painters = [];
  double digitWidth = 0;
  double colonWidth = 0;
  double dotWidth = 0;
  double height = 0;
  double baseline = 0;

  void paint(Canvas canvas, int index, double x, double y, double slotWidth) {
    final p = painters[index];
    p.paint(canvas, Offset(x + (slotWidth - p.width) / 2, y));
  }

  void dispose() {
    for (final p in painters) {
      p.dispose();
    }
  }
}

const int _slots = 6; // H1 H2 M1 M2 S1 S2

List<int> _digitsOf(Duration d, {required bool countdown}) {
  final ms = d.isNegative ? 0 : d.inMilliseconds;
  final total = countdown ? (ms + 999) ~/ 1000 : ms ~/ 1000;
  final h = (total ~/ 3600) % 100;
  final m = (total ~/ 60) % 60;
  final s = total % 60;
  return [h ~/ 10, h % 10, m ~/ 10, m % 10, s ~/ 10, s % 10];
}

Duration _durationOf(List<int> d) => Duration(hours: d[0] * 10 + d[1], minutes: d[2] * 10 + d[3], seconds: d[4] * 10 + d[5]);

int _maxDigit(int slot) => (slot == 2 || slot == 4) ? 5 : 9;

class RenderSlidingTime extends RenderBox {
  RenderSlidingTime({required this._elapsed, required this._countdown, required this._textStyle, required this._duration, this.onPicked}) {
    _rebuildGlyphs();
    _sync(animate: false);
  }

  Duration _elapsed;
  set elapsed(Duration value) {
    if (value == _elapsed) return;
    final dir = value < _elapsed ? -1 : 1;
    _elapsed = value;
    final changed = _sync(dir: dir);
    if (changed) _updateTicker();
    if (changed || _showMs) markNeedsPaint();
  }

  bool _countdown;
  set countdown(bool value) {
    if (_countdown == value) return;
    _countdown = value;
    _sync(animate: false);
    markNeedsLayout();
    markNeedsPaint();
  }

  TextStyle _textStyle;
  set textStyle(TextStyle value) {
    if (_textStyle == value) return;
    _textStyle = value;
    _rebuildGlyphs();
    markNeedsLayout();
  }

  Duration _duration;
  set duration(Duration value) => _duration = value;

  ValueChanged<Duration>? onPicked;

  bool get _showMs => !_countdown;
  bool get _pickerActive => onPicked != null;

  final List<int> _current = List<int>.filled(_slots, 0);
  final List<int> _previous = List<int>.filled(_slots, 0);
  final List<double> _progress = List<double>.filled(_slots, 1.0);
  final List<int> _direction = List<int>.filled(_slots, 1);
  int _ms = 0;

  bool _sync({int dir = 1, bool animate = true}) {
    final next = _digitsOf(_elapsed, countdown: _countdown);
    var changed = false;
    for (var i = 0; i < _slots; i++) {
      if (next[i] == _current[i]) continue;
      if (animate) {
        _previous[i] = _current[i];
        _direction[i] = dir;
        _progress[i] = 0.0;
      } else {
        _previous[i] = next[i];
        _progress[i] = 1.0;
      }
      _current[i] = next[i];
      changed = true;
    }
    _ms = (_countdown || _elapsed.isNegative) ? 0 : _elapsed.inMilliseconds % 1000;
    return changed;
  }

  bool get _isAnimating => _progress.any((p) => p < 1.0);

  late _GlyphSet _big;
  late _GlyphSet _small;
  bool _glyphsReady = false;

  void _rebuildGlyphs() {
    if (_glyphsReady) {
      _big.dispose();
      _small.dispose();
    }
    _big = _GlyphSet(_textStyle);
    _small = _GlyphSet(_textStyle.copyWith(fontSize: (_textStyle.fontSize ?? 14) / 2));
    _glyphsReady = true;
  }

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _ticker = Ticker(_onTick, debugLabel: 'SlidingTime');
    _updateTicker();
  }

  @override
  void detach() {
    _ticker?.dispose();
    _ticker = null;
    super.detach();
  }

  void _updateTicker() {
    final t = _ticker;
    if (t == null) return;
    if (_isAnimating && !t.isActive) {
      _lastTick = Duration.zero;
      t.start();
    } else if (!_isAnimating && t.isActive) {
      t.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = elapsed - _lastTick;
    _lastTick = elapsed;
    final step = _duration.inMicroseconds <= 0 ? 1.0 : dt.inMicroseconds / _duration.inMicroseconds;
    for (var i = 0; i < _slots; i++) {
      if (_progress[i] >= 1.0) continue;
      _progress[i] = (_progress[i] + step).clamp(0.0, 1.0);
    }
    markNeedsPaint();
    _updateTicker();
  }

  late final VerticalDragGestureRecognizer _drag = VerticalDragGestureRecognizer(debugOwner: this)
    ..onStart = _onDragStart
    ..onUpdate = _onDragUpdate;

  int _dragSlot = 0;
  double _dragAccum = 0;

  @override
  bool hitTestSelf(Offset position) => _pickerActive;

  @override
  bool get isRepaintBoundary => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent && _pickerActive) {
      _dragSlot = _slotAt(entry.localPosition.dx);
      _drag.addPointer(event);
    }
  }

  void _onDragStart(DragStartDetails d) => _dragAccum = 0;

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_pickerActive) return;
    final step = _big.height * 1.5;
    _dragAccum += d.delta.dy;
    while (_dragAccum >= step) {
      _dragAccum -= step;
      _stepDigit(_dragSlot, -1);
    }
    while (_dragAccum <= -step) {
      _dragAccum += step;
      _stepDigit(_dragSlot, 1);
    }
  }

  void _stepDigit(int slot, int delta) {
    final count = _maxDigit(slot) + 1;
    _previous[slot] = _current[slot];
    _current[slot] = (_current[slot] + delta) % count;
    _direction[slot] = delta;
    _progress[slot] = 0.0;
    final picked = _durationOf(_current);
    _elapsed = picked;
    markNeedsPaint();
    _updateTicker();
    onPicked?.call(picked);
  }

  double _slotX(int i) => i * _big.digitWidth + (i ~/ 2) * _big.colonWidth;

  int _slotAt(double dx) {
    for (var i = 0; i < _slots; i++) {
      if (dx <= _slotX(i) + _big.digitWidth) return i;
    }
    return _slots - 1;
  }

  Size _contentSize() {
    var w = _slots * _big.digitWidth + 2 * _big.colonWidth;
    if (_showMs) w += _small.dotWidth + 3 * _small.digitWidth;
    return Size(w, _big.height);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(_contentSize());

  @override
  void performLayout() {
    size = constraints.constrain(_contentSize());
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, _paintContent);
  }

  void _paintContent(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final dw = _big.digitWidth;
    final h = _big.height;

    _big.paint(canvas, _GlyphSet.colon, offset.dx + _slotX(2) - _big.colonWidth, offset.dy, _big.colonWidth);
    _big.paint(canvas, _GlyphSet.colon, offset.dx + _slotX(4) - _big.colonWidth, offset.dy, _big.colonWidth);

    for (var i = 0; i < _slots; i++) {
      final x = offset.dx + _slotX(i);
      final p = _progress[i];
      if (p >= 1.0) {
        _big.paint(canvas, _current[i], x, offset.dy, dw);
      } else {
        final t = Curves.easeOut.transform(p);
        final dir = _direction[i]; // +1: a régi felfelé megy ki, az új alulról jön; -1: fordítva
        _big.paint(canvas, _previous[i], x, offset.dy - dir * t * h, dw);
        _big.paint(canvas, _current[i], x, offset.dy + dir * (1 - t) * h, dw);
      }
    }

    if (_showMs) {
      var x = offset.dx + _slotX(_slots - 1) + dw;
      final y = offset.dy + _big.baseline - _small.baseline;
      _small.paint(canvas, _GlyphSet.dot, x, y, _small.dotWidth);
      x += _small.dotWidth;
      for (final d in [_ms ~/ 100, (_ms ~/ 10) % 10, _ms % 10]) {
        _small.paint(canvas, d, x, y, _small.digitWidth);
        x += _small.digitWidth;
      }
    }
  }

  @override
  void dispose() {
    _drag.dispose();
    _big.dispose();
    _small.dispose();
    super.dispose();
  }
}
