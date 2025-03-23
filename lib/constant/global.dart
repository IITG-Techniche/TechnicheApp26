import 'package:flutter/material.dart';

final String phoneURI = 'http://192.168.0.103:3001/api';

class GlobalVariables {
  static Color primaryColor = Colors.orange;
  static const String baseUrl = bool.fromEnvironment('dart.vm.product')
      ? 'https://techniche.org.in/api'
      : 'http://10.0.2.2:3001/api';
}
