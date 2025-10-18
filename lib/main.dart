import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web initialization
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDptn4jEFE5X_b90FaHjpY_hcHTNP7YQW8",
        authDomain: "ownsell-61c89.firebaseapp.com",
        projectId: "ownsell-61c89",
        storageBucket: "ownsell-61c89.firebasestorage.app",
        messagingSenderId: "606745580465",
        appId: "1:606745580465:web:b860106956f9fb63ec2390",
      ),
    );
  } else {
    // Mobile/desktop initialization
    await Firebase.initializeApp();

    // Enable crashlytics collection
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Forward Flutter errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Forward errors from the platform layer
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // ✅ SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstLaunch = prefs.getBool("first_launch") ?? true;

  runApp(MyApp(isFirstLaunch: isFirstLaunch));
}

class MyApp extends StatefulWidget {
  final bool isFirstLaunch;
  const MyApp({super.key, required this.isFirstLaunch});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
            widget.isFirstLaunch
                ? WelcomeScreen() // ✅ show welcome only once
                : Consumer<AuthService>(
                  builder: (context, auth, _) {
                    if (auth.user != null) {
                      return MainNavigationScreen();
                    } else {
                      return LoginScreen();
                    }
                  },
                ),
      ),
    );
  }
}
