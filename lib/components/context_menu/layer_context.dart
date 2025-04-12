import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/components/context_menu/stroke_context.dart';
import 'package:sketchspace/providers/drawing_context.dart';

class LayerContextMenu extends StatelessWidget {
  final PositionedContextController controller;
  final Widget child;
  final String layerId;
  const LayerContextMenu(this.controller, this.child, this.layerId, {super.key});
  final style =  const TextStyle(
    color: Colors.white,
    fontSize: 16,
  );
  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: controller,
      overlayChildBuilder: (BuildContext context) {
        return Positioned(
          left: controller.position.dx - 80,
          top: controller.position.dy - 20,
          child: Container(
            color: Colors.grey,
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    print("Deleting Layer");
                    context.read<DrawingContext>().removeLayer(
                      layerId,
                    );
                  },
                  child:  Text("Delete", style: style,),
                ),
                TextButton(
                  onPressed: () {
                    controller.hide();
                  },
                  child: Text("Merge", style: style),
                ),
              ],
            ),
          ),
        );
      },
      child: child,
    );
  }
}
