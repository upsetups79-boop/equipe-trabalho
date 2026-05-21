import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationService._init();

  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get the token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required String token,
  }) async {
    // This would typically be done through a backend server
    // For now, we'll just print the notification
    print('Sending notification to $token: $title - $body');
  }

  Future<void> scheduleDayOffReminder({
    required String employeeName,
    required DateTime dayOff,
  }) async {
    // Schedule a notification for the day before the day off
    final reminderDate = dayOff.subtract(const Duration(days: 1));
    print('Scheduling reminder for $employeeName on $reminderDate');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
