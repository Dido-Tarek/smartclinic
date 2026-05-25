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
import 'core/helper/user_session.dart';
import 'core/helper/user_roles.dart';
import 'core/services/push_notification_service.dart';

final GlobalKey<MyAppState> appKey = GlobalKey<MyAppState>();
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SharedPrefsHelper.init();
  await setupGetIt();
  await Firebase.initializeApp();
  await PushNotificationService.initialize(appNavigatorKey);

  // ---------------------------------------------------------
  // await getIt<UserSession>().initMockSession(
  //   role: UserRole.doctor,
  //   userId: "5fe5c967-3797-4dac-a1a8-3faba1265e32",
  //   token:
  //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiRGlhYSBFbCBEaW4gdGFyZWsiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjVmZTVjOTY3LTM3OTctNGRhYy1hMWE4LTNmYWJhMTI2NWUzMiIsImp0aSI6ImMxNzMwNjliLTUzZjEtNGM0Zi05NzY5LTVjNDMxYzRmNzkzMyIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IkRvY3RvciIsImV4cCI6MTc3OTU5OTE2MiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo1MDAwIiwiYXVkIjoiaHR0cDovL2xvY2FsaG9zdDo0MjAwIn0.ITvJaJzZooKn_3ODPz_GZHJ73NaY4IoREdlZTUfIrxE",
  // );
  // Doctor Email: diaatarek93@gmail.com
  // Doctor Password: Pass@123

  // await getIt<UserSession>().initMockSession(
  //   role: UserRole.patient,
  //   userId: "cbdb804d-1092-4d98-9d86-a9b028a46903",
  //   token:
  //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiQWhtZWQgQWJvIFRlc2h0IiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZWlkZW50aWZpZXIiOiJjYmRiODA0ZC0xMDkyLTRkOTgtOWQ4Ni1hOWIwMjhhNDY5MDMiLCJqdGkiOiIyMmZiM2ZiZC1mMzJlLTQ4MjctYmRlNi1mMzI4MjUzNTc1ZTciLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJQYXRpZW50IiwiZXhwIjoxNzc5NDk4MTk1LCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjUwMDAiLCJhdWQiOiJodHRwOi8vbG9jYWxob3N0OjQyMDAifQ.XlUq0pXhlIDgiUYsHKteZXM38l49i9e77kF3oYgUzrk",
  // );
  // Patient Email: aboteshta@gmail.com
  // Patient Password: 808080@Gg

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
