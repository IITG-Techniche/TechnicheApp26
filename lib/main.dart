import 'package:amazon_clone/constant/global.dart';
import 'package:amazon_clone/controller/authController.dart';
import 'package:amazon_clone/controller/provider_controller/user_provider.dart';
import 'package:amazon_clone/router.dart';
import 'package:amazon_clone/services/notification_service.dart';
import 'package:amazon_clone/utils/bottomNavBar.dart';
import 'package:amazon_clone/view/auth/authScreen.dart';
import 'package:amazon_clone/view/landing_screen.dart';
import 'package:amazon_clone/view/ghm/marathon_screen.dart';
import 'package:amazon_clone/view/techniche_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize notifications without topics first
    final notificationService = NotificationService();
    await notificationService.initNotifications(subscribeToTopics: false);
    
    // Wait a moment for FCM to fully initialize
    await Future.delayed(const Duration(seconds: 3));
    
    // Then try to subscribe to topics
    await notificationService.subscribeToTopic('all_users');
    
  } catch (e) {
    print("Firebase/Notification Initialization error: $e");
  }

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthController authController = AuthController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token != null && token.isNotEmpty) {
        if (mounted) {
          await authController.fetchUserData(context);
        }
      }
    } catch (e) {
      print("Error initializing app: $e");
    } finally {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }

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
      // Define routes for our new screens
      routes: {
        '/': (context) => !_initialized
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const LandingScreen(),
        LandingScreen.routeName: (context) => const LandingScreen(),
        AuthScreen.routeName: (context) => const AuthScreen(),
        BottomNavBar.routeName: (context) => const BottomNavBar(),
        MarathonScreen.routeName: (context) => const MarathonScreen(),
        TechnicheScreen.routeName: (context) => const TechnicheScreen(),
      },
      // Use the landing screen as the initial route
      initialRoute: '/',
    );
  }
}
