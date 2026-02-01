import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_edit_controller.dart';
import '../controllers/create_post_controller.dart';
import '../controllers/comments_controller.dart';
import '../controllers/posts_controller.dart';
import '../controllers/home_controller.dart';

class SettingsController extends GetxController {
  late final AuthService _authService;
  late final StorageService _storageService;
  final supabase = Supabase.instance.client;

  // Observable variables
  var isPrivate = false.obs;
  var showLastSeen = true.obs;
  var allowMessagesFromEveryone = true.obs;
  var isDarkMode = false.obs;
  var currentLanguage = 'ar'.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  // Initialize required services
  Future<void> _initializeServices() async {
    // Initialize AuthService if not already initialized
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService());
    }
    _authService = Get.find<AuthService>();

    // Initialize StorageService if not already initialized
    if (!Get.isRegistered<StorageService>()) {
      await Get.putAsync(() => StorageService().init());
    }
    _storageService = Get.find<StorageService>();
    
    // Load settings after services are initialized
    await loadUserSettings();
    loadAppSettings();
  }

  // Load user privacy settings
  Future<void> loadUserSettings() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      final userData = await supabase
          .from(AppConstants.usersTable)
          .select('is_private, show_last_seen, allow_messages_from_everyone')
          .eq('id', currentUser.id)
          .single();

      isPrivate.value = userData['is_private'] ?? false;
      showLastSeen.value = userData['show_last_seen'] ?? true;
      allowMessagesFromEveryone.value = userData['allow_messages_from_everyone'] ?? true;

    } catch (error) {
      debugPrint('Failed to load user settings: $error');
    }
  }

  // Load app settings from local storage
  void loadAppSettings() {
    try {
      // Load saved settings from SharedPreferences
      isDarkMode.value = _storageService.isDarkMode;
      currentLanguage.value = _storageService.language;
    } catch (error) {
      // Use default values if storage service is not available
      isDarkMode.value = true; // Default to dark mode
      currentLanguage.value = 'ar'; // Default to Arabic
      debugPrint('Failed to load app settings: $error');
    }
  }

  // Toggle private account (UI only)
  Future<void> togglePrivateAccount(bool value) async {
    isPrivate.value = value;
    Get.snackbar(
      'إعداد الخصوصية',
      value ? 'تم تفعيل الحساب الخاص' : 'تم إلغاء تفعيل الحساب الخاص',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // Toggle show last seen (UI only)
  Future<void> toggleShowLastSeen(bool value) async {
    showLastSeen.value = value;
    Get.snackbar(
      'إعداد آخر ظهور',
      value ? 'سيتم إظهار آخر ظهور' : 'لن يتم إظهار آخر ظهور',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // Toggle allow messages from everyone (UI only)
  Future<void> toggleAllowMessages(bool value) async {
    allowMessagesFromEveryone.value = value;
    Get.snackbar(
      'إعداد الرسائل',
      value ? 'السماح بالرسائل من الجميع' : 'السماح بالرسائل من المتابعين فقط',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // Toggle dark mode
  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    
    try {
      // Save to SharedPreferences
      await _storageService.setDarkMode(value);
    } catch (error) {
      debugPrint('Failed to save dark mode setting: $error');
    }
    
    Get.snackbar(
      'تم التحديث',
      value ? 'تم تفعيل الوضع الليلي' : 'تم تفعيل الوضع النهاري',
      backgroundColor: value ? Colors.grey.shade800 : Colors.green,
      colorText: Colors.white,
    );
  }

  // Show language selection dialog
  void showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(Get.context!).cardColor,
        title: Text('language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('العربية'),
              leading: Radio<String>(
                value: 'ar',
                groupValue: currentLanguage.value,
                onChanged: (value) {
                  if (value != null) {
                    changeLanguage(value);
                    Get.back();
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: currentLanguage.value,
                onChanged: (value) {
                  if (value != null) {
                    changeLanguage(value);
                    Get.back();
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    Get.updateLocale(Locale(languageCode));
    
    try {
      // Save to SharedPreferences
      await _storageService.setLanguage(languageCode);
    } catch (error) {
      debugPrint('Failed to save language setting: $error');
    }
    
    Get.snackbar(
      languageCode == 'ar' ? 'تم التحديث' : 'Updated',
      languageCode == 'ar' ? 'تم تغيير اللغة إلى العربية' : 'Language changed to English',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Show about dialog
  void showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(Get.context!).cardColor,
        title: Text('about_app'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تطبيق Instagram Clone'),
            const SizedBox(height: 8),
            const Text('الإصدار: 1.0.0'),
            const SizedBox(height: 8),
            const Text('تطبيق مشاركة الصور والفيديوهات'),
            const SizedBox(height: 8),
            const Text('تم التطوير باستخدام Flutter و Supabase'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  // Show logout confirmation dialog
  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(Get.context!).cardColor,
        title: Text('logout'.tr),
        content: Text('logout'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('logout'.tr),
          ),
        ],
      ),
    );
  }

  // Logout
  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Clean up all controllers before signing out
      _cleanupAllControllers();
      
      await _authService.signOut();
      
      Get.snackbar(
        'تم تسجيل الخروج',
        'تم تسجيل الخروج بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Navigate to auth page
      Get.offAllNamed(AppConstants.authRoute);
      
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في تسجيل الخروج: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clean up all controllers to prevent disposal issues
  void _cleanupAllControllers() {
    try {
      // Delete all controllers that might have TextEditingControllers
      if (Get.isRegistered<AuthController>()) {
        Get.delete<AuthController>(force: true);
      }
      if (Get.isRegistered<ProfileEditController>()) {
        Get.delete<ProfileEditController>(force: true);
      }
      if (Get.isRegistered<CreatePostController>()) {
        Get.delete<CreatePostController>(force: true);
      }
      if (Get.isRegistered<CommentsController>()) {
        Get.delete<CommentsController>(force: true);
      }
      if (Get.isRegistered<PostsController>()) {
        Get.delete<PostsController>(force: true);
      }
      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>(force: true);
      }
    } catch (e) {
      debugPrint('Error cleaning up controllers: $e');
    }
  }
}