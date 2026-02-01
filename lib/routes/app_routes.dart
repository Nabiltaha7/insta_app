import 'package:get/get.dart';
import '../views/auth_page.dart';
import '../views/home_page.dart';
import '../views/create_post_page.dart';
import '../views/comments_page.dart';
import '../views/profile_edit_page.dart';
import '../views/settings_page.dart';
import '../views/user_profile_page.dart';
import '../views/my_posts_page.dart';
import '../middleware/auth_middleware.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../controllers/user_profile_controller.dart';
import '../controllers/my_posts_controller.dart';
import '../constants/app_constants.dart';

class AppRoutes {
  static const String auth = AppConstants.authRoute;
  static const String home = AppConstants.homeRoute;
  static const String createPost = '/create-post';
  static const String comments = '/comments';
  static const String profileEdit = '/profile-edit';
  static const String settings = '/settings';
  static const String userProfile = '/user-profile';
  static const String myPosts = '/my-posts';

  static List<GetPage> routes = [
    GetPage(
      name: auth,
      page: () => const AuthPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
      binding: HomeBinding(),
    ),
    GetPage(
      name: createPost,
      page: () => const CreatePostPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: comments,
      page: () => const CommentsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: profileEdit,
      page: () => const ProfileEditPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: userProfile,
      page: () => const UserProfilePage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        final String userId = Get.arguments as String;
        Get.put(UserProfileController(userId));
      }),
    ),
    GetPage(
      name: myPosts,
      page: () => const MyPostsPage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.put(MyPostsController());
      }),
    ),
  ];
}