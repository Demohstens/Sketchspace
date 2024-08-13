import 'package:sketchspace/canvas/data/worldspace.dart';
import 'package:sketchspace/classes/demo_debug.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:sketchspace/canvas/scale.dart';
import 'package:sketchspace/classes/settings.dart';
import 'package:sketchspace/pages/homepage.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScaleProvier()),
        ChangeNotifierProvider(create: (_) => Settings()),
        ChangeNotifierProvider(create: (_) => CanvasSpace(Matrix4.identity())),
        ChangeNotifierProxyProvider<CanvasSpace, Worldspace>(
            create: (context) => Worldspace(context.read<CanvasSpace>()),
            update: (context, canvasSpace, worldSpace) =>
                worldSpace ?? Worldspace(canvasSpace)),
        ChangeNotifierProvider(create: (_) => DrawFileProvider()),
        ChangeNotifierProxyProvider<Worldspace, DrawingContext>(
            create: (context) => DrawingContext(context.read<Worldspace>()),
            update: (context, canvasSpace, worldSpace) =>
                worldSpace ?? DrawingContext(canvasSpace)),
      ],
      child: Sketchspace(),
    ),
  );
}

class Sketchspace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sketchspace',
      theme: ThemeData(
          brightness: Brightness.light,
          pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                // Set the predictive back transitions for Android.
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              })),
      darkTheme: ThemeData.dark(),
      themeMode: context.watch<Settings>().darkModeEnabled
          ? ThemeMode.dark
          : ThemeMode.light,
      home: HomePage(),
    );
  }
}
