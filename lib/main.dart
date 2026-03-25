import 'constant/appTheme.dart';
import 'router.dart';
import 'view/splash_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'services/map_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://app-api.techniche.org.in',
    anonKey: 'sb_publishable_ciFSMUfqc4ynJ7eFvHC0Ug_4js-PR63',
  );

  // Initialize Map Cache immediately
  await MapCacheService.init();

  // Remote Config (skip on web if it causes issues)
  if (!kIsWeb) {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: Duration.zero,
    ));
    await remoteConfig.setDefaults(const {
      "marathon_registrations_open": true,
    });
    await remoteConfig.fetchAndActivate();
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
        if (kIsWeb) return child!;
        return WithForegroundTask(child: child!);
      },
    );
  }
}
