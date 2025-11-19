import 'package:flutter/material.dart';
import 'package:get/get.dart';

BuildContext? _getContext() {
  return Get.context ?? Get.key.currentContext;
}

void showSnackkbar({required String title, required String message}) {
  _showBaseSnackbar(
    title: title,
    message: message,
    background: Get.theme.colorScheme.primary,
    textColor: Colors.white,
  );
}

void showSuccessSnackkbar({String? title, required String message}) {
  _showBaseSnackbar(
    title: title ?? "SUCCESS!",
    message: message,
    background: Get.theme.colorScheme.primary,
    textColor: Colors.white,
  );
}

void showWarningSnackkbar({String? title, required String message}) {
  _showBaseSnackbar(
    title: title ?? "WARNING!",
    message: message,
    background: Colors.yellow.shade700,
    textColor: Colors.black,
  );
}

void showErrorSnackkbar({String? title, required String message}) {
  _showBaseSnackbar(
    title: title ?? "ERROR!",
    message: message,
    background: Colors.red,
    textColor: Colors.white,
  );
}

/// ------------------------
/// 🔥 Base Snackbar
/// ------------------------
void _showBaseSnackbar({
  required String title,
  required String message,
  required Color background,
  required Color textColor,
}) {
  final context = _getContext();
  if (context == null) return; // Prevent crash if no context

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: background,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(message, style: TextStyle(color: textColor)),
        ],
      ),
    ),
  );
}
