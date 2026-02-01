import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final session = supabase.auth.currentSession;
    
    // Check if user is authenticated and session is valid
    if (user == null || session == null) {
      return RouteSettings(name: AppConstants.authRoute);
    }
    
    // Check if session is expired and try to refresh
    if (session.expiresAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      final expiresAt = session.expiresAt!;
      
      // If session expires in less than 5 minutes, try to refresh
      if (now >= (expiresAt - 300)) {
        _refreshSession();
      }
      
      // If session is already expired, redirect to auth
      if (now >= expiresAt) {
        return RouteSettings(name: AppConstants.authRoute);
      }
    }
    
    return null;
  }
  
  // Refresh session in background
  void _refreshSession() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
    } catch (e) {
      // If refresh fails, user will be redirected on next navigation
      debugPrint('Failed to refresh session: $e');
    }
  }
}