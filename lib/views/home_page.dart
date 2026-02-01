import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../controllers/home_controller.dart';
import '../widgets/connectivity_widget.dart';
import 'feed_page.dart';
import 'create_post_page.dart';
import 'my_posts_page.dart';
import 'profile_edit_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());

    return ConnectivityWidget(
      child: Scaffold(
        body: Obx(() {
          // Use individual widgets instead of IndexedStack to properly dispose controllers
          switch (homeController.currentIndex.value) {
            case 0:
              return const FeedPage();
            case 1:
              return const CreatePostPage();
            case 2:
              return const MyPostsPage();
            case 3:
              return const ProfileEditPage();
            case 4:
              return const SettingsPage();
            default:
              return const FeedPage();
          }
        }),
        bottomNavigationBar: Obx(() => CurvedNavigationBar(
          index: homeController.currentIndex.value,
          onTap: homeController.changeTab,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.white,
          buttonBackgroundColor: Colors.blue,
          height: 65,
          animationDuration: const Duration(milliseconds: 300),
          animationCurve: Curves.easeInOut,
          items: [
            Icon(
              Icons.home_rounded,
              size: 28,
              color: homeController.currentIndex.value == 0 
                  ? Colors.white 
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade600),
            ),
            Icon(
              Icons.add_circle_rounded,
              size: 32,
              color: homeController.currentIndex.value == 1 
                  ? Colors.white 
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade600),
            ),
            Icon(
              Icons.grid_on_rounded,
              size: 28,
              color: homeController.currentIndex.value == 2 
                  ? Colors.white 
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade600),
            ),
            Icon(
              Icons.person_rounded,
              size: 28,
              color: homeController.currentIndex.value == 3 
                  ? Colors.white 
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade600),
            ),
            Icon(
              Icons.settings_rounded,
              size: 28,
              color: homeController.currentIndex.value == 4 
                  ? Colors.white 
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade600),
            ),
          ],
        )),
      ),
    );
  }
}