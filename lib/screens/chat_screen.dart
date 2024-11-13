import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:red_plastering/controller/chat_controller.dart';
import 'package:red_plastering/models/chatMessageModel.dart';
import 'package:red_plastering/models/grpChatMessageModel.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';
import 'package:red_plastering/widgets/custom_loader.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ChatScreen extends GetView<ChatScreenController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final HomeScreenController controller = Get.put(HomeScreenController());
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Image.asset(
            "assets/images/back.png",
          ),
        ),
      ),
      body: SizedBox(
        width: Utils.width,
        height: Utils.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/images/backgroundclockin.png",
              fit: BoxFit.cover,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: Utils.width! / 20,
                          right: Utils.width! / 20,
                          top: Utils.height! / 8,
                          bottom: Utils.height! / 20),
                      child: Column(
                        children: [
                          Obx(() => Container(
                              padding: EdgeInsets.only(
                                  left: Utils.width! / 70,
                                  right: Utils.width! / 70,
                                  top: Utils.height! / 70,
                                  bottom: Utils.height! / 70),
                              decoration: BoxDecoration(
                                  color: AppColors.containerColor6
                                      .withOpacity(0.47),
                                  border: Border.all(
                                      color: AppColors.containerColor4),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: TextField(
                                textAlignVertical: TextAlignVertical.center,
                                controller: controller
                                    .searchTextEditingController.value,
                                onChanged: (value) {
                                  controller.textSearch.value = value;
                                  if (controller.switchedIndex.value == 0) {
                                    if (value == "") {
                                      controller.singleChatNameList.clear();
                                      controller.noMessages.value = true;
                                      controller.getData();
                                    } else {
                                      controller.noMessages.value = false;
                                      controller.getUserSearchData(value);
                                    }
                                  } else {
                                    if (value == "") {
                                      controller.groupChatNameList.clear();
                                      controller.noMessages.value = true;
                                      controller.getGrpConverData();
                                    } else {
                                      controller.noMessages.value = false;
                                      controller.getGroupChatSearchData(value);
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                    hintText: tr("Search"),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    hintStyle: const TextStyle(
                                        fontFamily: 'Microsoft YaHei',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.0,
                                        color: AppColors.textColor1),
                                    suffixIcon: const Icon(
                                      Icons.search,
                                      color: AppColors.containerColor4,
                                      size: 27.0,
                                    ),
                                    suffixIconConstraints:
                                        const BoxConstraints()),
                                style: const TextStyle(
                                    fontFamily: 'Microsoft YaHei',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.0,
                                    color: AppColors.textColor1),
                              ))),
                          SizedBox(
                            height: Utils.height! / 30,
                          ),
                          ToggleSwitch(
                            minWidth: Utils.width! / 2.3,
                            minHeight: Utils.height! / 16,
                            cornerRadius: 100.0,
                            activeBgColors: const [
                              [AppColors.containerColor1],
                              [AppColors.containerColor1]
                            ],
                            activeFgColor: AppColors.textColor1,
                            inactiveBgColor:
                                AppColors.textColor1.withOpacity(0.05),
                            inactiveFgColor: AppColors.textColor2,
                            initialLabelIndex: GetStorage().read('ChatIndex'),
                            totalSwitches: 2,
                            labels: [tr('Chats'), tr('Groups')],
                            radiusStyle: true,
                            customTextStyles: const [
                              TextStyle(
                                  fontFamily: 'Microsoft YaHei',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15.0),
                              TextStyle(
                                  fontFamily: 'Microsoft YaHei',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15.0),
                            ],
                            onToggle: (index) {
                              print('switched to: $index');
                              controller.switchedIndex.value = index!;
                              if (controller.switchedIndex.value == 0) {
                                GetStorage().write('ChatIndex', 0);
                                if (controller.searchTextEditingController.value
                                        .text ==
                                    "") {
                                  controller.singleChatNameList.clear();
                                  controller.noMessages.value = true;
                                  controller.getData();
                                } else {
                                  controller.noMessages.value = false;
                                  controller.getUserSearchData(controller
                                      .searchTextEditingController.value.text);
                                }

                                // controller.getData();
                              } else {
                                GetStorage().write('ChatIndex', 1);

                                if (controller.searchTextEditingController.value
                                        .text ==
                                    "") {
                                  controller.groupChatNameList.clear();
                                  controller.noMessages.value = true;
                                  controller.getGrpConverData();
                                } else {
                                  controller.noMessages.value = false;
                                  controller.getGroupChatSearchData(controller
                                      .searchTextEditingController.value.text);
                                }
                                controller.getGroupData();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: Utils.height! / 15),
                      child: Image.asset("assets/images/footer.png"),
                    ),
                    Positioned(
                      left: Utils.width! / 10,
                      right: Utils.width! / 10,
                      top: Utils.height! / 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Image.asset(
                              "assets/images/clockdone.png",
                              width: Utils.width! / 5,
                            ),
                          ),
                          Image.asset(
                            "assets/images/chatstart.png",
                            width: Utils.width! / 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            Positioned(
              top: Utils.height! / 3.2,
              bottom: Utils.height! / 5.5,
              // bottom: Utils.height! / 3.8,
              left: 0.0,
              right: 0.0,
              child: SizedBox(
                height: Utils.height! / 4,
                child: Obx(() => controller.switchedIndex.value == 1
                    ? controller.noGrpMessages.value == true
                        ? const Center(
                            child: Text("No Group chats!!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Microsoft YaHei',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.0,
                                  color: AppColors.textColor1,
                                )),
                          )
                        : controller.textSearch.value != ''
                            ? Obx(() => ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount:
                                      controller.groupChatNameList2.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Get.toNamed(
                                                RouteConstant
                                                    .conversationScreen,
                                                parameters: {
                                              // 'peerIdList':
                                              //     snapshot.data![index].id,
                                              'grpName': controller
                                                  .groupChatNameList2[index]
                                                  .groupname
                                                  .toString(),
                                            })!
                                            .then((value) {
                                          // controller.getGroupChatId(snapshot
                                          //     .data![index].idTo
                                          //     .toString());
                                          controller.getGroupData();
                                          // controller.getMessages();
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: Utils.width! / 20,
                                            right: Utils.width! / 20,
                                            top: Utils.height! / 40,
                                            bottom: Utils.height! / 40),
                                        child: Row(children: [
                                          CircleAvatar(
                                            child: Text(getStringBeforeWord(
                                                controller
                                                    .groupChatNameList2[index]
                                                    .groupname![0]
                                                    .toString(),
                                                'gid-')),
                                          ),
                                          SizedBox(
                                            width: Utils.width! / 30,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: Utils.width! / 2,
                                                child: Text(
                                                  getStringBeforeWord(
                                                      controller
                                                          .groupChatNameList2[
                                                              index]
                                                          .groupname
                                                          .toString(),
                                                      'gid-'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Microsoft YaHei',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16.0,
                                                      color:
                                                          AppColors.textColor1),
                                                ),
                                              ),
                                              Container(
                                                width: Utils.width! / 2,
                                                child: Text(
                                                  controller
                                                      .groupChatNameList2[index]
                                                      .content
                                                      .toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Microsoft YaHei',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14.0,
                                                      color: AppColors
                                                          .textColor1
                                                          .withOpacity(0.6)),
                                                ),
                                              )
                                            ],
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: Utils.height! / 50),
                                            child: Text(
                                              DateFormat("hh:mm a").format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          int.parse(
                                                controller
                                                    .groupChatNameList2[index]
                                                    .timestamp
                                                    .toString(),
                                              ))),
                                              style: TextStyle(
                                                  fontFamily: 'Microsoft YaHei',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12.0,
                                                  color: AppColors.textColor1
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    );
                                  },
                                ))
                            : StreamBuilder(
                                stream: controller.getGrpConverData(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(child: Loader());
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: Loader(),
                                    );
                                  } else {
                                    controller.groupChatNameList.clear();
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        GroupChatMessageModel
                                            groupChatMessageModel =
                                            GroupChatMessageModel();
                                        groupChatMessageModel.groupname =
                                            snapshot.data![index].groupname;
                                        groupChatMessageModel.content =
                                            snapshot.data![index].content;
                                        groupChatMessageModel.timestamp =
                                            snapshot.data![index].timestamp;

                                        print("gggff");

                                        controller.groupChatNameList
                                            .add(groupChatMessageModel);

                                        print(
                                            "controller.groupChatNameList${controller.groupChatNameList}");
                                        return InkWell(
                                          onTap: () {
                                            Get.toNamed(
                                                    RouteConstant
                                                        .conversationScreen,
                                                    parameters: {
                                                  // 'peerIdList':
                                                  //     snapshot.data![index].id,
                                                  'grpName': snapshot
                                                      .data![index].groupname
                                                      .toString(),
                                                })!
                                                .then((value) {
                                              // controller.getGroupChatId(snapshot
                                              //     .data![index].idTo
                                              //     .toString());
                                              controller.getGroupData();
                                              // controller.getMessages();
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: Utils.width! / 20,
                                                right: Utils.width! / 20,
                                                top: Utils.height! / 40,
                                                bottom: Utils.height! / 40),
                                            child: Row(children: [
                                              CircleAvatar(
                                                child: Text(getStringBeforeWord(
                                                    snapshot.data![index]
                                                        .groupname![0]
                                                        .toString(),
                                                    'gid-')),
                                              ),
                                              SizedBox(
                                                width: Utils.width! / 30,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: Utils.width! / 2,
                                                    child: Text(
                                                      getStringBeforeWord(
                                                          snapshot.data![index]
                                                              .groupname
                                                              .toString(),
                                                          'gid-'),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Microsoft YaHei',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 16.0,
                                                          color: AppColors
                                                              .textColor1),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: Utils.width! / 2,
                                                    child: Text(
                                                      snapshot
                                                          .data![index].content
                                                          .toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Microsoft YaHei',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14.0,
                                                          color: AppColors
                                                              .textColor1
                                                              .withOpacity(
                                                                  0.6)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const Spacer(),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: Utils.height! / 50),
                                                child: Text(
                                                  DateFormat("hh:mm a").format(
                                                      DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(snapshot
                                                                  .data![index]
                                                                  .timestamp
                                                                  .toString()))),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Microsoft YaHei',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12.0,
                                                      color: AppColors
                                                          .textColor1
                                                          .withOpacity(0.6)),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                })
                    : controller.noMessages.value == true
                        ? const Center(
                            child: Text("No chats!!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Microsoft YaHei',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.0,
                                  color: AppColors.textColor1,
                                )),
                          )
                        : controller.textSearch.value != ''
                            ? Obx(() => ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount:
                                      controller.singleChatNameList2.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        print(
                                            "  ff .singleChatNameList2[index]${controller.singleChatNameList2.length}");
                                        print(
                                            "   .singleChatNameList2[index]${controller.singleChatNameList2[index].name}");
                                        controller.getFcmTokenData(controller
                                            .singleChatNameList2[index].id
                                            .toString());
                                        // Get.toNamed(
                                        //         RouteConstant
                                        //             .conversationScreen,
                                        //         parameters: {
                                        //       'peerId': controller
                                        //           .singleChatNameList2[index]
                                        //           .idTo
                                        //           .toString(),
                                        //       'peerName': controller
                                        //           .singleChatNameList2[index]
                                        //           .name
                                        //           .toString(),
                                        //       'peerFcmToken': controller
                                        //           .singleChatNameList2[index]
                                        //           .peerFcmToken
                                        //           .toString(),
                                        //     })!
                                        //     .then((value) {
                                        //   // controller.getGroupChatId(snapshot
                                        //   //     .data!.docs[index]['id']);
                                        //   controller.getData();
                                        //   // controller.getMessages();
                                        // });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: Utils.width! / 20,
                                            right: Utils.width! / 20,
                                            top: Utils.height! / 40,
                                            bottom: Utils.height! / 40),
                                        child: Row(children: [
                                          CircleAvatar(
                                            child: Text(controller
                                                .singleChatNameList2[index]
                                                .name![0]
                                                .toString()),
                                          ),
                                          SizedBox(
                                            width: Utils.width! / 30,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: Utils.width! / 2,
                                                child: Text(
                                                  controller
                                                      .singleChatNameList2[
                                                          index]
                                                      .name
                                                      .toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Microsoft YaHei',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16.0,
                                                      color:
                                                          AppColors.textColor1),
                                                ),
                                              ),
                                              Container(
                                                width: Utils.width! / 2,
                                                child: Text(
                                                  controller
                                                      .singleChatNameList2[
                                                          index]
                                                      .content
                                                      .toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Microsoft YaHei',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14.0,
                                                      color: AppColors
                                                          .textColor1
                                                          .withOpacity(0.6)),
                                                ),
                                              )
                                            ],
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: Utils.height! / 50),
                                            child: Text(
                                              DateFormat("hh:mm a").format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      int.parse(controller
                                                          .singleChatNameList2[
                                                              index]
                                                          .timestamp
                                                          .toString()))),
                                              style: TextStyle(
                                                  fontFamily: 'Microsoft YaHei',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12.0,
                                                  color: AppColors.textColor1
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    );
                                  },
                                ))
                            : Obx(() => StreamBuilder(
                                stream: controller.getUserData(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(child: Loader());
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: Loader(),
                                    );
                                  } else {
                                    controller.singleChatNameList.clear();
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        ChatMessagesModel chatMessagesModel =
                                            ChatMessagesModel();
                                        chatMessagesModel.idTo =
                                            snapshot.data![index].idTo;
                                        chatMessagesModel.id =
                                            snapshot.data![index].id;
                                        chatMessagesModel.name =
                                            snapshot.data![index].name;
                                        chatMessagesModel.peerFcmToken =
                                            snapshot.data![index].peerFcmToken;
                                        chatMessagesModel.content =
                                            snapshot.data![index].content;
                                        chatMessagesModel.timestamp =
                                            snapshot.data![index].timestamp;
                                        controller.singleChatNameList
                                            .add(chatMessagesModel);

                                        return InkWell(
                                          onTap: () {
                                            controller.getFcmTokenData(snapshot
                                                .data![index].id
                                                .toString());
                                            // Get.toNamed(
                                            //         RouteConstant
                                            //             .conversationScreen,
                                            //         parameters: {
                                            //       'peerId': snapshot
                                            //           .data![index].id
                                            //           .toString(),
                                            //       'peerName': snapshot
                                            //           .data![index].name
                                            //           .toString(),
                                            //       // 'peerFcmToken': snapshot
                                            //       //     .data![index].peerFcmToken
                                            //       //     .toString(),
                                            //       'peerFcmToken': controller
                                            //           .peerFcmToken.value,
                                            //     })!
                                            //     .then((value) {
                                            //   // controller.getGroupChatId(snapshot
                                            //   //     .data![index].idTo
                                            //   //     .toString());
                                            //   controller.getData();
                                            //   // controller.getMessages();
                                            // });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: Utils.width! / 20,
                                                right: Utils.width! / 20,
                                                top: Utils.height! / 40,
                                                bottom: Utils.height! / 40),
                                            child: Row(children: [
                                              CircleAvatar(
                                                child: Text(snapshot
                                                    .data![index].name![0]
                                                    .toString()),
                                              ),
                                              SizedBox(
                                                width: Utils.width! / 30,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: Utils.width! / 2,
                                                    child: Text(
                                                      snapshot.data![index].name
                                                          .toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Microsoft YaHei',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 16.0,
                                                          color: AppColors
                                                              .textColor1),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: Utils.width! / 2,
                                                    child: Text(
                                                      snapshot
                                                          .data![index].content
                                                          .toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Microsoft YaHei',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14.0,
                                                          color: AppColors
                                                              .textColor1
                                                              .withOpacity(
                                                                  0.6)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const Spacer(),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: Utils.height! / 50),
                                                child: Text(
                                                  DateFormat("hh:mm a").format(
                                                      DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(snapshot
                                                                  .data![index]
                                                                  .timestamp
                                                                  .toString()))),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Microsoft YaHei',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12.0,
                                                      color: AppColors
                                                          .textColor1
                                                          .withOpacity(0.6)),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                }))),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(
                    right: Utils.width! / 20, top: Utils.height! / 2),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteConstant.addMessageScreen);
                  },
                  child: Image.asset(
                    "assets/images/add.png",
                    width: Utils.width! / 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
