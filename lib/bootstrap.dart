import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:greatly_user/core/di/service_locator.dart';
import 'package:greatly_user/app.dart'; // Your main app widget

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize dependencies with proper ordering
  await initDependencies();
  
  // Run the app
  runApp( MyApp());
}