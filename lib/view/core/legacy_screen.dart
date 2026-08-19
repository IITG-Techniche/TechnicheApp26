import 'package:flutter/material.dart';

class LegacyPage extends StatelessWidget {
  static const String routeName = '/legacy';

  const LegacyPage({super.key});

  static const String routeName = '/legacy';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            fontFamily: 'Univers',
          ),
        ),
      ),
    );
  }
}