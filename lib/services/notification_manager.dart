import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  // Queue for pending notifications when APNS token is not ready
  final List<Map<String, dynamic>> _pendingNotifications = [];
  bool _isInitialized = false;
  String? _cachedFCMToken;

  /// Initialize notification manager and ensure APNS token is ready
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Platform.isIOS) {
        await _ensureAPNSTokenReady();
      }

      // Get and cache FCM token
      _cachedFCMToken = await FirebaseMessaging.instance.getToken();
      print(
          '✅ NotificationManager initialized with FCM token: ${_cachedFCMToken?.substring(0, 20)}...');

      _isInitialized = true;

      // Process any pending notifications
      await _processPendingNotifications();
    } catch (e) {
    }
  }

  /// Ensure APNS token is ready with aggressive retry
  Future<void> _ensureAPNSTokenReady() async {
    String? apnsToken;
    int maxRetries = 15;
    int retryCount = 0;

    while (apnsToken == null && retryCount < maxRetries) {
      try {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {

          await Future.delayed(Duration(milliseconds: 300 * (retryCount + 1)));
          retryCount++;
        }
      } catch (e) {

        retryCount++;
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    if (apnsToken != null) {

    } else {
      throw Exception('APNS token not available after $maxRetries attempts');
    }
  }

  /// Send order confirmation notification
  Future<void> sendOrderConfirmationNotification(String orderId) async {
    final notificationData = {
      'type': 'order_confirmation',
      'orderId': orderId,
      'title': 'Order Confirmed! 🎉',
      'body': 'Your order #$orderId has been confirmed and is being processed.',
    };

    if (_isInitialized && _cachedFCMToken != null) {
      await _sendNotificationToDevice(_cachedFCMToken!, notificationData);
    } else {
      // Queue notification for later processing

      _pendingNotifications.add(notificationData);

      // Try to initialize in background
      initialize();
    }
  }

  /// Process any pending notifications
  Future<void> _processPendingNotifications() async {
    if (_pendingNotifications.isEmpty || _cachedFCMToken == null) return;

    print(
        '📤 Processing ${_pendingNotifications.length} pending notifications');

    for (final notification in List.from(_pendingNotifications)) {
      try {
        await _sendNotificationToDevice(_cachedFCMToken!, notification);
        _pendingNotifications.remove(notification);
      } catch (e) {

      }
    }
  }

  /// Send notification to device using FCM API
  Future<void> _sendNotificationToDevice(
      String token, Map<String, dynamic> notificationData) async {
    try {
      // Load service account credentials
      final serviceAccountJson =
          await rootBundle.loadString('assets/service-account.json');
      final accountCredentials =
          ServiceAccountCredentials.fromJson(json.decode(serviceAccountJson));

      // Get access token
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(accountCredentials, scopes);

      // Send notification
      final response = await client.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/greatlyshopapp-f0b87/messages:send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': notificationData['title'],
              'body': notificationData['body'],
            },
            'data': {
              'orderId': notificationData['orderId'],
              'type': notificationData['type'],
            },
            // iOS-specific configuration
            'apns': {
              'payload': {
                'aps': {
                  'alert': {
                    'title': notificationData['title'],
                    'body': notificationData['body'],
                  },
                  'badge': 1,
                  'sound': 'default',
                },
              },
            },
            // Android-specific configuration
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'high_importance_channel',
                'default_sound': true,
              },
            },
          },
        }),
      );

      client.close();

      if (response.statusCode == 200) {
        print(
            '✅ Notification sent successfully for order ${notificationData['orderId']}');
      } else {

        throw Exception('FCM API error: ${response.statusCode}');
      }
    } catch (e) {

      rethrow;
    }
  }

  /// Get current initialization status
  bool get isInitialized => _isInitialized;

  /// Get pending notifications count
  int get pendingNotificationsCount => _pendingNotifications.length;
}
