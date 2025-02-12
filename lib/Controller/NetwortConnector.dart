import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fincauselist/Tools/custSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  bool _isSnackbarActive = false; // Track if snackbar is active

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (!_isSnackbarActive) {
        _isSnackbarActive = true;
        Future.delayed(Duration.zero, () {
          Get.snackbar(
            "No Network",
            "Kindly check your network connection 😢",
            snackPosition: SnackPosition.BOTTOM,
            borderWidth: double.infinity,
            snackStyle: SnackStyle.GROUNDED,
            maxWidth: double.infinity,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: Duration(days: 1), // Large duration to keep it persistent
            isDismissible: false, // Prevent user from dismissing it manually
            icon: const Icon(Icons.wifi_off, color: Colors.white),
            animationDuration: Duration(seconds: 4),
            reverseAnimationCurve: Curves.easeOut,
            margin: EdgeInsets.zero
          );
        });
      }
    } else {
      if (_isSnackbarActive) {
        Get.closeAllSnackbars(); // Remove snackbar when network is restored
        _isSnackbarActive = false;
      }
      
    }
  }

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }
}