import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ErrorHandler {
  static void handleError(dynamic error, {String? context}) {
    String message = _getErrorMessage(error);
    String title = _getErrorTitle(error);
    
    // Log error for debugging
    debugPrint('Error in $context: $error');
    
    // Show user-friendly message
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
    );
  }

  static String _getErrorTitle(dynamic error) {
    if (error is SocketException) {
      return 'مشكلة في الاتصال';
    } else if (error is AuthException) {
      return 'خطأ في المصادقة';
    } else if (error is PostgrestException) {
      return 'خطأ في البيانات';
    } else if (error is StorageException) {
      return 'خطأ في التخزين';
    } else {
      return 'خطأ';
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
    } else if (error is AuthException) {
      return _getAuthErrorMessage(error.message);
    } else if (error is PostgrestException) {
      return _getPostgrestErrorMessage(error.message);
    } else if (error is StorageException) {
      return _getStorageErrorMessage(error.message);
    } else if (error.toString().contains('timeout')) {
      return 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت';
    } else if (error.toString().contains('network')) {
      return 'مشكلة في الشبكة. تحقق من اتصالك بالإنترنت';
    } else if (error.toString().contains('permission')) {
      return 'ليس لديك صلاحية للقيام بهذا الإجراء';
    } else {
      return 'حدث خطأ غير متوقع. حاول مرة أخرى';
    }
  }

  static String _getAuthErrorMessage(String message) {
    switch (message.toLowerCase()) {
      case 'invalid login credentials':
        return 'بيانات تسجيل الدخول غير صحيحة';
      case 'email already registered':
      case 'user already registered':
        return 'البريد الإلكتروني مسجل مسبقاً';
      case 'password should be at least 6 characters':
        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      case 'invalid email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user not found':
        return 'المستخدم غير موجود';
      case 'session expired':
        return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى';
      default:
        return 'خطأ في المصادقة: $message';
    }
  }

  static String _getPostgrestErrorMessage(String message) {
    if (message.contains('duplicate key')) {
      return 'البيانات موجودة مسبقاً';
    } else if (message.contains('foreign key')) {
      return 'خطأ في ربط البيانات';
    } else if (message.contains('not null')) {
      return 'بعض البيانات المطلوبة مفقودة';
    } else if (message.contains('permission denied')) {
      return 'ليس لديك صلاحية للوصول لهذه البيانات';
    } else {
      return 'خطأ في قاعدة البيانات';
    }
  }

  static String _getStorageErrorMessage(String message) {
    if (message.contains('file too large')) {
      return 'حجم الملف كبير جداً';
    } else if (message.contains('invalid file type')) {
      return 'نوع الملف غير مدعوم';
    } else if (message.contains('permission denied')) {
      return 'ليس لديك صلاحية لرفع الملفات';
    } else {
      return 'خطأ في رفع الملف';
    }
  }

  // Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Show no internet dialog
  static void showNoInternetDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.cardColor,
        title: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            const SizedBox(width: 8),
            Text('لا يوجد اتصال بالإنترنت'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('موافق'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              if (await hasInternetConnection()) {
                Get.snackbar(
                  'تم الاتصال',
                  'تم استعادة الاتصال بالإنترنت',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                showNoInternetDialog();
              }
            },
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Retry mechanism
  static Future<T?> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? context,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error) {
        if (attempt == maxRetries) {
          handleError(error, context: context);
          return null;
        }
        
        // Wait before retry
        await Future.delayed(delay * attempt);
        
        // Check internet connection before retry
        if (!await hasInternetConnection()) {
          showNoInternetDialog();
          return null;
        }
      }
    }
    return null;
  }

  // Safe async operation wrapper
  static Future<T?> safeAsyncOperation<T>(
    Future<T> Function() operation, {
    String? context,
    bool showLoading = false,
  }) async {
    if (showLoading) {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
    }

    try {
      // Check internet connection first
      if (!await hasInternetConnection()) {
        if (showLoading) Get.back();
        showNoInternetDialog();
        return null;
      }

      final result = await operation();
      if (showLoading) Get.back();
      return result;
    } catch (error) {
      if (showLoading) Get.back();
      handleError(error, context: context);
      return null;
    }
  }
}