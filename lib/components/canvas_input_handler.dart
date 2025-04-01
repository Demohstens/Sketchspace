import 'package:flutter/material.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/components/canvas_overlay.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({Key? key}) : super(key: key);
  @override
  State<CanvasView> createState() => _CanvasViewState();
}


class _CanvasViewState extends State<CanvasView> {
  final TransformController _transformController = TransformController();

  Offset scaleStart = Offset.zero;
  Offset scaleEnd = Offset.zero;
  double scaleFactor = 1.0; // Add this line to store the scale factor
  double rotation = 0.0; // Add this line to store the rotation angle

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canvas Test')),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.red,
        child: Stack(
        children: [
          // Move the ValueListenableBuilder first in the stack
          ValueListenableBuilder<Matrix4>(
            valueListenable: _transformController,
            builder: (context, matrix, child) {
              return Transform(
                transform: matrix,
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.blue,
                ),
              );
            },
          ),
          // Put the GestureDetector after the Transform
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent, // Add this
              onTap: () {
                print('Tapped');
                _transformController.resetTransformations(); // Reset the transformation
              },
              onScaleStart: (details) {
                print('Scale Start');
                scaleStart = details.focalPoint;
              },
              onScaleUpdate: (details) {
                print('Scale Start ${details.scale}');
                _transformController.zoomRelative(details.scale); // Update the scale 
              },
              child: Container(
                color: Colors.transparent, // Change to transparent
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
