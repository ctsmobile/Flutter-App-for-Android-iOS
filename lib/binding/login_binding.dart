import 'package:get/get.dart';
import 'package:red_plastering/controller/login_controller.dart';

class LoginScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<LoginScreenController>(
      () => LoginScreenController(),
    );
  }
}
