import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';
import 'translations/app_translations.dart';
import 'constants/app_constants.dart';
import 'services/storage_service.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize StorageService early
  final storageService = await StorageService().init();
  Get.put(storageService);

  // Initialize ConnectivityService
  Get.put(ConnectivityService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get storage service and apply saved settings
    final storageService = Get.find<StorageService>();

    // Determine initial route based on auth state
    final user = Supabase.instance.client.auth.currentUser;
    final initialRoute =
        user != null ? AppConstants.homeRoute : AppConstants.authRoute;

    // Listen to auth state changes globally
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedOut) {
        // User signed out, navigation will be handled by AuthService
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        // Token refreshed successfully
        debugPrint('Auth token refreshed');
      }
    });

    return GetMaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey.shade900,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade400,
        ),
        cardTheme: CardTheme(color: Colors.grey.shade800),
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: storageService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      translations: AppTranslations(),
      locale: Locale(storageService.language),
      fallbackLocale: const Locale('ar'),
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
