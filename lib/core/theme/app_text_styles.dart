import 'package:flutter/material.dart';

TextTheme appTextTheme() {
  return TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
  );
}