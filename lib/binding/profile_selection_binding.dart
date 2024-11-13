import 'package:get/get.dart';
import 'package:red_plastering/controller/profile_selection_controller.dart';

class ProfileSelectionScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<ProfileSelectionScreenController>(
      () => ProfileSelectionScreenController(),
    );
  }
}
