import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void showSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

void httpErrorHandler({
  required BuildContext context,
  required http.Response response,
  required VoidCallback onSuccess,
}) {
  switch (response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 400:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    case 409:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    case 204:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    case 208:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    case 500:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    case 401:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    case 403:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    case 404:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    default:
      showSnackBar(context, response.body);
  }
}
