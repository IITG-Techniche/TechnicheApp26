import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void showMessage(BuildContext context, String msg, {bool isError = false}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Text(isError ? 'Alert' : 'Success'),
        ],
      ),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// Keeping this for backward compatibility, but it will use showMessage
void showSnackBar(BuildContext context, String msg) {
  showMessage(context, msg);
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
      showMessage(context, jsonDecode(response.body)['message'], isError: true);
      break;
    case 409:
      showMessage(context, jsonDecode(response.body)['message'], isError: true);
      break;
    case 204:
      showMessage(context, jsonDecode(response.body)['message']);
      break;
    case 208:
      showMessage(context, jsonDecode(response.body)['message'], isError: true);
      break;
    case 500:
      showMessage(context, jsonDecode(response.body)['message'], isError: true);
      break;
    case 401:
      showMessage(context, jsonDecode(response.body)['message'], isError: true);
      break;
    case 403:
      showMessage(context, jsonDecode(response.body)['message'], isError: true);
      break;
    case 404:
      showMessage(context, jsonDecode(response.body)['message'], isError: true);
      break;
    default:
      showMessage(context, response.body, isError: true);
  }
}
