// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart' as dio;
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:red_plastering/models/chatMessageModel.dart';
import 'package:red_plastering/models/grpChatMessageModel.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:red_plastering/network/dioClient.dart';

class ConversationScreenController extends GetxController {
  var sendMsgController = TextEditingController().obs;
  var currentUserId = "".obs;
  var currentUserPhoto = "".obs;
  var peerId = Get.parameters['peerId'];
  var peerName = Get.parameters['peerName'];
  var peerFcmToken = Get.parameters['peerFcmToken'];
  var grpName = Get.parameters['grpName'];
  var peerIdList = [].obs;
  var listOfIds = <Id>[].obs;
  DocumentReference<Map<String, dynamic>>? documentReferenceCurrentUser;
  final grpChatMessages = GroupChatMessageModel().obs;
  // var groupChatId = "".obs;
  var uuid = "".obs;
  // var idTo = "".obs;
  // var idToGet = "".obs;
  var valueGot = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentUserId.value = FirebaseAuth.instance.currentUser!.uid;
    currentUserPhoto.value =
        FirebaseAuth.instance.currentUser!.email![0].toString();
    // if (currentUserId.value.compareTo(peerId.toString()) > 0) {
    //   groupChatId.value = '${currentUserId.value} - ${peerId.toString()}';
    //   GetStorage().write('groupChat', groupChatId.value);
    // } else {
    //   groupChatId.value = '${peerId.toString()} - ${currentUserId.value}';
    //   GetStorage().write('groupChat', groupChatId.value);
    // }
    // print("GROUPDCHATID,${groupChatId.value}");
    print("CURRENTID,${currentUserId.value}");
    print("CURRENTIDHASHCODE,${currentUserId.value.hashCode}");
    print("PEERIDHASHCODE,${peerId.hashCode}");
    // getChatMessage();
    print(
        "EMPLOYEE FIRST NAME,${GetStorage().read('employeeName')[0].toString()}");
    if (grpName != null) {
      getGroupData();
    } else {
      getData();
    }
  }

  sendNotificationMessage(
      String peerFcmToken, String peerName, String message) async {}

  Stream<QuerySnapshot>? getGroupData() {}

  Stream<QuerySnapshot>? getData() {}

  Stream<QuerySnapshot>? getChatMessage() {}

  Stream<QuerySnapshot>? getGrpChatMessage() {}

  sendMsg(String content, int type) {}

  sendGrpMsg(String content, int type) {}

  @override
  void dispose() {
    super.dispose();
  }
}
