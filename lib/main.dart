import './controller/provider_controller/user_provider.dart';
import 'router.dart';
import 'view/splash_screen_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://oroilzktoorpcofqkqam.supabase.co',
    anonKey:
        '<prefer publishable key instead of anon key for mobile and desktop apps>',
  );

  runApp(ProviderScope(
    child: MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) => generateRoute(settings),
      debugShowCheckedModeBanner: false,
      title: 'Techniche 2026',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Orbitron',
        scaffoldBackgroundColor: const Color(0xFF18122B), // deep purple/black
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF00FFF7), // neon cyan
          onPrimary: Colors.black,
          secondary: Color(0xFF00FFF7), // neon cyan
          onSecondary: Colors.black,
          error: Color(0xFFFF1744),
          onError: Colors.white,
          surface: Color(0xFF232946), // dark blue
          onSurface: Color(0xFF00FFF7),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF232946),
          elevation: 8,
          titleTextStyle: TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF00FFF7),
            shadows: [
              Shadow(
                  blurRadius: 7.5,
                  color: Color(0xFF00FFF7),
                  offset: Offset(0, 0)),
            ],
          ),
          iconTheme: IconThemeData(color: Color(0xFF00FFF7)),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xFF18122B),
            statusBarBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Color(0xFF00FFF7)),
            foregroundColor: WidgetStateProperty.all(Color(0xFF18122B)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Color(0xFF00FFF7), width: 2),
            )),
            shadowColor: WidgetStateProperty.all(Color(0xFF00FFF7)),
            elevation: WidgetStateProperty.all(12),
            textStyle: WidgetStateProperty.all(TextStyle(
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 2,
              shadows: [
                Shadow(
                    blurRadius: 5,
                    color: Color(0xFF00FFF7),
                    offset: Offset(0, 0)),
              ],
            )),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF232946),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF00FFF7), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF00FFF7), width: 2),
          ),
          labelStyle: TextStyle(
            color: Color(0xFF00FFF7),
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                  blurRadius: 6,
                  color: Color(0xFF00FFF7),
                  offset: Offset(0, 0)),
            ],
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Color(0xFF00FFF7),
            shadows: [
              Shadow(
                  blurRadius: 9,
                  color: Color(0xFF00FFF7),
                  offset: Offset(0, 0)),
            ],
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 18,
            color: Color(0xFF00FFF7),
            shadows: [
              Shadow(
                  blurRadius: 6,
                  color: Color(0xFF00FFF7),
                  offset: Offset(0, 0)),
            ],
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 16,
            color: Color(0xFFB8C1EC),
          ),
        ),
      ),
      // Define all routes for your application
      home: SplashScreenWrapper(),
    );
  }
}
