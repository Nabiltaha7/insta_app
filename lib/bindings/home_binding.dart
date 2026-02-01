import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/posts_controller.dart';
import '../controllers/my_posts_controller.dart';
import '../services/posts_service.dart';
import '../services/user_profile_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostsService>(() => PostsService());
    Get.lazyPut<UserProfileService>(() => UserProfileService());
    Get.lazyPut<PostsController>(() => PostsController());
    Get.lazyPut<MyPostsController>(() => MyPostsController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}