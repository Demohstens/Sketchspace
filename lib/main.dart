import 'package:flutter/material.dart';
import 'package:flutter_application/classes/DrawingContext.dart';
import 'package:flutter_application/classes/Settings.dart';
import 'package:flutter_application/pages/homepage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Drawingcontext()),
        ChangeNotifierProvider(create: (_) => Settings()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
