import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta/controllers/posts_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../services/posts_service.dart';

class CreatePostController extends GetxController {
  late final PostsService _postsService;
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  // Form controllers
  final captionController = TextEditingController();
  final locationController = TextEditingController();
  final tagsController = TextEditingController();

  // Constants for file size limits
  static const int maxFileSizeInBytes = 1024 * 1024; // 1 MB
  static const double maxFileSizeInMB = 1.0;

  // Observable variables
  var selectedMedia = <File>[].obs;
  var mediaUrls = <String>[].obs;
  var isLoading = false.obs;
  var postType = 'text'.obs; // Only 'text', 'image', or 'carousel' (no video)

  @override
  void onInit() {
    super.onInit();

    // Initialize PostsService if not already initialized
    if (!Get.isRegistered<PostsService>()) {
      Get.put(PostsService());
    }
    _postsService = Get.find<PostsService>();
  }

  @override
  void onClose() {
    try {
      captionController.dispose();
      locationController.dispose();
      tagsController.dispose();
    } catch (e) {
      debugPrint('Error disposing CreatePostController controllers: $e');
    }
    super.onClose();
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
  void _showFileSizeError(String fileName, double fileSizeInMB) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.cardColor,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('حجم الملف كبير'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الملف: $fileName'),
            const SizedBox(height: 8),
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
                      'يرجى اختيار ملف أصغر لتوفير مساحة التخزين',
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

  // Pick images from gallery
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        List<File> validFiles = [];

        for (var image in images) {
          final file = File(image.path);

          // Check file size
          if (_isFileSizeValid(file)) {
            validFiles.add(file);
          } else {
            final fileSizeInMB = _getFileSizeInMB(file);
            final fileName = image.name.isNotEmpty ? image.name : 'صورة غير معروفة';
            _showFileSizeError(fileName, fileSizeInMB);
          }
        }

        if (validFiles.isNotEmpty) {
          selectedMedia.clear();
          selectedMedia.addAll(validFiles);
          postType.value = selectedMedia.length > 1 ? 'carousel' : 'image';

          Get.snackbar(
            'تم',
            'تم اختيار ${validFiles.length} صورة بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في اختيار الصور: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Take photo with camera
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final file = File(photo.path);

        // Check file size
        if (_isFileSizeValid(file)) {
          selectedMedia.clear();
          selectedMedia.add(file);
          postType.value = 'image';

          Get.snackbar(
            'تم',
            'تم التقاط الصورة بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          final fileSizeInMB = _getFileSizeInMB(file);
          final fileName = photo.name.isNotEmpty ? photo.name : 'صورة جديدة';

          _showFileSizeError(fileName, fileSizeInMB);
        }
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

  // Remove media at index
  void removeMedia(int index) {
    if (index >= 0 && index < selectedMedia.length) {
      selectedMedia.removeAt(index);
      if (selectedMedia.isEmpty) {
        postType.value = 'text';
      } else if (selectedMedia.length == 1) {
        postType.value = 'image';
      }
    }
  }

  // Upload media files to Supabase Storage
  Future<List<String>> _uploadMediaFiles() async {
    List<String> urls = [];

    try {
      for (int i = 0; i < selectedMedia.length; i++) {
        final file = selectedMedia[i];
        final fileName =
            'posts/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        // Upload to Supabase Storage
        await supabase.storage
            .from('media')
            .uploadBinary(fileName, await file.readAsBytes());

        // Get public URL
        final publicUrl = supabase.storage.from('media').getPublicUrl(fileName);

        urls.add(publicUrl);
      }

      return urls;
    } catch (error) {
      // If upload fails, show error but don't block post creation
      Get.snackbar(
        'تحذير',
        'فشل في رفع الصور، سيتم استخدام صور تجريبية',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      // Fallback to placeholder URLs
      List<String> fallbackUrls = [];
      for (int i = 0; i < selectedMedia.length; i++) {
        fallbackUrls.add(
          'https://via.placeholder.com/400x400.png?text=Image+$i',
        );
      }
      return fallbackUrls;
    }
  }

  // Parse tags from text
  List<String> _parseTags(String tagsText) {
    if (tagsText.trim().isEmpty) return [];

    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  // Create post
  Future<void> createPost() async {
    if (captionController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى كتابة وصف للمنشور',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Final check for file sizes before uploading
    if (selectedMedia.isNotEmpty) {
      List<File> invalidFiles = [];
      for (var file in selectedMedia) {
        if (!_isFileSizeValid(file)) {
          invalidFiles.add(file);
        }
      }

      if (invalidFiles.isNotEmpty) {
        Get.snackbar(
          'خطأ',
          'يوجد ${invalidFiles.length} ملف أكبر من ${maxFileSizeInMB.toStringAsFixed(1)} ميجابايت. يرجى إزالتها أولاً.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    try {
      isLoading.value = true;

      // Upload media files if any are selected
      List<String> uploadedUrls = [];
      if (selectedMedia.isNotEmpty) {
        uploadedUrls = await _uploadMediaFiles();
      }

      // Parse tags
      final tags = _parseTags(tagsController.text);

      // Create post
      await _postsService.createPost(
        caption: captionController.text.trim(),
        mediaUrls: uploadedUrls,
        type: selectedMedia.isEmpty ? 'text' : postType.value,
        tags: tags,
        location:
            locationController.text.trim().isEmpty
                ? null
                : locationController.text.trim(),
      );

      // Clear form
      clearForm();

      Get.snackbar(
        'success'.tr,
        'تم نشر المنشور بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back to home and refresh posts
      Get.back(); // Go back to previous page

      // Refresh posts in the main controller
      try {
        final postsController = Get.find<PostsController>();
        postsController.refreshPosts();
      } catch (e) {
        // PostsController might not be initialized
      }
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في نشر المنشور: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void clearForm() {
    captionController.clear();
    locationController.clear();
    tagsController.clear();
    selectedMedia.clear();
    mediaUrls.clear();
    postType.value = 'text';
  }

  // Show media picker options
  void showMediaPicker() {
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
              'اختر نوع المحتوى',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('صور من المعرض'),
              onTap: () {
                Get.back();
                pickImages();
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
          ],
        ),
      ),
    );
  }
}
