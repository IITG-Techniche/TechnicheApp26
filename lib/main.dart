import 'package:amazon_clone/controller/provider_controller/user_provider.dart';
import 'package:amazon_clone/router.dart';
import 'view/splash_screen_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) => generateRoute(settings),
      debugShowCheckedModeBanner: false,
      title: 'Techniche 2025',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Orbitron',
        scaffoldBackgroundColor: const Color(0xFF18122B), // deep purple/black
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF00FFF7), // neon cyan
          onPrimary: Colors.black,
          secondary: Color(0xFF00FFF7), // neon cyan
          onSecondary: Colors.black,
          error: Color(0xFFFF1744),
          onError: Colors.white,
          background: Color(0xFF18122B),
          onBackground: Color(0xFF00FFF7),
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
            backgroundColor: MaterialStateProperty.all(Color(0xFF00FFF7)),
            foregroundColor: MaterialStateProperty.all(Color(0xFF18122B)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Color(0xFF00FFF7), width: 2),
            )),
            shadowColor: MaterialStateProperty.all(Color(0xFF00FFF7)),
            elevation: MaterialStateProperty.all(12),
            textStyle: MaterialStateProperty.all(TextStyle(
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
        cardTheme: CardTheme(
          color: Color(0xFF232946),
          elevation: 10,
          shadowColor: Color(0xFF00FFF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Color(0xFF00FFF7), width: 2),
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
