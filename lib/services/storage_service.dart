import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class StorageService extends GetxController {
  static StorageService get to => Get.find();
  SharedPreferences? _prefs;

  // Keys for storage
  static const String _isDarkModeKey = 'isDarkMode';
  static const String _languageKey = 'language';
  static const String _isFirstLaunchKey = 'isFirstLaunch';

  Future<StorageService> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      return this;
    } catch (e) {
      // If SharedPreferences fails, continue with defaults
      return this;
    }
  }

  // Dark mode settings
  bool get isDarkMode => _prefs?.getBool(_isDarkModeKey) ?? true; // افتراضي ليلي
  
  Future<void> setDarkMode(bool value) async {
    try {
      await _prefs?.setBool(_isDarkModeKey, value);
      update(); // Notify listeners
    } catch (e) {
      // Handle error silently
    }
  }

  // Language settings
  String get language => _prefs?.getString(_languageKey) ?? 'ar';
  
  Future<void> setLanguage(String value) async {
    try {
      await _prefs?.setString(_languageKey, value);
      update(); // Notify listeners
    } catch (e) {
      // Handle error silently
    }
  }

  // First launch check
  bool get isFirstLaunch => _prefs?.getBool(_isFirstLaunchKey) ?? true;
  
  Future<void> setFirstLaunch(bool value) async {
    try {
      await _prefs?.setBool(_isFirstLaunchKey, value);
    } catch (e) {
      // Handle error silently
    }
  }

  // Apply saved theme and language
  void applySavedSettings() {
    try {
      // Apply theme
      final savedDarkMode = isDarkMode;
      Get.changeThemeMode(savedDarkMode ? ThemeMode.dark : ThemeMode.light);
      
      // Apply language
      final savedLanguage = language;
      Get.updateLocale(Locale(savedLanguage));
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear all settings (for logout or reset)
  Future<void> clearAll() async {
    try {
      await _prefs?.clear();
      update(); // Notify listeners
    } catch (e) {
      // Handle error silently
    }
  }
}