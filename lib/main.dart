import 'package:sizer/sizer.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:sketchspace/pages/homepage.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Settings()),
        ChangeNotifierProvider(create: (_) => TransformController()),
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
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'Sketchspace',
          theme: ThemeData(
            brightness: Brightness.dark,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                // Set the predictive back transitions for Android.
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData.dark(),
          themeMode:
              context.watch<Settings>().useDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
          home: HomePage(),
        );
      },
    );
  }
}
