import 'package:get/get.dart';
import 'package:red_plastering/controller/chat_controller.dart';

class ChatScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<ChatScreenController>(
      () => ChatScreenController(),
    );
  }
}
