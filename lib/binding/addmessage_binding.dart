import 'package:get/get.dart';
import 'package:red_plastering/controller/addmessage_controller.dart';

class AddMessageScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<AddMessageScreenController>(
      () => AddMessageScreenController(),
    );
  }
}
