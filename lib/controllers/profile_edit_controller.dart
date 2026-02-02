import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../constants/app_constants.dart';

class ProfileEditController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  // Form controllers
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final bioController = TextEditingController();
  final websiteController = TextEditingController();
  final phoneController = TextEditingController();

  // Constants for file size limits
  static const int maxFileSizeInBytes = 1024 * 1024; // 1 MB
  static const double maxFileSizeInMB = 1.0;

  // Observable variables
  var selectedImage = Rxn<File>();
  var currentProfileImage = RxnString();
  var username = ''.obs;
  var selectedGender = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserData();
  }

  @override
  void onClose() {
    try {
      usernameController.dispose();
      fullNameController.dispose();
      bioController.dispose();
      websiteController.dispose();
      phoneController.dispose();
    } catch (e) {
      debugPrint('Error disposing ProfileEditController controllers: $e');
    }
    super.onClose();
  }

  // Load current user data
  Future<void> loadCurrentUserData() async {
    try {
      isLoading.value = true;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      final userData =
          await supabase
              .from(AppConstants.usersTable)
              .select('*')
              .eq('id', currentUser.id)
              .single();

      // Fill form with current data
      usernameController.text = userData['username'] ?? '';
      fullNameController.text = userData['full_name'] ?? '';
      bioController.text = userData['bio'] ?? '';
      websiteController.text = userData['website'] ?? '';
      phoneController.text = userData['phone_number'] ?? '';

      username.value = userData['username'] ?? '';
      currentProfileImage.value = userData['profile_image_url'];
      selectedGender.value = userData['gender'] ?? '';
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل بيانات المستخدم: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check file size
  bool _isFileSizeValid(File file) {
    try {
      final fileSizeInBytes = file.lengthSync();
      return fileSizeInBytes <= maxFileSizeInBytes;
    } catch (e) {
      debugPrint('Error checking file size: $e');
      return false;
    }
  }

  // Get file size in MB
  double _getFileSizeInMB(File file) {
    try {
      final fileSizeInBytes = file.lengthSync();
      return fileSizeInBytes / (1024 * 1024);
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0.0;
    }
  }

  // Show file size error
  void _showFileSizeError(double fileSizeInMB) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.cardColor,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('حجم الصورة كبير'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحجم الحالي: ${fileSizeInMB.toStringAsFixed(2)} ميجابايت'),
            const SizedBox(height: 8),
            Text(
              'الحد الأقصى المسموح: ${maxFileSizeInMB.toStringAsFixed(1)} ميجابايت',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يرجى اختيار صورة أصغر لتوفير مساحة التخزين',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('موافق')),
        ],
      ),
    );
  }

  // Pick profile image
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);

        // Check file size
        if (_isFileSizeValid(file)) {
          selectedImage.value = file;
          Get.snackbar(
            'تم',
            'تم اختيار الصورة بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          final fileSizeInMB = _getFileSizeInMB(file);
          _showFileSizeError(fileSizeInMB);
        }
      }
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في اختيار الصورة: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Upload profile image to Supabase Storage
  Future<String?> _uploadProfileImage() async {
    if (selectedImage.value == null) return null;

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return null;

      final fileName =
          'profiles/${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase Storage
      await supabase.storage
          .from('media')
          .uploadBinary(fileName, await selectedImage.value!.readAsBytes());

      // Get public URL
      final publicUrl = supabase.storage.from('media').getPublicUrl(fileName);

      return publicUrl;
    } catch (error) {
      Get.snackbar(
        'تحذير',
        'فشل في رفع الصورة، سيتم حفظ البيانات الأخرى',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Check if username is available
  Future<bool> _isUsernameAvailable(String username) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return false;

      final existingUser =
          await supabase
              .from(AppConstants.usersTable)
              .select('id')
              .eq('username', username)
              .neq('id', currentUser.id) // Exclude current user
              .maybeSingle();

      return existingUser == null;
    } catch (error) {
      return false;
    }
  }

  // Save profile
  Future<void> saveProfile() async {
    // Validate required fields
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'اسم المستخدم مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'الاسم الكامل مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check username availability
    if (usernameController.text.trim() != username.value) {
      final isAvailable = await _isUsernameAvailable(
        usernameController.text.trim(),
      );
      if (!isAvailable) {
        Get.snackbar(
          'خطأ',
          'اسم المستخدم غير متاح',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    try {
      isLoading.value = true;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      // Upload profile image if selected
      String? profileImageUrl;
      if (selectedImage.value != null) {
        profileImageUrl = await _uploadProfileImage();
      }

      // Prepare update data
      final updateData = {
        'username': usernameController.text.trim(),
        'full_name': fullNameController.text.trim(),
        'bio': bioController.text.trim(),
        'website': websiteController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'gender': selectedGender.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add profile image URL if uploaded
      if (profileImageUrl != null) {
        updateData['profile_image_url'] = profileImageUrl;
      }

      // Update user data
      await supabase
          .from(AppConstants.usersTable)
          .update(updateData)
          .eq('id', currentUser.id);

      // Update posts with new profile data if username or image changed
      if (usernameController.text.trim() != username.value ||
          profileImageUrl != null) {
        await _updateUserPostsData(
          currentUser.id,
          usernameController.text.trim(),
          profileImageUrl ?? currentProfileImage.value,
        );
      }

      Get.snackbar(
        'تم الحفظ',
        'تم حفظ التغييرات بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Update local data
      username.value = usernameController.text.trim();
      if (profileImageUrl != null) {
        currentProfileImage.value = profileImageUrl;
      }
      selectedImage.value = null;

      // Go back
      Get.back();
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في حفظ التغييرات: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update user data in all posts (for consistency)
  Future<void> _updateUserPostsData(
    String userId,
    String newUsername,
    String? newProfileImage,
  ) async {
    try {
      final updateData = {
        'username': newUsername,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (newProfileImage != null) {
        updateData['user_profile_image'] = newProfileImage;
      }

      // Update posts table
      await supabase.from('posts').update(updateData).eq('user_id', userId);

      // Update comments table
      await supabase.from('comments').update(updateData).eq('user_id', userId);
    } catch (error) {
      // Ignore errors in updating posts data
      debugPrint('Failed to update posts data: $error');
    }
  }

  // Take photo with camera
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (photo != null) {
        selectedImage.value = File(photo.path);
      }
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في التقاط الصورة: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Show image picker options
  void showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر صورة الملف الشخصي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('من المعرض'),
              onTap: () {
                Get.back();
                pickProfileImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () {
                Get.back();
                takePhoto();
              },
            ),
            if (currentProfileImage.value != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'حذف الصورة',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  _removeProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  // Remove profile image
  void _removeProfileImage() {
    selectedImage.value = null;
    currentProfileImage.value = null;
  }
}
