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
    return IconButton(
      icon: Icon(Icons.image),
      onPressed: () async {
        importImage(context.read<DrawingContext>(), context);
      }
    );
  }
}

void importImage(DrawingContext drawingContext, BuildContext context) async {
  XFile? f; // Declare f outside the try block
  try {
    // 4. Perform the asynchronous operation (the 'await')
    print("Launching image picker...");
    f = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("Image picker returned: ${f?.path ?? 'null'}");

    // 5. Use the stored 'drawingContext' reference AFTER the await
    if (f != null) {
      print("Image selected, calling drawingContext.addImported...");
      // Call the method on the object reference we stored earlier.
      // We are NOT using the original 'context' variable here for this call.
      drawingContext.addImported(f); // Await if addImported is async
      print("addImported completed.");
      // Show feedback using the stored scaffoldMessenger
    } else {
      print("Image selection cancelled.");
      // Optionally show feedback that it was cancelled
      // scaffoldMessenger.showSnackBar(
      //   SnackBar(content: Text('Image selection cancelled.')),
      // );
    }
  } catch (e) {
    // Handle potential errors from ImagePicker or addImported
    print("Error during image pick/add: $e");
    // Show error feedback using the stored scaffoldMessenger
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
