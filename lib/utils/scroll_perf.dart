import 'dart:async';

import 'package:flutter/widgets.dart';

/// Señal global de "el usuario está deslizando".
///
/// Mientras [active] es true, la UI evita trabajo caro (desenfoque de vidrio,
/// aparecer carátulas nuevas) para que el scroll no se corte. Al soltar el
/// dedo se retoma el acabado visual.
class ScrollPerf {
  ScrollPerf._();

  static final ValueNotifier<bool> active = ValueNotifier(false);

  static const _idleAfter = Duration(milliseconds: 90);
  static Timer? _idle;
  static final List<VoidCallback> _deferred = [];

  static bool handle(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      _armIdle();
      return false;
    }
    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification) {
      _setActive(true);
      _idle?.cancel();
      _armIdle();
    }
    return false;
  }

  /// Ejecuta [callback] ya, o lo guarda para cuando el scroll se detenga.
  static void runWhenIdle(VoidCallback callback) {
    if (!active.value) {
      callback();
      return;
    }
    _deferred.add(callback);
  }

  static void _armIdle() {
    _idle?.cancel();
    _idle = Timer(_idleAfter, _goIdle);
  }

  static void _setActive(bool value) {
    if (active.value != value) active.value = value;
  }

  static void _goIdle() {
    _setActive(false);
    if (_deferred.isEmpty) return;
    final pending = List<VoidCallback>.of(_deferred);
    _deferred.clear();
    _flush(pending, 0);
  }

  static void _flush(List<VoidCallback> pending, int index) {
    const batch = 6;
    final end = index + batch > pending.length ? pending.length : index + batch;
    for (var i = index; i < end; i++) {
      pending[i]();
    }
    if (end < pending.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _flush(pending, end);
      });
    }
  }
}
