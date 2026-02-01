import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  // Get current tab name for debugging
  String get currentTabName {
    switch (currentIndex.value) {
      case 0:
        return 'Feed';
      case 1:
        return 'Create Post';
      case 2:
        return 'My Posts';
      case 3:
        return 'Profile';
      case 4:
        return 'Settings';
      default:
        return 'Unknown';
    }
  }
}