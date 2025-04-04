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

    return RepaintBoundary(
      child: Stack(children: [
        CanvasInputHandler(
          child: Stack(
            children: [
              ...context.read<DrawingContext>().canvas.layers.values.toList().map((layer) {
                return Stack(
                  children: [
                  // Use ValueListenableBuilder to rebuild layers when repaintNotifier changes
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
                                size: Size.infinite,
                                painter: LazyPainter(layer.elements.values.toList(), context.read<DrawingContext>().repaintNotifier)
                              )
                            )
                          );
                        }).toList(),
                      );
                    },
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                    child: CustomPaint(
                      isComplex: true,
                      size: Size.infinite,
                      painter: ActivePainter(
                          context.watch<DrawingContext>().points,
                          context.read<DrawingContext>().getPaint())
                          ,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
            );
                
              })
            ],
          ),
        ),
      
          CanvasOverlay()
      ]),
    );
  }
}