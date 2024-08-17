import 'package:flutter/material.dart';
import 'package:sketchspace/context_menu/manual_draggable.dart' as sketchspace;

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

class RadialContextMenu extends StatefulWidget {
  final Offset position;
  RadialContextMenu(this.position, {super.key});
  final sketchspace.DragNotifier dragNotifier = sketchspace.DragNotifier();

  @override
  State<RadialContextMenu> createState() => _RadialContextMenuState();
}

class _RadialContextMenuState extends State<RadialContextMenu> {
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    widget.dragNotifier.addListener(_handleDragStateChange);
  }

  void _handleDragStateChange() {
    if (widget.dragNotifier.canDrag) {
      widget.dragNotifier.initiateDrag(widget.position);

      widget.dragNotifier.setDragibility(false); // Reset the flag
    }
    // ... (handle other state changes if needed)
  }

  @override
  Widget build(BuildContext context) {
    print('Building RadialContextMenu');
    return Stack(children: [
      Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                sketchspace.ManualDraggable<bool>(
                  dragNotifier: widget.dragNotifier,
                  onDragStarted: () {},
                  // Data is the value this Draggable stores.
                  data: true,
                  feedback: Container(
                    color: Colors.deepOrange,
                    height: 100,
                    width: 100,
                    child: const Icon(Icons.directions_run),
                  ),
                  childWhenDragging: Container(
                    height: 100.0,
                    width: 100.0,
                    color: const Color.fromARGB(156, 174, 28, 77),
                  ),
                  child: Container(
                    height: 100.0,
                    width: 100.0,
                    color: const Color.fromARGB(155, 96, 255, 64),
                  ),
                ),
                DragTarget<bool>(
                  builder: (
                    BuildContext context,
                    List<dynamic> accepted,
                    List<dynamic> rejected,
                  ) {
                    return Container(
                      height: 100.0,
                      width: 100.0,
                      color: Colors.cyan,
                      child: Center(
                        child: Text('Value is updated to: $_isSelected'),
                      ),
                    );
                  },
                  onAcceptWithDetails: (DragTargetDetails<bool> details) {
                    setState(() {
                      _isSelected = details.data;
                    });
                  },
                ),
              ]))
    ]);
  }
}
