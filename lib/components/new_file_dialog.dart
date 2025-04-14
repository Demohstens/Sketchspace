import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/sketch_canvas.dart';
import 'package:sketchspace/pages/canvas.dart';

class NewFileDialog extends StatelessWidget {
  String? name;
  NewFileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController widthController = TextEditingController(text: (MediaQuery.of(context).size.width.round() * 2).toString()); 
    final TextEditingController heightController = TextEditingController(text: (MediaQuery.of(context).size.height.round() * 2).toString()); 
    return AlertDialog(
      title: Text("New File"), 
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Name",
            ),
            onChanged: (value) {
              name = value;
            },
          ), 
          DimensionInput(label: "Height", controller: heightController),
          DimensionInput(label: "Width", controller: widthController),
          Row(children: [
              Expanded(child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              )),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  double width = double.tryParse(widthController.text) ?? 0;
                  double height = double.tryParse(heightController.text) ?? 0;
                  SketchCanvas canvas = SketchCanvas(
                    fileName: name,
                    width: width,
                    height: height
                  );
                  context.read<DrawingContext>().pushCanvas(canvas);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CanvasPage()),
                  );
                
                },
                child: Text("Create"), 
              ))
            
          ],)
        ] 
      )
    );
  }
}

class NewFileButton extends StatelessWidget {
  final String tag;
  const NewFileButton({super.key, this.tag = "newfile"});
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: FloatingActionButton.extended(
          heroTag: tag,
          tooltip: "Create a new file",
          onPressed: () {
            showDialog(context: context, builder: (context) => NewFileDialog());
          },
          label: const Text("New File"),
          icon: FaIcon(FontAwesomeIcons.plus),
        ));
  }
}


class DimensionInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const DimensionInput({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
            controller: controller,
            maxLength: 5,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
            ],
            decoration: InputDecoration(
              labelText: label,
            ),
            onChanged: (value) => {
              
            },
          );
  }}