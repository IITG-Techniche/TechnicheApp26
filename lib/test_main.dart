import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'view/marathon/marathon_dashboard_tab.dart';
import 'view/marathon/marathon_run_tab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ejnxgufotlkhnmjqpdvs.supabase.co',
    anonKey: 'sb_publishable_ciFSMUfqc4ynJ7eFvHC0Ug_4js-PR63',
  );

  runApp(const ProviderScope(child: TestApp()));
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MarathonDashboardTab(), // change to MarathonRunTab() to test run screen
    );
  }
}