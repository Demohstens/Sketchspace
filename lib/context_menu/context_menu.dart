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
  Widget? _ContextMenu;

  void _onLongPress(details) {
    setState(() {
      _ContextMenu = RadialContextMenu(details.localPosition);
    });
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
                onLongPressStart: (details) {
                  _onLongPress(details);
                },
                onTap: () {
                  setState(() {
                    _ContextMenu = null;
                  });
                },
                child: _ContextMenu,
              )))
    ]);
  }
}

class RadialContextMenu extends StatefulWidget {
  final Offset position;
  const RadialContextMenu(this.position, {super.key});

  @override
  State<RadialContextMenu> createState() => _RadialContextMenuState();
}

class _RadialContextMenuState extends State<RadialContextMenu> {
  bool _isSelected = false;

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
                Draggable<bool>(
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
