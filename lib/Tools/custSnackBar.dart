import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackbar({
  required String title,
  required String message,
  bool isError = false,
}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM, // Position: TOP or BOTTOM
    backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
    colorText: Colors.white,
    borderRadius: 10,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
    icon: Icon(
      isError ? Icons.error_outline : Icons.check_circle_outline,
      color: Colors.white,
    ),
    shouldIconPulse: true,
    mainButton: TextButton(
      onPressed: () => Get.closeCurrentSnackbar(),
      child: const Text("DISMISS", style: TextStyle(color: Colors.white)),
    ),
  );
}
