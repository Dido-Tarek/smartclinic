import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:dio/dio.dart';

// ─── Shared channel definition ───────────────────────────────────────────────
// Defined at top-level so both the background isolate and the main isolate
// can reference the exact same channel ID/name without duplication.
const _kChannelId = 'smartclinic_notifications';
const _kChannelName = 'SmartClinic Notifications';
const _kChannelDescription = 'High priority notifications for SmartClinic';

/// Background message handler — runs in a separate isolate when the app is
/// killed or in the background.  Must be a top-level function.
///
/// Handles both:
///  • Notification messages  — [message.notification] is populated by Firebase
///  • Data-only messages     — [message.notification] is null; title/body are
///    extracted from [message.data] (common with ASP.NET / custom backends)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // firebase_messaging already calls DartPluginRegistrant.ensureInitialized()
  // internally before invoking this handler — do NOT call
  // WidgetsFlutterBinding.ensureInitialized() here; it conflicts with the
  // background isolate setup and crashes the handler silently.

  // Firebase must be initialised in every isolate independently.
  await Firebase.initializeApp();

  if (kDebugMode) {
    debugPrint('=== FCM BG HANDLER ===');
    debugPrint('notification field: ${message.notification?.title} / ${message.notification?.body}');
    debugPrint('data keys: ${message.data.keys.toList()}');
    debugPrint('data values: ${message.data}');
  }

  // ── Resolve title & body ────────────────────────────────────────────────
  // Priority: notification payload → data payload → sensible defaults.
  final notification = message.notification;
  final title = notification?.title
      ?? message.data['title']
      ?? message.data['Title']
      ?? message.data['notificationTitle']
      ?? 'SmartClinic';
  final body = notification?.body
      ?? message.data['body']
      ?? message.data['Body']
      ?? message.data['message']
      ?? message.data['Message']
      ?? message.data['content']
      ?? message.data['Content']
      ?? '';

  if (kDebugMode) {
    debugPrint('Resolved title="$title" body="$body"');
  }

  // If title/body are STILL empty after checking all those keys, the C# backend
  // is sending a data payload with completely different keys. Let's dump the
  // raw data payload into the body so we can see it in the system tray!
  final finalTitle = title == 'SmartClinic' && body.isEmpty ? 'Debug: Backend Payload' : title;
  final finalBody = body.isEmpty ? message.data.toString() : body;

  if (kDebugMode) {
    debugPrint('FCM BG: nothing found, showing raw data: $finalBody');
  }

  try {
    // We need our own plugin instance — the main-isolate one is not accessible here.
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(const InitializationSettings(android: androidInit));

    // Re-create the channel — safe to call multiple times (idempotent).
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _kChannelId,
        _kChannelName,
        description: _kChannelDescription,
        importance: Importance.high,
      ),
    );

    await plugin.show(
      message.hashCode,
      finalTitle,
      finalBody,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _kChannelId,
          _kChannelName,
          channelDescription: _kChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );

    if (kDebugMode) {
      debugPrint('FCM BG: notification shown successfully ✓');
    }
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('FCM BG: FAILED to show notification: $e');
      debugPrint(stack.toString());
    }
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        _kChannelId,
        _kChannelName,
        description: _kChannelDescription,
        importance: Importance.high,
      );

  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _initialized = false;

  /// Creates the Android notification channel as early as possible — called
  /// BEFORE [runApp] so that no incoming message can be dropped due to a
  /// missing channel.
  static Future<void> createChannelEarly() async {
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotificationsPlugin.initialize(
      const InitializationSettings(android: androidInit),
    );
    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
    if (kDebugMode) debugPrint('FCM channel created early');
  }

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

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
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

    // Ensure the channel exists (idempotent — safe to call again here).
    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openNotificationsScreen();
    });

    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _openNotificationsScreen();
    }

    await _syncCurrentToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _persistToken(token);
    });

    _initialized = true;
  }

  /// Re-syncs the FCM token to the backend immediately after the user logs in.
  /// Call this from the login success handler so the backend always has a valid
  /// token for the authenticated user.
  static Future<void> syncTokenAfterLogin() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.trim().isNotEmpty) {
        await _persistToken(token);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('syncTokenAfterLogin failed: $e');
    }
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
          // The C# backend expects a plain JSON string body: "token_value"
          // jsonEncode wraps the string in quotes → "fRADk..." (correct format).
          // Confirmed from Swagger: request body is a quoted string, not an object.
          data: jsonEncode(normalizedToken),
          options: Options(contentType: 'application/json'),
        );
        if (kDebugMode) debugPrint('✓ Device token saved on backend successfully');
      } catch (e) {
        if (kDebugMode) debugPrint('✗ Failed to save device token on backend: $e');
      }
    }
    if (kDebugMode) {
      debugPrint('FCM token: $normalizedToken');
    }
  }

  static Future<void> _showForegroundNotification(
      RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('=== FCM FOREGROUND HANDLER ===');
      debugPrint('data keys: ${message.data.keys.toList()}');
    }

    // Same fallback logic as the background handler.
    final notification = message.notification;
    final title = notification?.title
        ?? message.data['title']
        ?? message.data['Title']
        ?? message.data['notificationTitle']
        ?? 'SmartClinic';
    final body = notification?.body
        ?? message.data['body']
        ?? message.data['Body']
        ?? message.data['message']
        ?? message.data['Message']
        ?? message.data['content']
        ?? message.data['Content']
        ?? '';

    // If still empty, the backend is using unknown keys. Show the raw data!
    final finalTitle = title == 'SmartClinic' && body.isEmpty ? 'Debug: Foreground Payload' : title;
    final finalBody = body.isEmpty ? message.data.toString() : body;

    const androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _localNotificationsPlugin.show(
      message.hashCode,
      finalTitle,
      finalBody,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
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