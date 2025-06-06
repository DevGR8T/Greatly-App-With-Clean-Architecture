import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:greatly_user/core/di/service_locator.dart';
import 'package:greatly_user/app.dart';


void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

   // Set Stripe publishable key
  Stripe.publishableKey = 'pk_test_51ROrsVRpZylkLubgzvLmaqw51zPDYjAGDLva86MXeKQOkbTkDhfWuGur1CLxj8GSN8RWPiSD7MQn9ihXhXIkv6DH00tndCOaZS';
  await Stripe.instance.applySettings();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize dependencies with proper ordering
  await initDependencies();

  // Run the app
  runApp( MyApp());
}