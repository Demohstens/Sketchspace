import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/providers/drawing_context.dart';

class AddImported extends StatefulWidget {
  AddImported({super.key});
  final MenuController controller = MenuController();
  @override
  State<AddImported> createState() => _AddImportedState();
}

class _AddImportedState extends State<AddImported> {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: widget.controller,
      menuChildren: [
        MenuItemButton(
          child: Icon(Icons.image),
          onPressed: () {
            ImagePicker().pickImage(source: ImageSource.gallery).then((XFile? f) {
              if (f!= null) {
                if (context.mounted) {
                context.read<DrawingContext>().addImported(f);
                }
              }
            });
            widget.controller.close();
          }, 
        )
      ],
      child: IconButton(onPressed: () {
        widget.controller.isOpen ? widget.controller.close() : widget.controller.open();
      }, icon: Icon(Icons.add)));
  } 
}