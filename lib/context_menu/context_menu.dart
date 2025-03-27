import 'package:flutter/material.dart';

/// Flutter code sample for [Draggable].

void main() => runApp(const DraggableExampleApp());

class DraggableExampleApp extends StatelessWidget {
  const DraggableExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: const BG(),
      ),
    );
  }
}

class BG extends StatefulWidget {
  const BG({super.key});

  _BGState createState() => _BGState();
}

class _BGState extends State<BG> {
  OverlayEntry? _overlayEntry;
  void _onLongPressStart(LongPressStartDetails details) {
    _showOverlay(details.globalPosition);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    print("Long Press Move Update");
    _updateOverlayPosition(details.globalPosition);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _removeOverlay();
  }

  void _showOverlay(Offset globalPosition) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _buildOverlayContent(globalPosition);
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateOverlayPosition(Offset globalPosition) {
    _overlayEntry?.markNeedsBuild(); // Trigger a rebuild to update position
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlayContent(Offset globalPosition) {
    final RenderBox overlayBox =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final Offset localPosition = overlayBox.globalToLocal(globalPosition);

    return Positioned(
      left: localPosition.dx,
      top: localPosition.dy,
      child: GestureDetector(
        onTap: () {
          // Handle tap on the injected widget
          _removeOverlay();
        },
        child: Container(
          // Your injected widget (e.g., InkWell)
          width: 100,
          height: 100,
          color: Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          left: MediaQuery.of(context).size.width * 0.1,
          top: MediaQuery.of(context).size.height * 0.1,
          child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPressStart: _onLongPressStart,
                onLongPressMoveUpdate: _onLongPressMoveUpdate,
                onLongPressEnd: _onLongPressEnd,
              )))
    ]);
  }
}

Widget _spawnGestureDetector2() {
  return Focus(
      focusNode: FocusNode(),
      canRequestFocus: true,
      autofocus: true,
      child: GestureDetector(
        onTap: () {
          print("Tapped 2");
        },
        onPanUpdate: (details) {
          print("Pan Update 2");
        },
        child: Container(
          width: 100,
          height: 100,
          color: Colors.red,
        ),
      ));
}
