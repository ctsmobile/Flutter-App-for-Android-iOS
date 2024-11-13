// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:red_plastering/models/chatMessageModel.dart';
import 'package:red_plastering/models/grpChatMessageModel.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/utils.dart';

class ChatScreenController extends GetxController {
  var searchTextEditingController = TextEditingController().obs;
  var textSearch = "".obs;
  var switchedIndex = 0.obs;
  var currentUserId = "".obs;
  var peerFcmToken = "".obs;
  // var groupChatId = "".obs;
  var noMessages = false.obs;
  var noGrpMessages = false.obs;
  var singleChatNameList = <ChatMessagesModel>[].obs;
  var singleChatNameList2 = <ChatMessagesModel>[].obs;
  var groupChatNameList = <GroupChatMessageModel>[].obs;
  var groupChatNameList2 = <GroupChatMessageModel>[].obs;
  // var timeShow = false.obs;
  // var lastMsgShow = false.obs;
  // var id = ''.obs;
  // var valueGet = false.obs;

  @override
  void onInit() {
    super.onInit();
    print(
        "FirebaseAuth.instance.currentUser${FirebaseAuth.instance.currentUser}");
    currentUserId.value = FirebaseAuth.instance.currentUser!.uid;
    // getMessages();

    getData();
    print('assasas');
    getGroupData();
    // FirebaseFirestore.instance.collection("UserListing").get().then((value) {
    //   value.docs.forEach((element) {
    //     if (GetStorage().read('email') != element.get('email')) {
    //       UserDataModel userDataModel = UserDataModel();
    //       userDataModel.id = element.get('id');
    //       userDataModel.name = element.get('name');
    //       userDataModel.fcmToken = element.get('fcmToken');
    //       userDataModel.email = element.get('email');
    //       nameList.add(userDataModel);
    //     }
    //   });
    // });
  }

  Future getData() async {
    try {
      await FirebaseFirestore.instance
          .collection("UserListing")
          .doc(currentUserId.value)
          .collection('conversation')
          .get()
          .then((value) {
        print("value.sizebbvbv${value.size}");
        if (value.size == 0) {
          noMessages.value = true;
        } else {
          noMessages.value = false;
          getUserData();
          // singleChatNameList.clear();
        }
      });
    } catch (e) {
      print("bvnhjuyty${e.toString()}");
    }
  }

  getGroupData() async {
    await FirebaseFirestore.instance
        .collection("UserListing")
        .doc(currentUserId.value)
        .collection('grpConversation')
        .get()
        .then((value) {
      print("vvfgtttsize${value.size}");
      if (value.size == 0) {
        noGrpMessages.value = true;
      } else {
        noGrpMessages.value = false;
        getGrpConverData();
        // groupChatNameList.clear();
      }
    });
  }

  // getMessages() {
  //   if (GetStorage().read('groupChat') == null) {
  //     noMessages.value = true;
  //   } else {
  //     FirebaseFirestore.instance.collection("Messages").get().then((value) {
  //       if (value.size == 0) {
  //         noMessages.value = true;
  //       } else {
  //         noMessages.value = false;
  //         getUserData();
  //         // timeShow.value = true;
  //         // lastMsgShow.value = true;
  //       }
  //     });
  //   }
  // }

  // getGroupChatId(String peerId) {
  //   print("PEERID,${peerId.toString()}");
  //   if (currentUserId.value.compareTo(peerId.toString()) > 0) {
  //     groupChatId.value = '${currentUserId.value} - ${peerId.toString()}';
  //     GetStorage().write('groupChat', groupChatId.value);
  //   } else {
  //     groupChatId.value = '${peerId.toString()} - ${currentUserId.value}';
  //     GetStorage().write('groupChat', groupChatId.value);
  //   }
  // }

  // Stream<QuerySnapshot> getUserData(String value) {
  //   if (value.isEmpty || value == '') {
  //     return FirebaseFirestore.instance
  //         .collection("Messages")
  //         .orderBy('timestamp', descending: true)
  //         .where('id', isEqualTo: currentUserId.value)
  //         .snapshots();
  //   } else {
  //     return FirebaseFirestore.instance
  //         .collection("UserListing")
  //         .where('name', isEqualTo: value)
  //         .snapshots();
  //   }
  // }
  // Stream<QuerySnapshot> getUserSearchData(String value) {
  //   return FirebaseFirestore.instance
  //       .collection("UserListing")
  //       .where('name', isGreaterThanOrEqualTo: value)
  //       .where('name', isLessThan: value + 'z')
  //       .where('name', isNotEqualTo: GetStorage().read('employeeName'))
  //       .snapshots();
  // }
  getUserSearchData(String value) {
    singleChatNameList2.value = singleChatNameList
        .where((item) => item.name!.toLowerCase().contains(value.toLowerCase()))
        .toList();

    singleChatNameList2.forEach((element) {
      print("VALUE,${element.name}");
    });
  }

  getGroupChatSearchData(String value) {
    print("groupChatNameList2$groupChatNameList2");
    print("groupChatNameList2$groupChatNameList");
    groupChatNameList2.value = groupChatNameList
        .where((item) =>
            getStringBeforeWord(item.groupname!.toLowerCase(), 'gid-')
                .contains(value.toLowerCase()))
        .toList();

    groupChatNameList2.forEach((element) {
      print("VALUE,${element.groupname}");
    });
  }

  getFcmTokenData(String peerId) {
    // print("hhhh$peerId");
    FirebaseFirestore.instance.collection('UserListing').get().then((value) {
      value.docs.forEach((element) {
        if (peerId.toString() == element.get('id')) {
          // print("element.get('name')${element.get('name')}");
          peerFcmToken.value = element.get('fcmToken');
          Get.toNamed(RouteConstant.conversationScreen, parameters: {
            'peerId': element.get('id'),
            'peerName': element.get('name'),
            'peerFcmToken': element.get('fcmToken'),
          })!
              .then((value) {
            getData();
          });
        }
      });
    });
  }

  Stream<List<ChatMessagesModel>> getUserData() {
    return FirebaseFirestore.instance
        .collection("UserListing")
        .doc(currentUserId.value)
        .collection('conversation')
        // .doc(GetStorage().read('groupChat'))
        // .collection(GetStorage().read('groupChat'))
        // .where('name', isNotEqualTo: GetStorage().read('employeeName'))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot list) => list.docs
            .map((DocumentSnapshot doc) => ChatMessagesModel.fromDocument(doc))
            .toList());
  }

  Stream<List<GroupChatMessageModel>> getGrpConverData() {
    return FirebaseFirestore.instance
        .collection("UserListing")
        .doc(currentUserId.value)
        .collection('grpConversation')
        // .doc(GetStorage().read('groupChat'))
        // .collection(GetStorage().read('groupChat'))
        // .where('name', isNotEqualTo: GetStorage().read('employeeName'))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot list) => list.docs
            .map((DocumentSnapshot doc) =>
                GroupChatMessageModel.fromDocument(doc))
            .toList());
  }

  @override
  void dispose() {
    super.dispose();
  }
}
