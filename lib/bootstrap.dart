import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:greatly_user/app.dart';
import 'package:greatly_user/firebase_options.dart';
import 'core/di/service_locator.dart';
// In bootstrap.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    print('Firebase initialized successfully');
    configureDependencies();
    runApp( MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}
