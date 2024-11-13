import 'package:get/get.dart';
import 'package:red_plastering/controller/contactslist_controller.dart';

class ContactsListScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<ContactsListScreenController>(
      () => ContactsListScreenController(),
    );
  }
}
