import 'package:get/get.dart';
import 'package:red_plastering/controller/clockin_controller.dart';

class ClockInScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<ClockInScreenController>(
      () => ClockInScreenController(),
    );
  }
}
