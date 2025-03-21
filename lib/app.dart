import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme(),
      home: Scaffold(
        appBar: AppBar(title: Text('Greatly User App')),
        body: Center(child: Text('Hello, world!')),
      ),
    );
  }
}