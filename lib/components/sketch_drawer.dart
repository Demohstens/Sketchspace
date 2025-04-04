import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/pages/homepage.dart';
import 'package:sketchspace/pages/settings_page.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';

class SketchDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    bool isVertical = MediaQuery.of(context).size.height > MediaQuery.of(context).size.width; 
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double drawerWidth = isVertical ? width * 0.8 : width * 0.3;

    return Container(
      padding: EdgeInsets.all(25),
      color: context.read<Settings>().background,
      constraints: BoxConstraints.tight(Size(drawerWidth, height)),
      child: ListView(
        children: [
          Title(
            color: Colors.black,
            child: Text("Menu", style: TextStyle(fontSize: 24),),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("settings"),
            onTap: () {
              Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
        // Brush Men
            }, 
          ),
          
          ListTile(
            leading: Icon(Icons.save),
            title: Text("Save"),
            onTap: () {
              context.read<DrawingContext>().saveFile(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Return home"),
            onTap: () {
                if (context.read<Settings>().autoSave) {
                  context
                      .read<DrawingContext>()
                      .saveFile(context)
                      .then((saveSuccess) {
                    if (context.mounted) {
                      // TODO load files
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                    }
                  });
                } else {
                  context.read<DrawingContext>().resetAll();
                  Navigator.pop(context);
                }
              },
          ),
          // SwitchListTile(
          //   value: context.watch<Settings>().useDarkMode,
          //   title: Text("Toggle dark mode"),
          //   onChanged: (bool value) {
          //     context.read<Settings>().darkMode = value;
          //   },
          // ),
          ListTile(
            leading: IconButton(onPressed: () {
              context.read<Settings>().useMobile = true;
            }, icon: Icon(Icons.android)),
            trailing: IconButton(onPressed: (){
              context.read<Settings>().useMobile = false;
            }, icon: Icon(Icons.desktop_windows)),
          )
        ]
      )
    );
  }
}