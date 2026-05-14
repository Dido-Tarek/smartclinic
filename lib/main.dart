import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartclinic/core/helper/shared_preds_helper.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'core/constants/config.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localization.dart';
import 'injection_dependency.dart';
import 'core/helper/user_session.dart';
import 'core/helper/user_roles.dart';

final GlobalKey<MyAppState> appKey = GlobalKey<MyAppState>();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SharedPrefsHelper.init();
  await setupGetIt();

  // ---------------------------------------------------------
  // await getIt<UserSession>().initMockSession(
  //   role: UserRole.doctor,
  //   userId: "5fe5c967-3797-4dac-a1a8-3faba1265e32",
  //   token: ""
  // );

  await getIt<UserSession>().initMockSession(
    role: UserRole.patient,
    userId: "cbdb804d-1092-4d98-9d86-a9b028a46903",
    token:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiQWhtZWQgQWJvIFRlc2h0IiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZWlkZW50aWZpZXIiOiJjYmRiODA0ZC0xMDkyLTRkOTgtOWQ4Ni1hOWIwMjhhNDY5MDMiLCJqdGkiOiIwNDE4YzM3Mi00MjczLTQzNDMtYTQzYi1lMWNjMmUxOGU5NDUiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJQYXRpZW50IiwiZXhwIjoxNzc4ODAxMzAyLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjUwMDAiLCJhdWQiOiJodHRwOi8vbG9jYWxob3N0OjQyMDAifQ.qHTEFlfCtLruAdbZX8nvql-3CklhICF3Rvu1FcEaBN0",
  );

  // await getIt<UserSession>().initMockSession(
  //   role: UserRole.hospital,
  //   userId: "YOUR_HOSPITAL_ID_HERE",
  //   token: ""
  // );

  // ---------------------------------------------------------
  runApp(MyApp(key: appKey));
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
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
    FlutterNativeSplash.remove();
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
