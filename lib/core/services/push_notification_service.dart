import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:dio/dio.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Future<void>.value();
  if (kDebugMode) {
    debugPrint('FCM background message: ${message.messageId}');
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'smartclinic_notifications',
        'SmartClinic Notifications',
        description: 'High priority notifications for SmartClinic',
        importance: Importance.high,
      );

  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _initialized = false;

  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) {
      return;
    }

    _navigatorKey = navigatorKey;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();

    await _localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      ),
      onDidReceiveNotificationResponse: (response) {
        _openNotificationsScreen();
      },
    );

    final androidPlugin = _localNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openNotificationsScreen();
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _openNotificationsScreen();
    }

    await _syncCurrentToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _persistToken(token);
    });

    _initialized = true;
  }

  static Future<void> _syncCurrentToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.trim().isEmpty) {
      return;
    }

    await _persistToken(token);
  }

  static Future<void> _persistToken(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      return;
    }
    await getIt<UserSession>().saveDeviceToken(normalizedToken);
    final userSession = getIt<UserSession>();
    if (userSession.isLoggedIn) {
      try {
        final dio = getIt<Dio>();
        await dio.post(
          '/api/DeviceToken/save-token',
          data: normalizedToken,
          options: Options(contentType: 'application/json'),
        );
        if (kDebugMode) debugPrint('Device token saved on backend');
      } catch (e) {
        if (kDebugMode) debugPrint('Failed to save device token on backend: $e');
      }
    }
    if (kDebugMode) {
      debugPrint('FCM token saved: $normalizedToken');
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );
  }

  static void _openNotificationsScreen() {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      return;
    }

    navigator.pushNamed(AppRoutes.notifications);
  }
}