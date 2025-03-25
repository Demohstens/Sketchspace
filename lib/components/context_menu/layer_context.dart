
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LayerContextMenu extends StatelessWidget {
  final PositionedContextController controller;
  final Widget child;
  const LayerContextMenu(this.controller, this.child, {Key? key} ) : super(key: key);

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
                TextButton(onPressed: () {
                  controller.hide();
                }, child: const Text("Delete")),
                TextButton(onPressed: () {
                  controller.hide();
                }, child: const Text("Merge")),
                TextButton(onPressed: () {
                  controller.hide();
                }, child: const Text("Duplicate")),
                TextButton(onPressed: () {
                  controller.hide();
                }, child: const Text("Move Up")), 
                TextButton(onPressed: () {
                  controller.hide();
                }, child: const Text("Move Down")),
              ],
            ),
          
        ));
        },
      child: child,
      );
  }

}

class PositionedContextController extends OverlayPortalController {
  Offset position = const Offset(0, 0);
  
  void setPosition(Offset position) {
    this.position = position;
  }

} 