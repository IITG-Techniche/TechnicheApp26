import 'package:amazon_clone/constant/global.dart';
import 'package:amazon_clone/controller/provider_controller/user_provider.dart';
import 'package:amazon_clone/router.dart';
import 'view/splash_screen_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
  );

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
