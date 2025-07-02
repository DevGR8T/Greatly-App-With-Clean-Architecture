import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:io';

import 'package:greatly_user/core/di/service_locator.dart';
import 'package:greatly_user/app.dart';
import 'features/notifications/data/datasources/remote/firebase_notification_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
   
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = 'pk_test_51ROrsVRpZylkLubgzvLmaqw51zPDYjAGDLva86MXeKQOkbTkDhfWuGur1CLxj8GSN8RWPiSD7MQn9ihXhXIkv6DH00tndCOaZS';
  await Stripe.instance.applySettings();
  
  await Firebase.initializeApp();

  
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Request notification permissions explicitly
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  
  print('Notification permission status: ${settings.authorizationStatus}');

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground notification: ${message.notification?.title}');
    NotificationService.showNotificationFromFirebase(message);
  });

  // Handle notification taps when app is terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification opened app: ${message.notification?.title}');
    // Handle navigation based on notification data
  });

  // Check if app was opened from a notification
  RemoteMessage? initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    print('App opened from notification: ${initialMessage.notification?.title}');
    // Handle navigation based on notification data
  }
  
  // FIX: Handle APNS token properly for iOS
  try {
    String? token;
    
    if (Platform.isIOS) {
      // Wait for APNS token on iOS
      String? apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        print('APNS Token: $apnsToken');
        // Now get FCM token after APNS token is available
        token = await messaging.getToken();
      } else {
        print('APNS token not available, retrying...');
        // Retry mechanism for APNS token
        await Future.delayed(Duration(seconds: 2));
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          token = await messaging.getToken();
        } else {
          print('APNS token still not available, FCM may not work properly');
        }
      }
    } else {
      // For Android, directly get FCM token
      token = await messaging.getToken();
    }
    
    if (token != null) {
      print('FCM Token: $token');
    } else {
      print('Failed to get FCM token');
    }
  } catch (e) {
    print('Error getting messaging tokens: $e');
  }

  await initDependencies();
  runApp(MyApp());
}