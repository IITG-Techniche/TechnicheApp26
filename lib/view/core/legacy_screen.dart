import 'package:flutter/material.dart';

class LegacyScreen extends StatelessWidget {
  static const String routeName = '/legacy';
  const LegacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B19) : Colors.white,
      appBar: AppBar(
        title: const Text('LEGACY'),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF070B19) : Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: const SizedBox.expand(),
    );
  }
}