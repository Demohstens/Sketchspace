import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:sketchspace/canvas/canvas_mobile_ui.dart';
import 'package:sketchspace/canvas/canvas_viewport.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/components/sketch_drawer.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/canvas/canvas_desktop_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/providers/settings.dart';

class CanvasPage extends StatelessWidget {
  final _focusNode = FocusNode();
  
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // context.read<Worldspace>().loadFile([]);
    return  Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              context.read<DrawingContext>().saveFile(context);
            },
          ),
        ],
        title: Text(context.watch<DrawingContext>().activeLayer.name),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: (){}),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      drawer: SketchDrawer(),
      body: PieCanvas(child:  
      
      Stack(
              children: [
                Positioned.fill(
                    child: CustomPaint(
                      painter: BackGroundPainter(size: Size(context.width, context.height)),
                    )
                  ),
                Positioned.fill(
                  child: CanvasViewport(),
                ),
                Visibility(
                  visible: true, // context.watch<DrawingContext>().ui_enabled,
                  child: context.watch<Settings>().useMobile == true
                      ? CanvasUIMobile()
                      : CanvasUIDesktop(),
                ),
              ],
    )));
  }
}
