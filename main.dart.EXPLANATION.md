# شرح ملف main.dart

## الوظيفة الأساسية
هذا هو الملف الرئيسي للتطبيق - نقطة البداية التي يتم تشغيلها عند فتح التطبيق.

## المحتوى والوظائف

### 1. دالة main()
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  // تهيئة الخدمات
  final storageService = await StorageService().init();
  Get.put(storageService);
  Get.put(ConnectivityService());
  
  runApp(const MyApp());
}
```

**الوظائف:**
- `WidgetsFlutterBinding.ensureInitialized()`: تهيئة Flutter قبل تشغيل العمليات غير المتزامنة
- `Supabase.initialize()`: ربط التطبيق بقاعدة البيانات Supabase
- تهيئة الخدمات الأساسية (التخزين المحلي ومراقبة الاتصال)
- `runApp()`: تشغيل التطبيق

### 2. فئة MyApp
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // تحديد المسار الأولي حسب حالة المصادقة
    final user = Supabase.instance.client.auth.currentUser;
    final initialRoute = user != null ? AppConstants.homeRoute : AppConstants.authRoute;
    
    return GetMaterialApp(
      // إعدادات التطبيق
    );
  }
}
```

**الوظائف:**
- تحديد المسار الأولي (صفحة تسجيل الدخول أو الصفحة الرئيسية)
- إعداد الثيمات (فاتح/داكن)
- إعداد اللغات والترجمة
- ربط المسارات والصفحات

## الأدوات والمكتبات المستخدمة

### 1. GetX Framework
- **GetMaterialApp**: بديل لـ MaterialApp مع ميزات GetX
- **Get.put()**: حقن التبعيات في الذاكرة
- **إدارة المسارات**: التنقل بين الصفحات

### 2. Supabase
- **Supabase.initialize()**: تهيئة الاتصال بقاعدة البيانات
- **auth.currentUser**: فحص حالة المصادقة الحالية
- **onAuthStateChange**: مراقبة تغييرات المصادقة

### 3. الخدمات المخصصة
- **StorageService**: إدارة التخزين المحلي (الإعدادات، اللغة، الثيم)
- **ConnectivityService**: مراقبة حالة الاتصال بالإنترنت

## الترابطات مع الملفات الأخرى

### الاستيرادات
```dart
import 'routes/app_routes.dart';           // مسارات التطبيق
import 'translations/app_translations.dart'; // ترجمات التطبيق
import 'constants/app_constants.dart';      // الثوابت
import 'services/storage_service.dart';     // خدمة التخزين
import 'services/connectivity_service.dart'; // خدمة الاتصال
```

### التفاعل مع الملفات
1. **app_constants.dart**: يستخدم الثوابت لإعداد Supabase والمسارات
2. **app_routes.dart**: يحدد جميع مسارات التطبيق
3. **app_translations.dart**: يوفر الترجمات للغات المختلفة
4. **storage_service.dart**: يحفظ ويسترجع إعدادات المستخدم
5. **connectivity_service.dart**: يراقب حالة الاتصال

## الميزات المهمة

### 1. إدارة الثيمات
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
),
darkTheme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
),
themeMode: storageService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
```

### 2. دعم اللغات المتعددة
```dart
translations: AppTranslations(),
locale: Locale(storageService.language),
fallbackLocale: const Locale('ar'),
```

### 3. مراقبة حالة المصادقة
```dart
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  if (event == AuthChangeEvent.signedOut) {
    // معالجة تسجيل الخروج
  } else if (event == AuthChangeEvent.tokenRefreshed) {
    // معالجة تحديث الرمز المميز
  }
});
```

## نصائح للتطوير

### 1. إضافة خدمة جديدة
```dart
// في main()
Get.put(NewService());
```

### 2. تغيير المسار الأولي
```dart
final initialRoute = someCondition ? '/new-route' : AppConstants.authRoute;
```

### 3. إضافة إعدادات جديدة للثيم
```dart
theme: ThemeData(
  // إعدادات جديدة
),
```

## الأخطاء الشائعة وحلولها

### 1. خطأ تهيئة Supabase
**المشكلة**: عدم تهيئة Supabase بشكل صحيح
**الحل**: التأكد من صحة URL و API Key في app_constants.dart

### 2. خطأ الخدمات
**المشكلة**: عدم تهيئة الخدمات قبل استخدامها
**الحل**: التأكد من استخدام `await` عند تهيئة الخدمات

### 3. مشاكل المسارات
**المشكلة**: عدم وجود مسار محدد
**الحل**: التأكد من تعريف جميع المسارات في app_routes.dart

## الخلاصة
ملف main.dart هو قلب التطبيق الذي يربط جميع المكونات معاً ويضمن تشغيل التطبيق بشكل صحيح مع جميع الخدمات والإعدادات المطلوبة.