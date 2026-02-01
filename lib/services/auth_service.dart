import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class AuthService extends GetxService {
  final supabase = Supabase.instance.client;
  
  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    try {
      supabase.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        switch (event) {
          case AuthChangeEvent.signedIn:
            if (session?.user != null) {
              // التأكد من وجود AuthController قبل التنقل
              try {
                if (Get.isRegistered<AuthController>()) {
                  final authController = Get.find<AuthController>();
                  authController.clearForm();
                }
              } catch (e) {
                // AuthController غير موجود، تجاهل
                debugPrint('AuthController not found: $e');
              }
              Get.offAllNamed(AppConstants.homeRoute);
            }
            break;
          case AuthChangeEvent.signedOut:
            // Clean up all controllers before navigation to prevent disposal issues
            _cleanupAllControllers();
            Get.offAllNamed(AppConstants.authRoute);
            break;
          case AuthChangeEvent.tokenRefreshed:
            // Handle token refresh if needed
            break;
          default:
            break;
        }
      });
    } catch (e) {
      debugPrint('Error setting up auth listener: $e');
    }
  }
  
  // Check if user email is confirmed
  bool get isEmailConfirmed {
    try {
      final user = supabase.auth.currentUser;
      return user?.emailConfirmedAt != null;
    } catch (e) {
      debugPrint('Error checking email confirmation: $e');
      return false;
    }
  }
  
  // Get user profile from users table
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;
      
      final response = await supabase
          .from(AppConstants.usersTable)
          .select()
          .eq('id', user.id)
          .single();
      
      return response;
    } catch (error) {
      debugPrint('Error fetching user profile: $error');
      return null;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      debugPrint('Error signing out: $error');
      rethrow;
    }
  }

  // Clean up all controllers to prevent disposal issues
  void _cleanupAllControllers() {
    try {
      // Delete all controllers that might have TextEditingControllers
      final controllersToDelete = [
        'AuthController',
        'ProfileEditController', 
        'CreatePostController',
        'CommentsController',
        'PostsController',
        'HomeController',
        'SettingsController'
      ];
      
      for (String controllerName in controllersToDelete) {
        try {
          Get.delete(tag: controllerName, force: true);
        } catch (e) {
          // Controller might not be registered, ignore
        }
      }
      
      // Also try to delete by type
      if (Get.isRegistered<AuthController>()) {
        Get.delete<AuthController>(force: true);
      }
    } catch (e) {
      debugPrint('Error cleaning up controllers: $e');
    }
  }
}