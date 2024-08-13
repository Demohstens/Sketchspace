// import 'dart:async';
// import 'package:flutter/material.dart';

// /// Listener to trigger a repaint of all paths
// ///
// /// Author: Philip Lalonde
// class RepaintListener implements Listenable {
//   final StreamController<void> _controller = StreamController<void>.broadcast();
//   bool _isDisposed = false;
//   bool get isDisposed => _isDisposed;

//   @override
//   void addListener(VoidCallback listener) {
//     if (_isDisposed) {
//       throw Exception('Cannot add listener after disposal');
//     }
//     _controller.stream.listen((_) => listener());
//   }

//   @override
//   void removeListener(VoidCallback listener) {
//     // No-op: StreamController does not support removing listeners
//   }

//   void notifyListeners() {
//     if (_isDisposed) {
//       throw Exception('Cannot notify listeners after disposal');
//     }
//     try {
//       _controller.add(null);
//     } catch (e) {
//       print('Error notifying listeners: $e');
//     }
//   }

//   void dispose() {
//     if (_isDisposed) {
//       return;
//     }
//     _isDisposed = true;
//     _controller.close();
//   }
// }
