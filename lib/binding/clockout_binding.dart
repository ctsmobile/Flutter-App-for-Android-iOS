import 'package:get/get.dart';
import 'package:red_plastering/controller/clockout_controller.dart';

class ClockOutScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<ClockOutScreenController>(
      () => ClockOutScreenController(),
    );
  }
}
