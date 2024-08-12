import 'dart:async';

import 'package:flutter/material.dart';

/// Listener to trigger a repaint of all paths
///
/// Author: Philip Lalonde
class RepaintListener implements Listenable {
  final StreamController<void> _controller = StreamController<void>.broadcast();
  bool _isDisposed = false;
  @override
  void addListener(VoidCallback listener) {
    if (!_isDisposed) {
      _controller.stream.listen((_) => listener());
    } else {
      throw Exception('Cannot add listener after disposal');
    }
  }

  @override
  void removeListener(VoidCallback listener) {}

  void notifyListeners() {
    _controller.add(null);
  }

  void dispose() {
    _isDisposed = true;
    _controller.close();
  }
}
