import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sketchspace/components/layer_list.dart';

class CollapsedLayerButton extends StatefulWidget {
  final Widget? child;
  final double iconSize;
  final Color iconColor;
  const CollapsedLayerButton({super.key, this.child, this.iconSize = 20, this.iconColor = Colors.black});

  @override
  State<CollapsedLayerButton> createState() => _CollapsedLayerButtonState();
}

class _CollapsedLayerButtonState extends State<CollapsedLayerButton> {
  final MenuController controller = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateColor.transparent,
      ),
      controller: controller, // Explicitly connect the controller
      menuChildren: [LayerList()],
      builder: (
        BuildContext context,
        MenuController controller,
        Widget? child,
      ) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(Icons.layers, size: widget.iconSize, color: widget.iconColor),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
