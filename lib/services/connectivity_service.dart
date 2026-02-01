import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find();
  
  var isConnected = true.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startMonitoring();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startMonitoring() {
    // Check immediately
    checkConnection();
    
    // Check every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      checkConnection();
    });
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      bool connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (isConnected.value != connected) {
        isConnected.value = connected;
        
        if (connected) {
          _showConnectionRestored();
        } else {
          _showConnectionLost();
        }
      }
    } on SocketException catch (_) {
      if (isConnected.value) {
        isConnected.value = false;
        _showConnectionLost();
      }
    } on TimeoutException catch (_) {
      if (isConnected.value) {
        isConnected.value = false;
        _showConnectionLost();
      }
    }
  }

  void _showConnectionLost() {
    Get.snackbar(
      'انقطع الاتصال',
      'تم فقدان الاتصال بالإنترنت',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.wifi_off, color: Colors.white),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showConnectionRestored() {
    Get.snackbar(
      'تم الاتصال',
      'تم استعادة الاتصال بالإنترنت',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.wifi, color: Colors.white),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}