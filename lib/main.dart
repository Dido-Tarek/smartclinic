import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartclinic/core/helper/shared_preds_helper.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'core/constants/config.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localization.dart';
import 'injection_dependency.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/bg_remover_service.dart';

final GlobalKey<MyAppState> appKey = GlobalKey<MyAppState>();
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (const bool.fromEnvironment('dart.vm.product')) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SharedPrefsHelper.init();
  await setupGetIt();

  // Firebase must be initialised BEFORE runApp so that:
  //  1. The Android notification channel is created before any FCM message
  //     can arrive (eliminates the race condition).
  //  2. The background message handler isolate can safely call
  //     Firebase.initializeApp() on its own.
  await Firebase.initializeApp();
  await PushNotificationService.createChannelEarly();

  runApp(MyApp(key: appKey));

  unawaited(_initializeServices());
}

Future<void> _initializeServices() async {
  try {
    await PushNotificationService.initialize(appNavigatorKey);
    // Initialize the background-removal ONNX model in the background
    // so it is ready by the time the user reaches a doctor card.
    await BgRemoverService.instance.initialize();
  } catch (error) {
    debugPrint('Startup service initialization failed: $error');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      if (!mounted) {
        return;
      }
      setState(() {
        _locale = Locale(languageCode);
      });
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
