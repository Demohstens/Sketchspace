import 'package:sketchspace/actions/menu_actions.dart';
import 'package:sketchspace/canvas/actions.dart';
import 'package:sketchspace/canvas/drawing_context.dart';
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
        ChangeNotifierProvider(create: (_) => Settings()),
        ChangeNotifierProvider(create: (_) => DrawingContext()),
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
      themeMode: context.watch<Settings>().darkModeEnabled
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
