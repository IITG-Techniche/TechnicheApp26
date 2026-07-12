import 'constant/appTheme.dart';
import 'router.dart';
import 'view/core/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Supabase.initialize(
      url: 'https://app-api.techniche.org.in',
      anonKey: 'sb_publishable_ciFSMUfqc4ynJ7eFvHC0Ug_4js-PR63',
    );
  } catch (e) {
    debugPrint("Failed to initialize core services: $e");
  }

  runApp(const ProviderScope(
    child: MyApp(),
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
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      builder: (context, child) {
        return child!;
      },
    );
  }
}
