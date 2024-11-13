// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:red_plastering/controller/chat_controller.dart';
import 'package:red_plastering/models/chatMessageModel.dart';
import 'package:red_plastering/models/contactListModel.dart';
import 'package:red_plastering/models/grpChatMessageModel.dart';
import 'package:red_plastering/models/userDataModel.dart';
import 'package:red_plastering/network/dioClient.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';
import 'package:uuid/uuid.dart';

class ContactsListScreenController extends GetxController {
  var selectAll = false.obs;
  var msgSent = false.obs;
  var selected = false.obs;
  var singleChat = false.obs;
  var isDataLoading = false.obs;
  var selectOne = [].obs;
  var searchTextEditingController = TextEditingController().obs;
  var groupNameController = TextEditingController().obs;
  var textSearch = "".obs;
  var currentUserId = "".obs;
  var listOfIds = <Id>[].obs;
  var groupIdsList = <GroupIds>[].obs;
  var groupIds2 = [].obs;
  var groupIds3 = <Id>[].obs;
  var groupIds4 = [].obs;
  var contactListModelList = <ContactListModel>[].obs;
  var contactListModelListSearch = <ContactListModel>[].obs;
  final userDataModel = UserDataModel().obs;
  var uuid = "".obs;
  // var peerId = "".obs;
  var textMessage = Get.parameters['textMessage'];
  final createGroupFormKey = GlobalKey<FormState>();
  final grpChatMessages = GroupChatMessageModel().obs;
  DocumentReference<Map<String, dynamic>>? documentReferenceCurrentUser;

  @override
  void onInit() {
    super.onInit();

    for (int i = 0; i < 10; i++) {
      selectOne.add(false);
    }
    currentUserId.value = FirebaseAuth.instance.currentUser!.uid;
    // getContactsList('');
    updateSelection(true, currentUserId.value,
        GetStorage().read('employeeName'), GetStorage().read('fcmtoken'));
    FirebaseFirestore.instance.collection("UserListing").get().then((value) {
      value.docs.forEach((element) {
        if (GetStorage().read('email') != element.get('email')) {
          ContactListModel contactListModel = ContactListModel();
          contactListModel.id = element.get('id');
          contactListModel.name = element.get('name');
          contactListModel.fcmToken = element.get('fcmToken');
          contactListModel.isSelected = false;
          contactListModelList.add(contactListModel);
        }
      });
    });
  }

  // Stream<QuerySnapshot> getContactsList() {
  //   return FirebaseFirestore.instance
  //       .collection("UserListing")
  //       .where('name', isNotEqualTo: GetStorage().read('employeeName'))
  //       .snapshots();
  // }
  getContactsList(String searchValue) {
    FirebaseFirestore.instance
        .collection("UserListing")
        .where('name', isGreaterThanOrEqualTo: searchValue)
        .where('name', isLessThan: searchValue + 'z')
        .where('name', isNotEqualTo: GetStorage().read('employeeName'))
        .get()
        .then((value) {
      contactListModelList.clear();
      value.docs.forEach((element) {
        ContactListModel contactListModel = ContactListModel();
        contactListModel.id = element.get('id');
        contactListModel.name = element.get('name');
        contactListModel.fcmToken = element.get('fcmToken');
        contactListModel.isSelected = false;
        contactListModelList.add(contactListModel);
      });
    });
  }

  // updateSelection(bool? value, String? id) {
  //   return FirebaseFirestore.instance
  //       .collection("UserListing")
  //       .doc(id)
  //       .set({'isSelected': value}).then((value) {
  //     getContactsList();
  //   });
  // }

  updateSelection(bool? value, String? id, String? name, String? fcmToken) {
    if (value == true) {
      GroupIds groupIds = GroupIds();
      groupIds.peerId = id;
      groupIds.peerName = name;
      groupIds.peerFcmToken = fcmToken;
      groupIdsList.add(groupIds);
      userDataModel.value = UserDataModel(
          name: GetStorage().read('employeeName'),
          id: currentUserId.value,
          phoneNumber: GetStorage().read('employeePhone'),
          email: GetStorage().read('email'),
          fcmToken: GetStorage().read('fcmtoken'),
          groupIds: groupIdsList);
      FirebaseFirestore.instance
          .collection("UserListing")
          .doc(currentUserId.value)
          .update(userDataModel.value.toJson());
    } else {
      // GroupIds groupIds = GroupIds();
      // groupIds.peerId = id;
      // groupIds.peerName = name;
      groupIdsList.removeWhere((element) => element.peerId == id);
      userDataModel.value = UserDataModel(
          name: GetStorage().read('employeeName'),
          id: currentUserId.value,
          phoneNumber: GetStorage().read('employeePhone'),
          email: GetStorage().read('email'),
          fcmToken: GetStorage().read('fcmtoken'),
          groupIds: groupIdsList);
      FirebaseFirestore.instance
          .collection("UserListing")
          .doc(currentUserId.value)
          .update(userDataModel.value.toJson());
    }
  }

  // removeSelection() {
  //   return FirebaseFirestore.instance
  //       .collection("UserListing")
  //       .where('isSelected', isEqualTo: true)
  //       .get()
  //       .then((value) {
  //     value.docs.forEach((element) {
  //       FirebaseFirestore.instance
  //           .collection("collectionPath")
  //           .doc(element.get('id'))
  //           .update({'isSelected': false});
  //     });
  //   });
  // }

  sendNotificationMessage(
      String peerFcmToken, String peerName, String message) async {
    try {
      final body = {
        'to': peerFcmToken,
        'notification': {'title': peerName, 'body': message},
        'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'}
      };
      dio.Response response =
          await DioClient.dio.post("https://fcm.googleapis.com/fcm/send",
              data: body,
              options: dio.Options(headers: {
                'content-Type': 'application/json',
                'authorization':
                    'key=AAAAMOGP4vQ:APA91bG041nRGaIzqLUzcFYPQmC85w5L9bgPFt9PkYEu3-5_8MAWL2TAeRzDdd3CfQ3QrV6SXe63WGDwV0svPUS0SIA1jBegG8gFF23xMWySQkgDCOZiZsVw0LZ_SZKsXqj6ofkFg-cn'
              }));
      log("RESPONSE JSON CODE,${response.statusCode}");
      log("RESPONSE JSON CODE,${response.statusMessage}");
    } catch (e) {
      log('message,${e}');
    }
  }

  String? groupNameValidation(String? value) {
    if (value == null || value.isEmpty) {
      return tr('Please fill this field');
    }
    return null;
  }

  checkSize() {
    FirebaseFirestore.instance
        .collection('UserListing')
        .doc(currentUserId.value)
        .get()
        .then((value) {
      groupIds4.clear();
      groupIds4.addAll(value.data()!['groupIds']);
      if (groupIds4.length > 2) {
        singleChat.value = false;
        Get.defaultDialog(
            title: tr("Create Group"),
            barrierDismissible: false,
            content: Form(
              key: createGroupFormKey,
              child: Column(
                children: [
                  Obx(() => TextFormField(
                        controller: groupNameController.value,
                        validator: groupNameValidation,
                        style: TextStyle(
                          fontFamily: 'Microsoft YaHei',
                          fontWeight: FontWeight.w400,
                          fontSize: 15.0,
                        ),
                        decoration: InputDecoration(
                          hintText: tr('Enter group name'),
                          hintStyle: TextStyle(
                            fontFamily: 'Microsoft YaHei',
                            fontWeight: FontWeight.w400,
                            fontSize: 15.0,
                          ),
                          fillColor: AppColors.textColor1.withOpacity(0.05),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.containerColor2
                                      .withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(50.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.containerColor2
                                      .withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(50.0)),
                          errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.containerColor8),
                              borderRadius: BorderRadius.circular(50.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.containerColor8),
                              borderRadius: BorderRadius.circular(50.0)),
                        ),
                      )),
                  SizedBox(
                    height: Utils.height! / 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: AppColors.containerColor8,
                        onPressed: () {
                          groupNameController.value.text = "";
                          Get.back();
                        },
                        child: Text(
                          tr("Cancel"),
                          style: const TextStyle(
                              fontFamily: 'Microsoft YaHei',
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                              color: AppColors.textColor1),
                        ),
                      ),
                      SizedBox(
                        width: Utils.width! / 10,
                      ),
                      MaterialButton(
                        color: AppColors.containerColor8,
                        onPressed: () {
                          if (groupNameController.value.text
                              .trim()
                              .isNotEmpty) {
                            sendMsgToGrp();
                          } else {
                            Get.snackbar(tr('Message'),
                                tr('Please enter a valid group name!'),
                                backgroundColor: AppColors.containerColor8,
                                colorText: AppColors.textColor1);
                            groupNameController.value.clear();
                          }
                        },
                        child: Text(
                          tr("Submit"),
                          style: const TextStyle(
                              fontFamily: 'Microsoft YaHei',
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                              color: AppColors.textColor1),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ));
      } else if (groupIds4.length == 2) {
        // value.docs.forEach((element) {
        //   sendMsg(element.get('id'), element.get('name'));
        // });

        sendMsg(
            value.data()!['groupIds'][1]['peerId'],
            value.data()!['groupIds'][1]['peerName'],
            value.data()!['groupIds'][1]['peerFcmToken']);
        singleChat.value = true;
      } else {
        Get.snackbar(tr('Message'), tr('Please select atleast one contact.'),
            backgroundColor: AppColors.containerColor8,
            colorText: AppColors.textColor1);
      }
    });
  }

  // Stream<QuerySnapshot> getUserSearchData(String value) {
  //   return FirebaseFirestore.instance
  //       .collection("UserListing")
  //       .where('name', isEqualTo: value)
  //       .where('name', isNotEqualTo: GetStorage().read('employeeName'))
  //       .snapshots();
  // }
  // getUserSearchData(String value) {
  //   FirebaseFirestore.instance
  //       .collection("UserListing")
  //       .where('name', isGreaterThanOrEqualTo: value)
  //       .where('name', isLessThan: value + 'z')
  //       .where('name', isNotEqualTo: GetStorage().read('employeeName'))
  //       .get()
  //       .then((value) {
  //     contactListModelListSearch.clear();
  //     value.docs.forEach((element) {
  //       ContactListModel contactListModel = ContactListModel();
  //       contactListModel.id = element.get('id');
  //       contactListModel.name = element.get('name');
  //       contactListModel.isSelected = false;
  //       contactListModelListSearch.add(contactListModel);
  //     });
  //   });
  // }
  getUserSearchData(String value) {
    contactListModelListSearch.value = contactListModelList
        .where((item) => item.name!.toLowerCase().contains(value.toLowerCase()))
        .toList();

    contactListModelListSearch.forEach((element) {
      print("VALUE,${element.name}");
    });
  }

  sendMsg(String id, String name, String fcmToken) {
    print("mkoi");
    isDataLoading(true);
    FirebaseFirestore.instance
        .collection("UserListing")
        .doc(currentUserId.value)
        .collection('conversation')
        .get()
        .then((valueSize) {
      if (valueSize.size != 0) {
        print("zasawe");
        FirebaseFirestore.instance
            .collection("UserListing")
            .doc(currentUserId.value)
            .collection('conversation')
            .doc(id)
            .get()
            .then((valueNewSize) {
          if (valueNewSize.exists) {
            FirebaseFirestore.instance
                .collection("UserListing")
                .doc(currentUserId.value)
                .collection('conversation')
                .doc(id)
                .get()
                .then((value) {
              uuid.value = value.data()!['uniqueId'];
              print("VALUEEEEE,${uuid.value}");
              print("VALUEEEEE CONTENT,${value.data()!['content']}");

              DocumentReference documentReferenceCurrentUser = FirebaseFirestore
                  .instance
                  .collection("UserListing")
                  .doc(currentUserId.value)
                  .collection('conversation')
                  .doc(id);
              DocumentReference documentReferencePeerUser = FirebaseFirestore
                  .instance
                  .collection("UserListing")
                  .doc(id)
                  .collection('conversation')
                  .doc(currentUserId.value);
              ChatMessagesModel chatMessagesCurrentUser = ChatMessagesModel(
                  id: id,
                  name: name,
                  idFrom: currentUserId.value,
                  peerFcmToken: fcmToken,
                  idTo: id,
                  timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
                  uniqueId: uuid.value,
                  content: textMessage,
                  type: 1);
              ChatMessagesModel chatMessagesPeerUser = ChatMessagesModel(
                  id: currentUserId.value,
                  name: GetStorage().read('employeeName'),
                  idFrom: currentUserId.value,
                  idTo: id,
                  peerFcmToken: GetStorage().read('fcmtoken'),
                  timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
                  uniqueId: uuid.value,
                  content: textMessage,
                  type: 1);

              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(documentReferenceCurrentUser,
                    chatMessagesCurrentUser.toJson());
                transaction.set(
                    documentReferencePeerUser, chatMessagesPeerUser.toJson());
                DocumentReference documentReferenceMessages = FirebaseFirestore
                    .instance
                    .collection("Messages")
                    .doc(chatMessagesCurrentUser.uniqueId)
                    .collection('chats')
                    .doc();
                transaction.set(documentReferenceMessages,
                    chatMessagesCurrentUser.toJson());
                sendNotificationMessage(
                    fcmToken, GetStorage().read('employeeName'), textMessage!);
                isDataLoading(false);
                // FirebaseFirestore.instance
                //     .collection("UserListing")
                //     .doc(id)
                //     .update({'isSelected': false});
                userDataModel.value = UserDataModel(
                    name: GetStorage().read('employeeName'),
                    id: currentUserId.value,
                    phoneNumber: GetStorage().read('employeePhone'),
                    fcmToken: GetStorage().read('fcmtoken'),
                    email: GetStorage().read('email'),
                    groupIds: []);
                FirebaseFirestore.instance
                    .collection("UserListing")
                    .doc(currentUserId.value)
                    .update(userDataModel.value.toJson());
                print("tyytytyt");
                Get.until(
                    (route) => route.settings.name == RouteConstant.chatScreen);
              });
            });
          } else {
            print("bvbbvpo");
            uuid.value = Uuid().v4();

            DocumentReference documentReferenceCurrentUser = FirebaseFirestore
                .instance
                .collection("UserListing")
                .doc(currentUserId.value)
                .collection('conversation')
                .doc(id);
            DocumentReference documentReferencePeerUser = FirebaseFirestore
                .instance
                .collection("UserListing")
                .doc(id)
                .collection('conversation')
                .doc(currentUserId.value);
            ChatMessagesModel chatMessagesCurrentUser = ChatMessagesModel(
                id: id,
                name: name,
                idFrom: currentUserId.value,
                idTo: id,
                peerFcmToken: fcmToken,
                timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
                uniqueId: uuid.value,
                content: textMessage,
                type: 1);
            ChatMessagesModel chatMessagesPeerUser = ChatMessagesModel(
                id: currentUserId.value,
                name: GetStorage().read('employeeName'),
                idFrom: currentUserId.value,
                idTo: id,
                peerFcmToken: GetStorage().read('fcmtoken'),
                timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
                uniqueId: uuid.value,
                content: textMessage,
                type: 1);

            FirebaseFirestore.instance.runTransaction((transaction) async {
              transaction.set(documentReferenceCurrentUser,
                  chatMessagesCurrentUser.toJson());
              transaction.set(
                  documentReferencePeerUser, chatMessagesPeerUser.toJson());
              DocumentReference documentReferenceMessages = FirebaseFirestore
                  .instance
                  .collection("Messages")
                  .doc(chatMessagesCurrentUser.uniqueId)
                  .collection('chats')
                  .doc();
              transaction.set(
                  documentReferenceMessages, chatMessagesCurrentUser.toJson());
              sendNotificationMessage(
                  fcmToken, GetStorage().read('employeeName'), textMessage!);
              isDataLoading(false);
              // FirebaseFirestore.instance
              //     .collection("UserListing")
              //     .doc(id)
              //     .update({'isSelected': false});
              userDataModel.value = UserDataModel(
                  name: GetStorage().read('employeeName'),
                  id: currentUserId.value,
                  phoneNumber: GetStorage().read('employeePhone'),
                  fcmToken: GetStorage().read('fcmtoken'),
                  email: GetStorage().read('email'),
                  groupIds: []);
              FirebaseFirestore.instance
                  .collection("UserListing")
                  .doc(currentUserId.value)
                  .update(userDataModel.value.toJson());
              print("bvvbbvbvbvbv");
              Get.until(
                  (route) => route.settings.name == RouteConstant.chatScreen);
            });
          }
        });

        // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        //     .collection("UserListing")
        //     .doc(currentUserId.value)
        //     .collection('conversation')
        //     .get();

        // for (int i = 0; i < querySnapshot.docs.length; i++) {
        //   var uniqueID = querySnapshot.docs[i];
        //   // uuid.value = uniqueID.get('uniqueId');
        //   if (idTo.value == '') {
        //     if (uniqueID.get('id') == peerId.toString()) {
        //       uuid.value = uniqueID.get('uniqueId');
        //       idTo.value = uniqueID.get('idTo');
        //     } else if (uniqueID.get('id') == currentUserId.value) {
        //       uuid.value = uniqueID.get('uniqueId');
        //       idTo.value = uniqueID.get('idTo');
        //     } else {
        //       uuid.value = Uuid().v4();
        //     }
        //     print(uniqueID.get('uniqueId'));
        //   }
        // }
      } else {
        print("vcvvc");
        uuid.value = Uuid().v4();
        DocumentReference documentReferenceCurrentUser = FirebaseFirestore
            .instance
            .collection("UserListing")
            .doc(currentUserId.value)
            .collection('conversation')
            .doc(id);
        DocumentReference documentReferencePeerUser = FirebaseFirestore.instance
            .collection("UserListing")
            .doc(id)
            .collection('conversation')
            .doc(currentUserId.value);
        print("asawe");
        ChatMessagesModel chatMessagesCurrentUser = ChatMessagesModel(
            id: id,
            name: name,
            idFrom: currentUserId.value,
            idTo: id,
            peerFcmToken: fcmToken,
            timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
            uniqueId: uuid.value,
            content: textMessage,
            type: 1);
        ChatMessagesModel chatMessagesPeerUser = ChatMessagesModel(
            id: currentUserId.value,
            name: GetStorage().read('employeeName'),
            idFrom: currentUserId.value,
            idTo: id,
            peerFcmToken: GetStorage().read('fcmtoken'),
            timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
            uniqueId: uuid.value,
            content: textMessage,
            type: 1);
        print("nbnbji");
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(
              documentReferenceCurrentUser, chatMessagesCurrentUser.toJson());
          transaction.set(
              documentReferencePeerUser, chatMessagesPeerUser.toJson());
          DocumentReference documentReferenceMessages = FirebaseFirestore
              .instance
              .collection("Messages")
              .doc(chatMessagesCurrentUser.uniqueId)
              .collection('chats')
              .doc();
          transaction.set(
              documentReferenceMessages, chatMessagesCurrentUser.toJson());
          print("axaxse");

          sendNotificationMessage(
              fcmToken, GetStorage().read('employeeName'), textMessage!);
          isDataLoading(false);
          // FirebaseFirestore.instance
          //     .collection("UserListing")
          //     .doc(id)
          //     .update({'isSelected': false});
          userDataModel.value = UserDataModel(
              name: GetStorage().read('employeeName'),
              id: currentUserId.value,
              phoneNumber: GetStorage().read('employeePhone'),
              fcmToken: GetStorage().read('fcmtoken'),
              email: GetStorage().read('email'),
              groupIds: []);
          await FirebaseFirestore.instance
              .collection("UserListing")
              .doc(currentUserId.value)
              .update(userDataModel.value.toJson())
              .then((v) async {
            print("bghguuuy");
            Future.delayed(const Duration(seconds: 1)).then((val) async {
              await Get.find<ChatScreenController>().getData();
            });
          });
          print("ooooo");

          // Get.offAllNamed(RouteConstant.chatScreen);
          Get.until((route) => route.settings.name == RouteConstant.chatScreen);
        });
      }
    });
  }

  // sendMsgToGrp() {
  //   FirebaseFirestore.instance
  //       .collection("UserListing")
  //       .doc(currentUserId.value)
  //       .update({'isSelected': true}).then((value) {
  //     if (createGroupFormKey.currentState!.validate()) {
  //       return FirebaseFirestore.instance
  //           .collection("UserListing")
  //           .doc(currentUserId.value)
  //           .collection("grpConversation")
  //           .get()
  //           .then((value) {
  //         if (value.size != 0) {
  //           value.docs.forEach((element) {
  //             if (groupNameController.value.text == element.get('groupname')) {
  //               Get.snackbar(tr('Message'),
  //                   tr('Group with this name already exist. Please try another name.'),
  //                   backgroundColor: AppColors.containerColor8,
  //                   colorText: AppColors.textColor1);
  //             } else {
  //               FirebaseFirestore.instance
  //                   .collection("UserListing")
  //                   .where('isSelected', isEqualTo: true)
  //                   .get()
  //                   .then((value) {
  //                 value.docs.forEach((element) {
  //                   documentReferenceCurrentUser = FirebaseFirestore.instance
  //                       .collection("UserListing")
  //                       .doc(currentUserId.value)
  //                       .collection('grpConversation')
  //                       .doc(groupNameController.value.text);
  //                   DocumentReference documentReferencePeerUser =
  //                       FirebaseFirestore.instance
  //                           .collection("UserListing")
  //                           .doc(element.get('id'))
  //                           .collection('grpConversation')
  //                           .doc(groupNameController.value.text);
  //                   Id peerIds = Id(
  //                       peerId: element.get('id'),
  //                       peerName: element.get('name'));
  //                   listOfIds.add(peerIds);
  //                   grpChatMessages.value = GroupChatMessageModel(
  //                     id: listOfIds,
  //                     groupname: groupNameController.value.text,
  //                     content: textMessage,
  //                     timestamp:
  //                         DateTime.now().millisecondsSinceEpoch.toString(),
  //                     idFrom: currentUserId.value,
  //                     senderName: GetStorage().read('employeeName'),
  //                   );
  //                   FirebaseFirestore.instance
  //                       .runTransaction((transaction) async {
  //                     transaction.set(documentReferencePeerUser,
  //                         grpChatMessages.value.toJson());
  //                   });
  //                 });
  //                 if (documentReferenceCurrentUser != null) {
  //                   FirebaseFirestore.instance
  //                       .runTransaction((transaction) async {
  //                     transaction.set(documentReferenceCurrentUser!,
  //                         grpChatMessages.value.toJson());

  //                     DocumentReference documentReferenceMessages =
  //                         FirebaseFirestore.instance
  //                             .collection("Messages")
  //                             .doc(groupNameController.value.text)
  //                             .collection('grpChats')
  //                             .doc();
  //                     transaction.set(documentReferenceMessages,
  //                         grpChatMessages.value.toJson());
  //                     listOfIds.forEach((element) {
  //                       FirebaseFirestore.instance
  //                           .collection("UserListing")
  //                           .doc(element.peerId)
  //                           .update({'isSelected': false});
  //                     });
  //                     Get.until((route) =>
  //                         route.settings.name == RouteConstant.chatScreen);
  //                   });
  //                 }
  //               });
  //             }
  //           });
  //         } else {
  //           FirebaseFirestore.instance
  //               .collection("UserListing")
  //               .where('isSelected', isEqualTo: true)
  //               .get()
  //               .then((value) {
  //             value.docs.forEach((element) {
  //               documentReferenceCurrentUser = FirebaseFirestore.instance
  //                   .collection("UserListing")
  //                   .doc(currentUserId.value)
  //                   .collection('grpConversation')
  //                   .doc(groupNameController.value.text);
  //               DocumentReference documentReferencePeerUser = FirebaseFirestore
  //                   .instance
  //                   .collection("UserListing")
  //                   .doc(element.get('id'))
  //                   .collection('grpConversation')
  //                   .doc(groupNameController.value.text);
  //               Id peerIds = Id(
  //                   peerId: element.get('id'), peerName: element.get('name'));
  //               listOfIds.add(peerIds);
  //               grpChatMessages.value = GroupChatMessageModel(
  //                 id: listOfIds,
  //                 groupname: groupNameController.value.text,
  //                 content: textMessage,
  //                 timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
  //                 idFrom: currentUserId.value,
  //                 senderName: GetStorage().read('employeeName'),
  //               );
  //               FirebaseFirestore.instance.runTransaction((transaction) async {
  //                 transaction.set(documentReferencePeerUser,
  //                     grpChatMessages.value.toJson());
  //               });
  //             });
  //             if (documentReferenceCurrentUser != null) {
  //               FirebaseFirestore.instance.runTransaction((transaction) async {
  //                 transaction.set(documentReferenceCurrentUser!,
  //                     grpChatMessages.value.toJson());

  //                 DocumentReference documentReferenceMessages =
  //                     FirebaseFirestore.instance
  //                         .collection("Messages")
  //                         .doc(groupNameController.value.text)
  //                         .collection('grpChats')
  //                         .doc();
  //                 transaction.set(documentReferenceMessages,
  //                     grpChatMessages.value.toJson());
  //                 listOfIds.forEach((element) {
  //                   FirebaseFirestore.instance
  //                       .collection("UserListing")
  //                       .doc(element.peerId)
  //                       .update({'isSelected': false});
  //                 });
  //                 Get.until((route) =>
  //                     route.settings.name == RouteConstant.chatScreen);
  //               });
  //             }
  //           });
  //         }
  //       });
  //     }
  //   });
  // }

  sendMsgToGrp() {
    bool groupExist = false;
    String groupName = groupNameController.value.text.toString() +
        'gid-${currentUserId.value}';

    print("groupName$groupName");
    if (createGroupFormKey.currentState!.validate()) {
      print("currentUserId.value${currentUserId.value}");
      return FirebaseFirestore.instance
          .collection("UserListing")
          .doc(currentUserId.value)
          .collection("grpConversation")
          .get()
          .then((value) {
        print("value.size${value.size}");
        if (value.size != 0) {
          for (int i = 0; i < value.docs.length; i++) {
            if (value.docs[i].get('groupname') ==
                groupNameController.value.text.toString() +
                    'gid-${currentUserId.value}') {
              groupName = groupName + const Uuid().v4();
              // groupExist = true;
              // Get.snackbar(tr('Message'),
              //     tr('Group with this name already exist. Please try another name.'),
              //     backgroundColor: AppColors.containerColor8,
              //     colorText: AppColors.textColor1);
            }
          }

          print("groupName2$groupName");
          // if (!groupExist) {
          FirebaseFirestore.instance
              .collection("UserListing")
              .doc(currentUserId.value)
              .get()
              .then((value) {
            groupIds2.clear();
            groupIds3.clear();
            print("value.data()!${value.data()!}");
            print("value.data()!['groupIds']${value.data()!['groupIds']}");
            groupIds2.addAll(value.data()!['groupIds']);
            for (int i = 0; i < groupIds2.length; i++) {
              Id peerIds = Id(
                  peerId: value.data()!['groupIds'][i]['peerId'],
                  peerName: value.data()!['groupIds'][i]['peerName'],
                  peerFcmToken: value.data()!['groupIds'][i]['peerFcmToken']);
              groupIds3.add(peerIds);
              documentReferenceCurrentUser = FirebaseFirestore.instance
                  .collection("UserListing")
                  .doc(currentUserId.value)
                  .collection('grpConversation')
                  .doc(groupName);
              print(
                  "documentReferenceCurrentUser${documentReferenceCurrentUser}");
              DocumentReference documentReferencePeerUser = FirebaseFirestore
                  .instance
                  .collection("UserListing")
                  .doc(value.data()!['groupIds'][i]['peerId'])
                  .collection('grpConversation')
                  .doc(groupName);
              print("documentReferencePeerUser${documentReferencePeerUser}");
              grpChatMessages.value = GroupChatMessageModel(
                id: groupIds3,
                groupname: groupName,
                content: textMessage,
                timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
                idFrom: currentUserId.value,
                senderName: GetStorage().read('employeeName'),
              );
              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(
                    documentReferencePeerUser, grpChatMessages.value.toJson());
                if (GetStorage().read('fcmtoken') !=
                    value.data()!['groupIds'][i]['peerFcmToken']) {
                  sendNotificationMessage(
                      value.data()!['groupIds'][i]['peerFcmToken']!,
                      groupNameController.value.text,
                      textMessage.toString());
                }
              });
            }

            if (documentReferenceCurrentUser != null) {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                print("grpChatMessages${grpChatMessages.value.content}");
                transaction.set(documentReferenceCurrentUser!,
                    grpChatMessages.value.toJson());
                print("gffg${currentUserId.value}");
                DocumentReference documentReferenceMessages = FirebaseFirestore
                    .instance
                    .collection("Messages")
                    .doc(groupName)
                    .collection('grpChats')
                    .doc();
                print(
                    "grpChatMessages.value.toJson()${grpChatMessages.value.toJson()}");
                transaction.set(
                    documentReferenceMessages, grpChatMessages.value.toJson());

                userDataModel.value = UserDataModel(
                    name: GetStorage().read('employeeName'),
                    id: currentUserId.value,
                    fcmToken: GetStorage().read('fcmtoken'),
                    phoneNumber: GetStorage().read('employeePhone'),
                    email: GetStorage().read('email'),
                    groupIds: []);
                FirebaseFirestore.instance
                    .collection("UserListing")
                    .doc(currentUserId.value)
                    .update(userDataModel.value.toJson());

                Get.until(
                    (route) => route.settings.name == RouteConstant.chatScreen);
              });
            }
          });
          // }
        } else {
          FirebaseFirestore.instance
              .collection("UserListing")
              .doc(currentUserId.value)
              .get()
              .then((value) {
            groupIds2.clear();
            groupIds3.clear();
            groupIds2.addAll(value.data()!['groupIds']);
            for (int i = 0; i < groupIds2.length; i++) {
              Id peerIds = Id(
                  peerId: value.data()!['groupIds'][i]['peerId'],
                  peerName: value.data()!['groupIds'][i]['peerName'],
                  peerFcmToken: value.data()!['groupIds'][i]['peerFcmToken']);
              groupIds3.add(peerIds);
              documentReferenceCurrentUser = FirebaseFirestore.instance
                  .collection("UserListing")
                  .doc(currentUserId.value)
                  .collection('grpConversation')
                  .doc(groupName);
              DocumentReference documentReferencePeerUser = FirebaseFirestore
                  .instance
                  .collection("UserListing")
                  .doc(value.data()!['groupIds'][i]['peerId'])
                  .collection('grpConversation')
                  .doc(groupName);

              grpChatMessages.value = GroupChatMessageModel(
                id: groupIds3,
                groupname: groupName,
                content: textMessage,
                timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
                idFrom: currentUserId.value,
                senderName: GetStorage().read('employeeName'),
              );
              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(
                    documentReferencePeerUser, grpChatMessages.value.toJson());
                if (GetStorage().read('fcmtoken') !=
                    value.data()!['groupIds'][i]['peerFcmToken']) {
                  sendNotificationMessage(
                      value.data()!['groupIds'][i]['peerFcmToken']!,
                      groupNameController.value.text.toString(),
                      textMessage.toString());
                }
              });
            }

            if (documentReferenceCurrentUser != null) {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(documentReferenceCurrentUser!,
                    grpChatMessages.value.toJson());

                DocumentReference documentReferenceMessages = FirebaseFirestore
                    .instance
                    .collection("Messages")
                    .doc(groupName)
                    .collection('grpChats')
                    .doc();
                transaction.set(
                    documentReferenceMessages, grpChatMessages.value.toJson());

                userDataModel.value = UserDataModel(
                    name: GetStorage().read('employeeName'),
                    id: currentUserId.value,
                    email: GetStorage().read('email'),
                    fcmToken: GetStorage().read('fcmtoken'),
                    phoneNumber: GetStorage().read('employeePhone'),
                    groupIds: []);
                await FirebaseFirestore.instance
                    .collection("UserListing")
                    .doc(currentUserId.value)
                    .update(userDataModel.value.toJson())
                    .then((v) {
                  // print("123445");

                  Future.delayed(const Duration(seconds: 1)).then((val) async {
                    await GetStorage().write('ChatIndex', 1);
                    await Get.find<ChatScreenController>().getGroupData();
                  });
                });

                // Get.offAllNamed(RouteConstant.chatScreen);
                Get.until(
                    (route) => route.settings.name == RouteConstant.chatScreen);
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
