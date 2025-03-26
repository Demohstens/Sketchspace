
import 'package:flutter/material.dart';

class StrokeContextMenu extends StatelessWidget {
  final PositionedContextController controller;
  final Widget child;
  const StrokeContextMenu(this.controller, this.child, {super.key} );
  
  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: controller,
      overlayChildBuilder: (BuildContext context) {
        return Positioned(
          left: controller.position.dx - 80,
          top: controller.position.dy - 20,
          child: Container(
           
          
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