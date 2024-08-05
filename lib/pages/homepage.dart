import 'package:flutter/material.dart';
import 'package:flutter_application/pages/canvas.dart';

// Menu for selecting pages (Canvas, etc.)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Windows(),
    );
  }
}

// A display of all available Pages/windows. Hardcoded for now.
class Windows extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(crossAxisCount: 2, children: [
      ElevatedButton(
          onPressed: () {
            // Adds the page to the Nav. Stack.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CanvasPage()),
            );
          },
          child: Text('Canvas')),
    ]);
  }
}
