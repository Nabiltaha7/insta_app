import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _buildSectionHeader('account'.tr),
            _buildAccountSection(controller),

            const SizedBox(height: 24),

            // Privacy section
            _buildSectionHeader('privacy'.tr),
            _buildPrivacySection(controller),

            const SizedBox(height: 24),

            // App settings section
            _buildSectionHeader('app_settings'.tr),
            _buildAppSettingsSection(controller),

            const SizedBox(height: 24),

            // Developer section
            _buildSectionHeader('developer'.tr),
            _buildDeveloperSection(controller),

            const SizedBox(height: 24),

            // Logout section
            _buildLogoutSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Get.theme.textTheme.headlineSmall?.color,
        ),
      ),
    );
  }

  Widget _buildAccountSection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('edit_profile'.tr),
            subtitle: Text('edit_profile'.tr),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Get.toNamed('/profile-edit'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('notifications'.tr),
            subtitle: Text('notifications'.tr),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Get.snackbar('قريباً', 'ستتوفر إعدادات الإشعارات قريباً');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      child: Obx(
        () => Column(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.lock),
              title: Text('private_account'.tr),
              subtitle: Text('private_account'.tr),
              value: controller.isPrivate.value,
              onChanged: (value) => controller.togglePrivateAccount(value),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.access_time),
              title: Text('show_last_seen'.tr),
              subtitle: Text('show_last_seen'.tr),
              value: controller.showLastSeen.value,
              onChanged: (value) => controller.toggleShowLastSeen(value),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.message),
              title: Text('allow_messages'.tr),
              subtitle: Text('allow_messages'.tr),
              value: controller.allowMessagesFromEveryone.value,
              onChanged: (value) => controller.toggleAllowMessages(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      child: Obx(
        () => Column(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: Text('dark_mode'.tr),
              subtitle: Text('dark_mode'.tr),
              value: controller.isDarkMode.value,
              onChanged: (value) => controller.toggleDarkMode(value),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text('language'.tr),
              subtitle: Text(
                controller.currentLanguage.value == 'ar'
                    ? 'العربية'
                    : 'English',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => controller.showLanguageDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperSection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: Text('about_app'.tr),
            subtitle: Text('about_app'.tr),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => controller.showAboutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
        subtitle: Text('logout'.tr),
        onTap: () => controller.showLogoutDialog(),
      ),
    );
  }
}
