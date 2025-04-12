import 'package:awesome_extensions/awesome_extensions_flutter.dart';
import 'package:flutter/material.dart';

import 'package:sketchspace/brushes/active_painter.dart';
import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/components/canvas_input_handler.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/components/canvas_overlay.dart';

class CanvasViewport extends StatefulWidget {

  const CanvasViewport({super.key});

  
  @override
  State<CanvasViewport> createState() => _CanvasViewportState();

}

class _CanvasViewportState extends State<CanvasViewport> {

  

  @override
  Widget build(BuildContext context) {   
    setState(() {
    });   

    final cWidth = context.watch<DrawingContext>().canvas.width;
    final cHeight = context.watch<DrawingContext>().canvas.height;

    return RepaintBoundary(
      child: Stack(children: [
        CanvasInputHandler(
          canvasWidth: cWidth,
          canvasHeight: cHeight,
          child: Stack(
            children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: context.read<DrawingContext>().repaintNotifier,
                    builder: (context, value, child) {
                      return Stack(
                        children: context.read<DrawingContext>().canvas.layers.values.toList().map((layer) {
                          if (layer.visible == false) {
                            return Container();
                          }
                          return Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                willChange: false,
                                isComplex: true,
                                size: Size(context.watch<DrawingContext>().canvas.width, context.watch<DrawingContext>().canvas.height),
                                painter: LazyPainter(layer.elements.values.toList(), context.read<DrawingContext>().repaintNotifier)
                              )
                            )
                          );
                        }).toList(),
                      );
                    },
                  ),
                  CustomPaint(
                    isComplex: true,
                    size: Size(context.watch<DrawingContext>().canvas.width, context.watch<DrawingContext>().canvas.height),
                    painter: ActivePainter(
                        context.watch<DrawingContext>().points,
                        context.read<DrawingContext>().getPaint())
                  ),
                ],
          ),
        ),
      
          CanvasOverlay()
      ]),
    );
  }
}

class BackGroundPainter extends CustomPainter {
  final Size size;

  BackGroundPainter({required this.size});
  
  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, paint);
  }
  
  @override
  bool shouldRepaint(covariant BackGroundPainter oldDelegate) {
    return false;
  } 
}