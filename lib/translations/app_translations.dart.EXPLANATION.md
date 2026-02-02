# شرح ملف lib/translations/app_translations.dart

## الوظيفة الأساسية
ملف إدارة الترجمات في التطبيق - يوفر دعماً للغتين العربية والإنجليزية لجميع النصوص المستخدمة في التطبيق.

## هيكل الفئة
```dart
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar': {
      // الترجمات العربية
    },
    'en': {
      // الترجمات الإنجليزية
    },
  };
}
```

**الميزات:**
- **وراثة من Translations**: فئة GetX للترجمات
- **خريطة متداخلة**: لغة → مفتاح → نص
- **دعم لغتين**: العربية والإنجليزية

## تصنيف الترجمات

### 1. التنقل (Navigation)
```dart
// العربية
'home': 'الرئيسية',
'create': 'إنشاء',
'profile': 'الملف الشخصي',
'settings': 'الإعدادات',

// الإنجليزية
'home': 'Home',
'create': 'Create',
'profile': 'Profile',
'settings': 'Settings',
```

**الاستخدام:**
- شريط التنقل السفلي
- قوائم التطبيق
- عناوين الصفحات

### 2. المصادقة (Authentication)
```dart
// العربية
'login': 'تسجيل الدخول',
'signup': 'إنشاء حساب',
'username': 'اسم المستخدم',
'password': 'كلمة المرور',
'email': 'البريد الإلكتروني',
'full_name': 'الاسم الكامل',

// الإنجليزية
'login': 'Login',
'signup': 'Sign Up',
'username': 'Username',
'password': 'Password',
'email': 'Email',
'full_name': 'Full Name',
```

**الاستخدام:**
- صفحة تسجيل الدخول
- نماذج إنشاء الحساب
- رسائل المصادقة

### 3. المنشورات (Posts)
```dart
// العربية
'posts': 'المنشورات',
'followers': 'المتابعون',
'following': 'يتابع',
'like': 'إعجاب',
'comment': 'تعليق',
'share': 'مشاركة',
'view_all_comments': 'عرض جميع التعليقات',

// الإنجليزية
'posts': 'Posts',
'followers': 'Followers',
'following': 'Following',
'like': 'Like',
'comment': 'Comment',
'share': 'Share',
'view_all_comments': 'View all comments',
```

**الاستخدام:**
- PostCard widget
- صفحة التعليقات
- إحصائيات المستخدم

### 4. الإعدادات (Settings)
```dart
// العربية
'account': 'الحساب',
'privacy': 'الخصوصية',
'app_settings': 'إعدادات التطبيق',
'dark_mode': 'الوضع الليلي',
'language': 'اللغة',
'logout': 'تسجيل الخروج',

// الإنجليزية
'account': 'Account',
'privacy': 'Privacy',
'app_settings': 'App Settings',
'dark_mode': 'Dark Mode',
'language': 'Language',
'logout': 'Logout',
```

**الاستخدام:**
- صفحة الإعدادات
- قوائم الخيارات
- إعدادات الخصوصية

### 5. الرسائل العامة (General Messages)
```dart
// العربية
'success': 'نجح',
'error': 'خطأ',
'loading': 'جاري التحميل...',
'save': 'حفظ',
'cancel': 'إلغاء',
'delete': 'حذف',
'edit': 'تعديل',

// الإنجليزية
'success': 'Success',
'error': 'Error',
'loading': 'Loading...',
'save': 'Save',
'cancel': 'Cancel',
'delete': 'Delete',
'edit': 'Edit',
```

**الاستخدام:**
- رسائل النجاح والخطأ
- أزرار الحفظ والإلغاء
- مؤشرات التحميل

### 6. الملف الشخصي (Profile)
```dart
// العربية
'bio': 'النبذة الشخصية',
'website': 'الموقع الإلكتروني',
'phone': 'رقم الهاتف',
'gender': 'الجنس',
'male': 'ذكر',
'female': 'أنثى',
'edit_profile': 'تعديل الملف الشخصي',

// الإنجليزية
'bio': 'Bio',
'website': 'Website',
'phone': 'Phone',
'gender': 'Gender',
'male': 'Male',
'female': 'Female',
'edit_profile': 'Edit Profile',
```

**الاستخدام:**
- صفحة الملف الشخصي
- نموذج تعديل الملف
- معلومات المستخدم

### 7. إنشاء المنشورات (Create Post)
```dart
// العربية
'new_post': 'منشور جديد',
'caption': 'الوصف',
'location': 'المكان',
'tags': 'العلامات',
'publish': 'نشر',
'add_photos': 'إضافة صور',

// الإنجليزية
'new_post': 'New Post',
'caption': 'Caption',
'location': 'Location',
'tags': 'Tags',
'publish': 'Publish',
'add_photos': 'Add Photos',
```

**الاستخدام:**
- صفحة إنشاء المنشور
- نماذج الإدخال
- أزرار الإجراءات

### 8. الإشعارات (Notifications)
```dart
// العربية
'no_notifications': 'لا توجد إشعارات',
'notifications_will_appear_here': 'ستظهر الإشعارات هنا',
'mark_all_read': 'وضع علامة مقروء على الكل',
'delete_all_notifications': 'حذف جميع الإشعارات',

// الإنجليزية
'no_notifications': 'No notifications',
'notifications_will_appear_here': 'Notifications will appear here',
'mark_all_read': 'Mark all as read',
'delete_all_notifications': 'Delete all notifications',
```

**الاستخدام:**
- صفحة الإشعارات
- رسائل الحالة الفارغة
- إجراءات الإشعارات

## الاستخدام في التطبيق

### 1. في الواجهات
```dart
Text('home'.tr)  // سيعرض "الرئيسية" أو "Home" حسب اللغة
```

### 2. في الرسائل
```dart
Get.snackbar(
  'success'.tr,
  'تم الحفظ بنجاح',
  backgroundColor: Colors.green,
)
```

### 3. في النماذج
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'username'.tr,
    hintText: 'أدخل اسم المستخدم',
  ),
)
```

### 4. في الأزرار
```dart
ElevatedButton(
  onPressed: () => save(),
  child: Text('save'.tr),
)
```

## إعداد الترجمات في التطبيق

### 1. في main.dart
```dart
GetMaterialApp(
  translations: AppTranslations(),
  locale: Locale(storageService.language),
  fallbackLocale: const Locale('ar'),
  // باقي الإعدادات
)
```

### 2. تغيير اللغة
```dart
// تغيير إلى العربية
Get.updateLocale(const Locale('ar'));

// تغيير إلى الإنجليزية
Get.updateLocale(const Locale('en'));
```

### 3. الحصول على اللغة الحالية
```dart
String currentLanguage = Get.locale?.languageCode ?? 'ar';
```

## إدارة النصوص المعقدة

### 1. النصوص مع متغيرات
```dart
// في الترجمات
'welcome_user': 'مرحباً @username',

// في الاستخدام
Text('welcome_user'.tr.replaceAll('@username', user.name))
```

### 2. النصوص الطويلة
```dart
// العربية
'terms_and_conditions': '''
شروط وأحكام الاستخدام
1. يجب على المستخدم...
2. لا يحق للمستخدم...
''',

// الإنجليزية
'terms_and_conditions': '''
Terms and Conditions
1. User must...
2. User may not...
''',
```

### 3. النصوص الشرطية
```dart
// العربية
'posts_count': 'منشور واحد',
'posts_count_plural': '@count منشورات',

// في الاستخدام
String getPostsText(int count) {
  if (count == 1) {
    return 'posts_count'.tr;
  } else {
    return 'posts_count_plural'.tr.replaceAll('@count', count.toString());
  }
}
```

## أفضل الممارسات

### 1. تسمية المفاتيح
```dart
// جيد - وصفي ومنظم
'profile_edit_save_button': 'حفظ التغييرات',
'post_like_count': '@count إعجاب',

// سيء - غير واضح
'btn1': 'حفظ',
'text': 'إعجاب',
```

### 2. تجميع المفاتيح
```dart
// تجميع حسب الصفحة أو الوظيفة
// Auth related
'auth_login': 'تسجيل الدخول',
'auth_signup': 'إنشاء حساب',

// Profile related
'profile_edit': 'تعديل الملف',
'profile_bio': 'النبذة الشخصية',
```

### 3. التعامل مع النصوص المفقودة
```dart
// استخدام fallback locale
fallbackLocale: const Locale('ar'),

// أو التحقق من وجود الترجمة
String getText(String key) {
  return key.tr != key ? key.tr : 'نص غير متوفر';
}
```

## إضافة لغة جديدة

### 1. إضافة اللغة للخريطة
```dart
Map<String, Map<String, String>> get keys => {
  'ar': { /* الترجمات العربية */ },
  'en': { /* الترجمات الإنجليزية */ },
  'fr': { /* الترجمات الفرنسية */ },
};
```

### 2. ترجمة جميع المفاتيح
```dart
'fr': {
  'home': 'Accueil',
  'create': 'Créer',
  'profile': 'Profil',
  'settings': 'Paramètres',
  // باقي الترجمات
},
```

### 3. إضافة خيار اللغة في الإعدادات
```dart
List<String> supportedLanguages = ['ar', 'en', 'fr'];
```

## الاختبار والتحقق

### 1. التحقق من اكتمال الترجمات
```dart
void validateTranslations() {
  final arKeys = keys['ar']!.keys.toSet();
  final enKeys = keys['en']!.keys.toSet();
  
  final missingInAr = enKeys.difference(arKeys);
  final missingInEn = arKeys.difference(enKeys);
  
  if (missingInAr.isNotEmpty) {
    print('Missing in Arabic: $missingInAr');
  }
  if (missingInEn.isNotEmpty) {
    print('Missing in English: $missingInEn');
  }
}
```

### 2. اختبار تغيير اللغة
```dart
void testLanguageSwitch() {
  // تغيير للعربية
  Get.updateLocale(const Locale('ar'));
  assert('home'.tr == 'الرئيسية');
  
  // تغيير للإنجليزية
  Get.updateLocale(const Locale('en'));
  assert('home'.tr == 'Home');
}
```

## التحسينات المقترحة

### 1. تحميل الترجمات من ملفات خارجية
```dart
// تحميل من JSON
Future<Map<String, String>> loadTranslations(String language) async {
  final jsonString = await rootBundle.loadString('assets/translations/$language.json');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  return jsonMap.cast<String, String>();
}
```

### 2. ترجمات ديناميكية من الخادم
```dart
// تحميل من API
Future<void> loadRemoteTranslations() async {
  final response = await http.get(Uri.parse('/api/translations/ar'));
  final translations = json.decode(response.body);
  // تحديث الترجمات
}
```

### 3. دعم RTL/LTR
```dart
bool get isRTL => Get.locale?.languageCode == 'ar';

Widget build(BuildContext context) {
  return Directionality(
    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
    child: child,
  );
}
```

## الترابطات مع الملفات الأخرى

### 1. الاستيرادات
```dart
import 'package:get/get.dart'; // GetX Translations
```

### 2. الملفات المستخدمة
- **main.dart**: تهيئة الترجمات
- **جميع الواجهات**: استخدام النصوص المترجمة
- **storage_service.dart**: حفظ اللغة المختارة

### 3. الاستخدام في Controllers
```dart
Get.snackbar(
  'success'.tr,
  'تم الحفظ بنجاح',
);
```

## الخلاصة
ملف AppTranslations يوفر نظاماً شاملاً لدعم اللغات المتعددة في التطبيق. يغطي جميع النصوص المستخدمة مع تنظيم منطقي وسهولة في الإدارة والتوسع.