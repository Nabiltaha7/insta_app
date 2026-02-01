import 'package:email_validator/email_validator.dart';
import '../constants/app_constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!EmailValidator.validate(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن تكون ${AppConstants.minPasswordLength} أحرف على الأقل';
    }
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال اسم المستخدم';
    }
    if (value.length < AppConstants.minUsernameLength) {
      return 'اسم المستخدم يجب أن يكون ${AppConstants.minUsernameLength} أحرف على الأقل';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'اسم المستخدم يجب أن يحتوي على أحرف وأرقام فقط';
    }
    return null;
  }

  // Full name validation
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الاسم الكامل';
    }
    if (value.length < AppConstants.minFullNameLength) {
      return 'الاسم يجب أن يكون ${AppConstants.minFullNameLength} حرفين على الأقل';
    }
    return null;
  }
}