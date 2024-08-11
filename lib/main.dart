import 'package:demo_space/classes/demo_debug.dart';
import 'package:demo_space/classes/drawing_context.dart';
import 'package:demo_space/classes/settings.dart';
import 'package:demo_space/pages/homepage.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrawingContext()),
        ChangeNotifierProvider(create: (_) => Settings()),
        ChangeNotifierProvider(create: (_) => DemoDebug()),
        ChangeNotifierProvider(create: (_) => DrawFileProvider()),
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
          useMaterial3: true,
          primarySwatch: Colors.blue,
          pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                // Set the predictive back transitions for Android.
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              })),
      home: HomePage(),
    );
  }
}
