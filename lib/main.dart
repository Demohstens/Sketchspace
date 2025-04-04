import 'package:sketchspace/actions/menu_actions.dart';
import 'package:sketchspace/canvas/actions.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:sketchspace/pages/homepage.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:sketchspace/providers/sketch_canvas.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SketchCanvas>(create: (_) => SketchCanvas()),
        ChangeNotifierProvider(create: (_) => Settings()),
        ChangeNotifierProvider(create: (_) => TransformController()),
        ChangeNotifierProxyProvider<SketchCanvas, DrawingContext>(
      create: (_) => DrawingContext(),
      update: (_, canvasContext, drawingContext) =>
          drawingContext!..updateCanvasContext(canvasContext),
    ),
      ],
      child: const Sketchspace(),
    ),
  );
}

class Sketchspace extends StatelessWidget {
  const Sketchspace({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sketchspace',
      theme: ThemeData(
          brightness: Brightness.dark,
          pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                // Set the predictive back transitions for Android.
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              })),
      darkTheme: ThemeData.dark(),
      themeMode: context.watch<Settings>().useDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      home: Actions(actions: 
      {
        OpenMenuIntent: OpenMenuAction(),
        ResetIntent: ResetAction(context.read<DrawingContext>()),
      }, 
      child: HomePage(),)
    );
  }
}
