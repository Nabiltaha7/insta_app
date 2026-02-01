import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/auth_helper.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  // Observable variables
  var isLoading = false.obs;
  var isSignUp = false.obs;
  var isPasswordVisible = false.obs;

  // Form controllers - use nullable and recreate when needed
  TextEditingController? _usernameController;
  TextEditingController? _passwordController;
  TextEditingController? _emailController;
  TextEditingController? _fullNameController;

  // Getters for controllers with lazy initialization
  TextEditingController get usernameController {
    _usernameController ??= TextEditingController();
    return _usernameController!;
  }

  TextEditingController get passwordController {
    _passwordController ??= TextEditingController();
    return _passwordController!;
  }

  TextEditingController get emailController {
    _emailController ??= TextEditingController();
    return _emailController!;
  }

  TextEditingController get fullNameController {
    _fullNameController ??= TextEditingController();
    return _fullNameController!;
  }

  // Form keys
  final signInFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    
    // Initialize AuthService if not already initialized
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService());
    }
    
    // التحقق من حالة المصادقة عند بدء التشغيل
    checkAuthState();
    
    // مراقبة تغييرات حالة المصادقة
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        // المستخدم سجل دخول
        clearForm();
        isSignUp.value = false;
      } else if (event == AuthChangeEvent.signedOut) {
        // المستخدم سجل خروج
        clearForm();
        isSignUp.value = false;
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        // تم تحديث الرمز المميز
        debugPrint('Token refreshed');
      }
    });
  }
  
  // Check current authentication state
  void checkAuthState() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // المستخدم مسجل دخول، تنظيف النماذج
      clearForm();
      isSignUp.value = false;
    }
  }
  
  @override
  void onClose() {
    // Dispose controllers safely
    try {
      _usernameController?.dispose();
      _passwordController?.dispose();
      _emailController?.dispose();
      _fullNameController?.dispose();
      
      // Set to null after disposal
      _usernameController = null;
      _passwordController = null;
      _emailController = null;
      _fullNameController = null;
    } catch (e) {
      // Controllers might already be disposed, ignore error
      debugPrint('Error disposing controllers: $e');
    }
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle between sign in and sign up
  void toggleAuthMode() {
    isSignUp.value = !isSignUp.value;
    clearForm();
  }

  // Clear form fields safely
  void clearForm() {
    try {
      _usernameController?.clear();
      _passwordController?.clear();
      _emailController?.clear();
      _fullNameController?.clear();
    } catch (e) {
      // Controllers might be disposed, ignore error
      debugPrint('Error clearing form: $e');
    }
  }

  // Reset controllers - dispose old ones and allow new ones to be created
  void resetControllers() {
    try {
      _usernameController?.dispose();
      _passwordController?.dispose();
      _emailController?.dispose();
      _fullNameController?.dispose();
    } catch (e) {
      debugPrint('Error disposing old controllers: $e');
    }
    
    // Set to null so they will be recreated when accessed
    _usernameController = null;
    _passwordController = null;
    _emailController = null;
    _fullNameController = null;
  }

  // Sign in with username and password
  Future<void> signIn() async {
    if (!signInFormKey.currentState!.validate()) return;

    await ErrorHandler.safeAsyncOperation(
      () async {
        isLoading.value = true;

        // Get user email by username
        final userResponse = await supabase
            .from(AppConstants.usersTable)
            .select('email')
            .eq('username', usernameController.text.trim())
            .maybeSingle();

        if (userResponse == null) {
          throw Exception('اسم المستخدم غير موجود');
        }

        final email = userResponse['email'];

        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: passwordController.text,
        );

        final user = response.user;

        if (user != null) {
          // دخول ناجح
          Get.snackbar(
            'نجح تسجيل الدخول',
            'مرحباً بك مرة أخرى!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          Get.offAllNamed(AppConstants.homeRoute);
        }
      },
      context: 'تسجيل الدخول',
    );

    isLoading.value = false;
  }

  // Check if email or username already exists
  Future<bool> checkUserExists(String email, String username) async {
    return await AuthHelper.checkUserExists(email, username);
  }

  // Sign up with email and password

  // Sign up with email and password
  Future<void> signUp() async {
    if (!signUpFormKey.currentState!.validate()) return;

    await ErrorHandler.safeAsyncOperation(
      () async {
        isLoading.value = true;

        // التحقق من عدم تكرار البيانات
        final userExists = await checkUserExists(
          emailController.text.trim(),
          usernameController.text.trim(),
        );

        if (userExists) {
          return;
        }

        // إنشاء الحساب
        final response = await AuthHelper.signUpWithRateLimit(
          email: emailController.text.trim(),
          password: passwordController.text,
          username: usernameController.text.trim(),
          fullName: fullNameController.text.trim(),
        );

        // إذا تم إنشاء المستخدم بنجاح
        if (response?.user != null) {
          Get.snackbar(
            'تم إنشاء الحساب',
            'تم إرسال رسالة تأكيد إلى بريدك الإلكتروني. يرجى تأكيد البريد ثم تسجيل الدخول.',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(seconds: 6),
          );

          // الرجوع لواجهة تسجيل الدخول
          isSignUp.value = false;
          passwordController.clear();
        }
        // حالة Rate Limit (تم إنشاء الحساب لكن فشل إرسال الإيميل)
        else if (response == null) {
          Get.snackbar(
            'تم إنشاء الحساب',
            'تم إنشاء حسابك بنجاح. يرجى محاولة تسجيل الدخول.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          isSignUp.value = false;
          passwordController.clear();
        }
      },
      context: 'إنشاء الحساب',
    );

    isLoading.value = false;
  }

  // Sign out
  Future<void> signOut() async {
    await ErrorHandler.safeAsyncOperation(
      () async {
        // Reset controllers before signing out
        resetControllers();
        
        await supabase.auth.signOut();

        // تنظيف البيانات
        isSignUp.value = false;

        // الانتقال لصفحة تسجيل الدخول
        Get.offAllNamed(AppConstants.authRoute);
      },
      context: 'تسجيل الخروج',
    );
  }


  // Check if user is authenticated
  bool get isAuthenticated => supabase.auth.currentUser != null;

  // Get current user
  User? get currentUser => supabase.auth.currentUser;
}
