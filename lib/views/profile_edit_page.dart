import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/profile_edit_controller.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileEditPage extends GetView<ProfileEditController> {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    Get.put(ProfileEditController());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern AppBar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              'الملف الشخصي',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),
            actions: [
              Obx(
                () => Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : controller.saveProfile,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child:
                        controller.isLoading.value
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'حفظ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile image section
                  _buildProfileImageSection(controller),

                  const SizedBox(height: 32),

                  // Form fields
                  _buildFormFields(controller),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(ProfileEditController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'صورة الملف الشخصي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.textTheme.headlineMedium?.color,
                  ),
                ),

                const SizedBox(height: 20),

                // Profile image
                Obx(
                  () => GestureDetector(
                    onTap: controller.pickProfileImage,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                controller.selectedImage.value != null
                                    ? FileImage(controller.selectedImage.value!)
                                    : (controller.currentProfileImage.value !=
                                            null
                                        ? CachedNetworkImageProvider(
                                          controller.currentProfileImage.value!,
                                        )
                                        : null),
                            child:
                                controller.selectedImage.value == null &&
                                        controller.currentProfileImage.value ==
                                            null
                                    ? Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.blue, Colors.purple],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          controller.username.value.isNotEmpty
                                              ? controller.username.value[0]
                                                  .toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontSize: 40,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.purple],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'اضغط لتغيير الصورة',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(ProfileEditController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الحساب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Get.theme.textTheme.headlineMedium?.color,
            ),
          ),

          const SizedBox(height: 20),

          // Username
          _buildModernTextField(
            controller: controller.usernameController,
            label: 'اسم المستخدم',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'اسم المستخدم مطلوب';
              }
              if (value.length < 3) {
                return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Full name
          _buildModernTextField(
            controller: controller.fullNameController,
            label: 'الاسم الكامل',
            icon: Icons.badge_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الاسم الكامل مطلوب';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Bio
          _buildModernTextField(
            controller: controller.bioController,
            label: 'النبذة الشخصية',
            icon: Icons.info_outline,
            maxLines: 3,
            maxLength: 150,
          ),

          const SizedBox(height: 16),

          // Website
          _buildModernTextField(
            controller: controller.websiteController,
            label: 'الموقع الإلكتروني',
            icon: Icons.link,
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 16),

          // Phone number
          _buildModernTextField(
            controller: controller.phoneController,
            label: 'رقم الهاتف',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 20),

          // Gender
          _buildGenderSelector(controller),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          color: Get.theme.textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Get.theme.textTheme.bodyMedium?.color?.withValues(
              alpha: 0.7,
            ),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(ProfileEditController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الجنس',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Get.theme.textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedGender.value = 'male',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          controller.selectedGender.value == 'male'
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            controller.selectedGender.value == 'male'
                                ? Colors.blue
                                : Get.theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.male,
                          color:
                              controller.selectedGender.value == 'male'
                                  ? Colors.blue
                                  : Get.theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ذكر',
                          style: TextStyle(
                            color:
                                controller.selectedGender.value == 'male'
                                    ? Colors.blue
                                    : Get.theme.textTheme.bodyMedium?.color,
                            fontWeight:
                                controller.selectedGender.value == 'male'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedGender.value = 'female',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          controller.selectedGender.value == 'female'
                              ? Colors.pink.withValues(alpha: 0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            controller.selectedGender.value == 'female'
                                ? Colors.pink
                                : Get.theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.female,
                          color:
                              controller.selectedGender.value == 'female'
                                  ? Colors.pink
                                  : Get.theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'أنثى',
                          style: TextStyle(
                            color:
                                controller.selectedGender.value == 'female'
                                    ? Colors.pink
                                    : Get.theme.textTheme.bodyMedium?.color,
                            fontWeight:
                                controller.selectedGender.value == 'female'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
