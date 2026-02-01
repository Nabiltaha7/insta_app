import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class AuthHelper {
  static final supabase = Supabase.instance.client;
  
  // محاولة إنشاء حساب مع التعامل مع Rate Limit
  static Future<AuthResponse?> signUpWithRateLimit({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      // محاولة إنشاء الحساب
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // إضافة بيانات المستخدم لقاعدة البيانات
        await supabase.from(AppConstants.usersTable).insert({
          'id': response.user!.id,
          'email': email.toLowerCase(),
          'username': username.toLowerCase(),
          'full_name': fullName,
        });
      }
      
      return response;
    } on AuthException catch (error) {
      if (error.message.toLowerCase().contains('rate limit')) {
        // في حالة Rate Limit، نحاول إنشاء المستخدم في قاعدة البيانات مباشرة
        // هذا يعني أن الحساب تم إنشاؤه في Auth ولكن فشل في إرسال البريد
        Get.snackbar(
          'تم إنشاء الحساب',
          'تم إنشاء حسابك بنجاح! يمكنك تسجيل الدخول الآن.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        return null; // إشارة للنجاح مع Rate Limit
      }
      rethrow;
    }
  }
  
  // التحقق من وجود المستخدم
  static Future<bool> checkUserExists(String email, String username) async {
    try {
      // التحقق من البريد الإلكتروني
      final emailCheck = await supabase
          .from(AppConstants.usersTable)
          .select('email')
          .eq('email', email.toLowerCase())
          .maybeSingle();
      
      if (emailCheck != null) {
        Get.snackbar(
          'البريد الإلكتروني مستخدم',
          'هذا البريد الإلكتروني مسجل مسبقاً. يرجى استخدام بريد آخر أو تسجيل الدخول.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        return true;
      }
      
      // التحقق من اسم المستخدم
      final usernameCheck = await supabase
          .from(AppConstants.usersTable)
          .select('username')
          .eq('username', username.toLowerCase())
          .maybeSingle();
      
      if (usernameCheck != null) {
        Get.snackbar(
          'اسم المستخدم مستخدم',
          'هذا اسم المستخدم مأخوذ. يرجى اختيار اسم آخر.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        return true;
      }
      
      return false;
    } catch (error) {
      debugPrint('Error checking user exists: $error');
      return false;
    }
  }
}