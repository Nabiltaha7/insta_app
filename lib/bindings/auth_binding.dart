import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put to ensure a fresh controller instance every time
    Get.put<AuthController>(AuthController(), permanent: false);
  }
}