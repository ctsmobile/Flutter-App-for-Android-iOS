import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddMessageScreenController extends GetxController {
  var now = DateTime.now().obs;
  var formatter = DateFormat.yMMMMd();
  var formattedDate = "".obs;
  var textMessage = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    formattedDate.value = formatter.format(now.value);
  }

  removeSelection() {
    return FirebaseFirestore.instance
        .collection("UserListing")
        .where('isSelected', isEqualTo: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("UserListing")
            .doc(element.get('id'))
            .update({'isSelected': false});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
