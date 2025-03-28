
import 'package:flutter/material.dart';

/// This widget handles selection of elements in the canvas. It will show a 
/// selection box around the selected elements. It will also show a menu with
/// options for editing the selected elements. 
class CamvasOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Camvas Overlay"),
      ),
    );
  }
}

class StrokeOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Stroke Overlay"),
      ),
    );
  } 
}