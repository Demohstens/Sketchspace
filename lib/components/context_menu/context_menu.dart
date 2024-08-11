import 'package:flutter/material.dart';
import 'dart:math';

class CircularContextMenu extends StatefulWidget {
  @override
  _CircularContextMenuState createState() => _CircularContextMenuState();
}

class _CircularContextMenuState extends State<CircularContextMenu> {
  Offset _tapPosition = Offset.zero;
  bool _isMenuVisible = false;

  void _showContextMenu(BuildContext context, Offset position) {
    setState(() {
      _tapPosition = position;
      _isMenuVisible = true;
    });
  }

  void _hideContextMenu() {
    setState(() {
      _isMenuVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _showContextMenu(context, details.localPosition),
      onTap: _hideContextMenu,
      child: Stack(
        children: [
          // Your main content here
          Positioned(
            left: _tapPosition.dx,
            top: _tapPosition.dy,
            child: _isMenuVisible ? _buildContextMenu() : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenu() {
    final List<Widget> buttons = [];
    final double radius = 50.0;
    final int itemCount = 6; // Number of buttons

    for (int i = 0; i < itemCount; i++) {
      final double angle = (2 * pi / itemCount) * i;
      final double x = radius * cos(angle);
      final double y = radius * sin(angle);

      buttons.add(
        Positioned(
          left: x,
          top: y,
          child: IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              // Handle button press
              _hideContextMenu();
            },
          ),
        ),
      );
    }

    return Stack(children: buttons);
  }
}
