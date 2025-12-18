import 'constant/appTheme.dart';
import 'router.dart';
import 'view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://xhsenvvfkwdglxoihvdu.supabase.co',
    anonKey: 'sb_publishable_m-34-6lrb5mKrAhxpqnCiw_SnvLXvQ5',
  );

  // Riverpod only - no Provider needed for CA auth
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
    );
  }
}
