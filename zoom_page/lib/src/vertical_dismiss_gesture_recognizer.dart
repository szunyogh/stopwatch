import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// Distance (in logical pixels) the primary pointer must travel downward
/// before the gesture is accepted as a dismiss drag.
const double _kDismissDragThreshold = 15.0;

/// Recognizes a vertical drag-to-dismiss gesture, only when [canStart]
/// returns true (e.g. once a page transition has fully completed).
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
    if (event.pointer != _primaryPointer) {
      if (event is PointerUpEvent || event is PointerCancelEvent) {
        stopTrackingPointer(event.pointer);
      }

      return;
    }

    _velocityTracker?.addPosition(event.timeStamp, event.position);

    if (event is PointerMoveEvent) {
      final deltaY = event.position.dy - _initialY;

      if (!_isAccepted && deltaY > _kDismissDragThreshold) {
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
