import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sketchspace/components/add_imported.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/tools/brush.dart';
import 'package:sketchspace/tools/mouse.dart';

// possible to use menu anchor instead?
// https://api.flutter.dev/flutter/material/PopupMenuButton-class.html

enum MenuEntry { width }

class BrushMenuMobile extends StatefulWidget {

  const BrushMenuMobile({
    Key? key,
  }) : super(key: key);

  @override
  State<BrushMenuMobile> createState() => BrushMenuMobileState();
}

class BrushMenuMobileState extends State<BrushMenuMobile> {
  final MenuController _widthMenuController = MenuController();
  final MenuController menuController = MenuController();
  @override
  Widget build(BuildContext context) {
    Color secondary = context.watch<Settings>().secondaryColor;
    return Material(
      color: Colors.transparent,
      child: MenuAnchor(
        controller: menuController,
        menuChildren: [
          AddImported(),
          MouseToolButton(),
              BrushToolButton(),
              PopupMenuButton<ColorButton>(
                constraints: BoxConstraints(maxWidth: 50),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(),
                ),
                position: PopupMenuPosition.over,
                initialValue: ColorToColotButton(context.read<DrawingContext>().color),
                onSelected: (ColorButton result) {
                  context
                      .read<DrawingContext>()
                      .changeColor(ColorEnumToColorType(result));
                },
                tooltip: "Change Color",
                itemBuilder: (BuildContext context) => <PopupMenuEntry<ColorButton>>[
                  PopupMenuItem(
                      value: ColorButton.red, child: _colorButton(Colors.red)),
                  PopupMenuItem(
                      value: ColorButton.green, child: _colorButton(Colors.green)),
                  PopupMenuItem(
                      value: ColorButton.blue, child: _colorButton(Colors.blue)),
                ],
                child: CircleAvatar(
                  backgroundColor: context.watch<DrawingContext>().color,
                  radius: 15,
                  child: null,
                
                ),
              ),
              
              MenuAnchor(
                controller: _widthMenuController,
                menuChildren: <Widget>[_widthSlider(context)],
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, // Ensures the entire area is clickable
                  onTap: () {
                    switch (_widthMenuController.isOpen) {
                      case true:
                        _widthMenuController.close();
                        break;
                      case false:
                        _widthMenuController.open();
                        break;
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    child: Icon(
                      Icons.circle,
                      size: context.read<DrawingContext>().strokeWidth,
                      color: secondary,
                    ),
                  ),
                ),
        )
      ],
        child:CircleAvatar( 
          backgroundColor: Colors.transparent, 
          child: IconButton(
          tooltip: "Brush Menu",
          color: context.read<Settings>().secondaryColor,
          onPressed: () {
          switch (menuController.isOpen) {
            case true: 
              {
                setState(() {
                  menuController.close();

                });
              }
              break;
            case false:
              {
                setState(() {
                  menuController.open();

                });
              }
              break;
            
          }
        }, icon: menuController.isOpen ? Icon(Icons.close) : Icon(Icons.menu)),
    )));
  }

  Widget _colorButton(Color color) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 15,
      child: null,
    );
  }

  Widget _widthSlider(BuildContext context) {
    return Slider(
      value: context.read<DrawingContext>().strokeWidth,
      min: 1,
      max: 20,
      divisions: 19,
      label: 'Stroke Width: ${context.read<DrawingContext>().strokeWidth}',
      onChanged: (double value) {
        context.read<DrawingContext>().changeWidth(value);
      },
    );
  }
}

enum ColorButton { red, green, blue }

Color ColorEnumToColorType(ColorButton color) {
  switch (color) {
    case ColorButton.red:
      return Colors.red;
    case ColorButton.green:
      return Colors.green;
    case ColorButton.blue:
      return Colors.blue;
  }
}

ColorButton ColorToColotButton(Color color) {
  if (color == Colors.red) {
    return ColorButton.red;
  } else if (color == Colors.green) {
    return ColorButton.green;
  } else if (color == Colors.blue) {
    return ColorButton.blue;
  } else {
    return ColorButton.red;
  }
}


class ColorSelector extends StatelessWidget {
  void Function (Color color) changeColor;
  ColorSelector(this.changeColor);
  
  Widget _colorButton(Color color) {
    return Container(height: 30, width: 30, color: color, child: null);
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<ColorButton>(
        constraints: BoxConstraints(maxWidth: 40),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(),
        ),
        position: PopupMenuPosition.over,
        initialValue: ColorToColotButton(context.read<DrawingContext>().color),
        onSelected: (ColorButton result) {
          changeColor(ColorEnumToColorType(result));
        },
        tooltip: "Change Color",
        itemBuilder: (BuildContext context) => <PopupMenuEntry<ColorButton>>[
          PopupMenuItem(
              value: ColorButton.red, child: _colorButton(Colors.red)),
          PopupMenuItem(
              value: ColorButton.green, child: _colorButton(Colors.green)),
          PopupMenuItem(
              value: ColorButton.blue, child: _colorButton(Colors.blue)),
        ],
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
              color: context.watch<DrawingContext>().color,
              border: Border.all(width: 1, color: context.watch<Settings>().secondaryColor)),
        ),
    ));
  }
}

class WidthSelector extends StatelessWidget {
  final MenuController _menuController = MenuController();

  Widget _widthSlider(BuildContext context) {
    return Slider(
      value: context.read<DrawingContext>().strokeWidth,
      min: 1,
      max: 20,
      divisions: 19,
      label: 'Stroke Width: ${context.read<DrawingContext>().strokeWidth}',
      onChanged: (double value) {
        context.read<DrawingContext>().changeWidth(value);
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
          controller: _menuController,
          menuChildren: <Widget>[_widthSlider(context)],
          child: GestureDetector(
              onTap: () {
                _menuController.open();
              },
              child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: context.watch<Settings>().secondaryColor)),
                  child: Icon(Icons.circle,
                      size: context.read<DrawingContext>().strokeWidth,
                      color: context.watch<Settings>().secondaryColor))));
  }
}