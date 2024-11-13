import 'package:get/get.dart';
import 'package:red_plastering/controller/conversation_controller.dart';

class ConversationScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<ConversationScreenController>(
      () => ConversationScreenController(),
    );
  }
}
