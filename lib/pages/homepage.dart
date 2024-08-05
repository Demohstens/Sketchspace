import 'package:flutter/material.dart';
import 'package:flutter_application/pages/canvas.dart';

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

class Windows extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(crossAxisCount: 2, children: [
      ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CanvasPage()),
            );
          },
          child: Text('Canvas')),
    ]);
  }
}
