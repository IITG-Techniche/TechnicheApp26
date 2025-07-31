import 'package:amazon_clone/constant/global.dart';
import 'package:amazon_clone/controller/provider_controller/user_provider.dart';
import 'package:amazon_clone/router.dart';
import 'package:amazon_clone/services/notification_service.dart';
//import 'package:amazon_clone/utils/bottomNavBar.dart';
//import 'package:amazon_clone/view/auth/authScreen.dart';
//import 'package:amazon_clone/view/ghm/marathon_screen.dart';
//import 'package:amazon_clone/view/landing_screen.dart';
import 'view/splash_screen_wrapper.dart';
//import 'package:amazon_clone/view/techniche_screen.dart';
//import 'package:amazon_clone/view/techno/papers_display.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final notificationService = NotificationService();
    await notificationService.resetFcmToken();
    await notificationService.initNotifications(subscribeToTopics: false);

    String? token;
    int attempts = 0;
    while (token == null && attempts < 3) {
      token = await notificationService.getDeviceToken();
      if (token == null) {
        attempts++;
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (token != null) {
      await notificationService.subscribeToTopic('all_users');
    }
  } catch (e) {
    print("Firebase/Notification Initialization error: $e");
  }

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
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF7E8C9),
        colorScheme: ColorScheme.light(
          primary: GlobalVariables.primaryColor,
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.orange,
              statusBarBrightness: Brightness.dark),
          backgroundColor: Colors.orange,
        ),
      ),
      // Define all routes for your application
      home: SplashScreenWrapper(),
    );
  }
}
