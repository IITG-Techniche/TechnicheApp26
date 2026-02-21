import 'constant/appTheme.dart';
import 'router.dart';
import 'view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://ejnxgufotlkhnmjqpdvs.supabase.co',
    anonKey: 'sb_publishable_ciFSMUfqc4ynJ7eFvHC0Ug_4js-PR63',
  );

  // Initialize Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: Duration.zero,
  ));
  await remoteConfig.setDefaults(const {
    "marathon_registrations_open": true,
  });
  await remoteConfig.fetchAndActivate();

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
      home: WithForegroundTask(child: const SplashScreen()),
    );
  }
}
