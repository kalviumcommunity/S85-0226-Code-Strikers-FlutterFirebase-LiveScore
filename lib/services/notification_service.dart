import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// BACKGROUND HANDLER (must be top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.notification?.title}");
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {

    /// REQUEST PERMISSION
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    /// GET TOKEN
    String? token = await _messaging.getToken();
    print("FCM TOKEN: $token");

    /// FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message: ${message.notification?.title}");
    });

    /// BACKGROUND CLICK
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Opened from notification");
    });

    /// TERMINATED STATE
    RemoteMessage? initialMessage =
    await _messaging.getInitialMessage();

    if (initialMessage != null) {
      print("Opened from terminated state");
    }

    /// BACKGROUND HANDLER
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);
  }
}