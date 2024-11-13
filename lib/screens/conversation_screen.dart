import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:red_plastering/controller/conversation_controller.dart';
import 'package:red_plastering/models/chatMessageModel.dart';
import 'package:red_plastering/models/grpChatMessageModel.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';
import 'package:red_plastering/widgets/custom_loader.dart';

class ConversationScreen extends GetView<ConversationScreenController> {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.containerColor1,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Image.asset(
            "assets/images/back.png",
          ),
        ),
        title: controller.grpName != null
            ? Text(
                "Conversation with ${getStringBeforeWord(controller.grpName.toString(), 'gid-')}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Microsoft YaHei',
                    fontWeight: FontWeight.w400,
                    fontSize: 15.0,
                    color: AppColors.textColor1.withOpacity(0.58)),
              )
            : Text(
                "Conversation with " + controller.peerName.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Microsoft YaHei',
                    fontWeight: FontWeight.w400,
                    fontSize: 15.0,
                    color: AppColors.textColor1.withOpacity(0.58)),
              ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/backgroundclockin.png",
            fit: BoxFit.cover,
          ),
          Positioned(
            top: Utils.height! / 10,
            bottom: Utils.height! / 8,
            left: 0.0,
            right: 0.0,
            child: SizedBox(
                // height: Utils.height! / 1.2,
                child: Obx(() => controller.grpName != null
                    ? buildListGrpMessage()
                    : buildListMessage())
                // ListView.builder(
                //   shrinkWrap: true,
                //   itemBuilder: (context, index) {
                //     return Container(
                //       padding: EdgeInsets.only(
                //           top: Utils.height! / 40,
                //           bottom: Utils.height! / 40,
                //           left: Utils.width! / 40,
                //           right: Utils.width! / 40),
                //       child: Column(
                //         children: [
                //           Row(
                //             children: [
                //               CircleAvatar(
                //                 child: Text(controller.peerName![0].toString()),
                //               ),
                //               Expanded(
                //                 child: ChatBubble(
                //                   clipper: ChatBubbleClipper6(
                //                       type: BubbleType.receiverBubble),
                //                   backGroundColor: AppColors.containerColor4
                //                       .withOpacity(0.11),
                //                   child: Column(
                //                       crossAxisAlignment:
                //                           CrossAxisAlignment.start,
                //                       children: [
                //                         Text(
                //                           "Hey, what are your plans for today?",
                //                           style: GoogleFonts.roboto(
                //                               fontSize: 14.0,
                //                               fontWeight: FontWeight.w400,
                //                               color: AppColors.textColor1),
                //                         ),
                //                         Align(
                //                           alignment: Alignment.bottomRight,
                //                           child: Text(
                //                             "9:46 am",
                //                             style: TextStyle(
                //                                 fontFamily: 'Microsoft YaHei',
                //                                 fontWeight: FontWeight.w400,
                //                                 fontSize: 12.0,
                //                                 color: AppColors.textColor1
                //                                     .withOpacity(0.6)),
                //                           ),
                //                         )
                //                       ]),
                //                 ),
                //               )
                //             ],
                //           ),
                //           SizedBox(
                //             height: Utils.height! / 20,
                //           ),
                //           ChatBubble(
                //             clipper:
                //                 ChatBubbleClipper6(type: BubbleType.sendBubble),
                //             backGroundColor:
                //                 AppColors.containerColor8.withOpacity(0.49),
                //             child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text(
                //                     "Hey, I’m working on Football project.",
                //                     style: GoogleFonts.roboto(
                //                         fontSize: 14.0,
                //                         fontWeight: FontWeight.w400,
                //                         color: AppColors.textColor1),
                //                   ),
                //                   Align(
                //                     alignment: Alignment.bottomRight,
                //                     child: Text(
                //                       "9:46 am",
                //                       style: TextStyle(
                //                           fontFamily: 'Microsoft YaHei',
                //                           fontWeight: FontWeight.w400,
                //                           fontSize: 12.0,
                //                           color: AppColors.textColor1
                //                               .withOpacity(0.6)),
                //                     ),
                //                   )
                //                 ]),
                //           )
                //         ],
                //       ),
                //     );
                //   },
                //   itemCount: 4,
                // ),
                ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(
                  left: Utils.width! / 50,
                  right: Utils.width! / 50,
                  bottom: Utils.height! / 100,
                  top: Utils.height! / 100),
              margin: EdgeInsets.only(
                  left: Utils.width! / 50,
                  right: Utils.width! / 50,
                  bottom: Utils.height! / 50,
                  top: Utils.height! / 50),
              decoration: BoxDecoration(
                  color: AppColors.containerColor2,
                  borderRadius: BorderRadius.circular(50.0)),
              child: Obx(() => TextFormField(
                    controller: controller.sendMsgController.value,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8), // Added this

                      suffixIcon: GestureDetector(
                        onTap: () {
                          if (controller.sendMsgController.value.text
                              .trim()
                              .isNotEmpty) {
                            if (controller.grpName != null) {
                              controller.sendGrpMsg(
                                  controller.sendMsgController.value.text, 1);
                            } else {
                              controller.sendMsg(
                                  controller.sendMsgController.value.text, 1);
                            }
                          } else {
                            controller.sendMsgController.value.clear();
                          }
                        },
                        child: Image.asset(
                          "assets/images/sendmsg.png",
                          width: Utils.width! / 20,
                        ),
                      ),
                      hintText: tr("Text Message..."),
                      hintStyle: GoogleFonts.roboto(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor1),
                    ),
                    style: GoogleFonts.roboto(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textColor1),
                  )),
            ),
          )
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return StreamBuilder<QuerySnapshot>(
        stream: controller.valueGot.value == true
            ? controller.getChatMessage()
            : Stream.empty(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                  padding: EdgeInsets.only(
                      left: Utils.width! / 50,
                      right: Utils.width! / 50,
                      top: Utils.height! / 50,
                      bottom: Utils.width! / 50),
                  itemCount: snapshot.data?.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) =>
                      buildItem(index, snapshot.data?.docs[index]));
            } else {
              return const Center(
                child: Text(
                  'No messages...',
                  style: const TextStyle(fontSize: 14.0, color: Colors.white),
                ),
              );
            }
          } else {
            return const Center(
              child: Loader(),
            );
          }
        });
  }

  Widget buildListGrpMessage() {
    print("controller.valueGot.value${controller.valueGot.value}");
    return StreamBuilder<QuerySnapshot>(
        stream: controller.valueGot.value == true
            ? controller.getGrpChatMessage()
            : Stream.empty(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                  padding: EdgeInsets.only(
                      left: Utils.width! / 50,
                      right: Utils.width! / 50,
                      top: Utils.height! / 50,
                      bottom: Utils.width! / 50),
                  itemCount: snapshot.data?.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    print("snapshot.data?.docs${snapshot.data?.docs.length}");

                    return buildGrpItem(index, snapshot.data?.docs[index]);
                  });
            } else {
              return const Center(
                child: Text(
                  'No grp messages...',
                  style: const TextStyle(fontSize: 14.0, color: Colors.white),
                ),
              );
            }
          } else {
            return const Center(
              child: Loader(),
            );
          }
        });
  }

  Widget buildItem(int index, DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      ChatMessagesModel chatMessages =
          ChatMessagesModel.fromDocument(documentSnapshot);
      if (chatMessages.idFrom == controller.currentUserId.value) {
        // right side (my message)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                chatMessages.type == 1
                    ? Flexible(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Utils.width! / 50,
                              right: Utils.width! / 50,
                              top: Utils.height! / 50,
                              bottom: Utils.height! / 50),
                          margin: EdgeInsets.only(
                              left: Utils.width! / 50,
                              right: Utils.width! / 50,
                              top: Utils.height! / 50,
                              bottom: Utils.height! / 50),
                          decoration: BoxDecoration(
                            color: AppColors.containerColor8.withOpacity(0.49),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            chatMessages.content.toString(),
                            maxLines: null,
                            style: const TextStyle(
                                fontSize: 14.0, color: Colors.white),
                          ),
                        ),
                      )
                    : chatMessages.type == 2
                        ? Container(
                            margin: EdgeInsets.only(
                                left: Utils.width! / 50,
                                right: Utils.width! / 50,
                                top: Utils.height! / 50,
                                bottom: Utils.height! / 50),
                            child: OutlinedButton(
                              onPressed: () {},
                              child: Image.network(
                                chatMessages.content.toString(),
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext ctx, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null &&
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, object, stackTrace) =>
                                    Container(
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.asset(
                                    'assets/images/imagenotfound.jpeg',
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: CircleAvatar(
                    child: Text(
                      GetStorage().read('employeeName')[0].toString(),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  left: Utils.width! / 50,
                  right: Utils.width! / 50,
                  top: Utils.height! / 50,
                  bottom: Utils.height! / 50),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chatMessages.timestamp.toString()),
                  ),
                ),
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
            )
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: CircleAvatar(
                    child: Text(
                      controller.peerName![0].toString(),
                    ),
                  ),
                ),
                chatMessages.type == 1
                    ? Flexible(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Utils.width! / 50,
                              right: Utils.width! / 50,
                              top: Utils.height! / 50,
                              bottom: Utils.height! / 50),
                          margin: EdgeInsets.only(
                              left: Utils.width! / 50,
                              right: Utils.width! / 50,
                              top: Utils.height! / 50,
                              bottom: Utils.height! / 50),
                          decoration: BoxDecoration(
                            color: AppColors.containerColor4.withOpacity(0.11),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            chatMessages.content.toString(),
                            style: const TextStyle(
                                fontSize: 14.0, color: Colors.white),
                          ),
                        ),
                      )
                    : chatMessages.type == 2
                        ? Container(
                            margin: EdgeInsets.only(
                                left: Utils.width! / 50,
                                right: Utils.width! / 50,
                                top: Utils.height! / 50,
                                bottom: Utils.height! / 50),
                            child: OutlinedButton(
                              onPressed: () {},
                              child: Image.network(
                                chatMessages.content.toString(),
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext ctx, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null &&
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, object, stackTrace) =>
                                    Container(
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.asset(
                                    'assets/images/imagenotfound.jpeg',
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  left: Utils.width! / 50,
                  right: Utils.width! / 50,
                  top: Utils.height! / 50,
                  bottom: Utils.height! / 50),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chatMessages.timestamp.toString()),
                  ),
                ),
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
            )
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildGrpItem(int index, DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      GroupChatMessageModel grpChatMessages =
          GroupChatMessageModel.fromDocument(documentSnapshot);
      if (grpChatMessages.idFrom == controller.currentUserId.value) {
        // right side (my message)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(
                        left: Utils.width! / 50,
                        right: Utils.width! / 50,
                        top: Utils.height! / 50,
                        bottom: Utils.height! / 50),
                    margin: EdgeInsets.only(
                        left: Utils.width! / 50,
                        right: Utils.width! / 50,
                        top: Utils.height! / 50,
                        bottom: Utils.height! / 50),
                    decoration: BoxDecoration(
                      color: AppColors.containerColor8.withOpacity(0.49),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      grpChatMessages.content.toString(),
                      style:
                          const TextStyle(fontSize: 14.0, color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: CircleAvatar(
                    child:
                        Text(GetStorage().read('employeeName')[0].toString()),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  left: Utils.width! / 50,
                  right: Utils.width! / 50,
                  top: Utils.height! / 50,
                  bottom: Utils.height! / 50),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(grpChatMessages.timestamp.toString()),
                  ),
                ),
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
            )
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: CircleAvatar(
                    child: Text(
                      grpChatMessages.senderName![0].toString(),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(
                        left: Utils.width! / 50,
                        right: Utils.width! / 50,
                        top: Utils.height! / 50,
                        bottom: Utils.height! / 50),
                    margin: EdgeInsets.only(
                        left: Utils.width! / 50,
                        right: Utils.width! / 50,
                        top: Utils.height! / 50,
                        bottom: Utils.height! / 50),
                    decoration: BoxDecoration(
                      color: AppColors.containerColor4.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      grpChatMessages.content.toString(),
                      style:
                          const TextStyle(fontSize: 14.0, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  left: Utils.width! / 50,
                  right: Utils.width! / 50,
                  top: Utils.height! / 50,
                  bottom: Utils.height! / 50),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(grpChatMessages.timestamp.toString()),
                  ),
                ),
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
            )
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
