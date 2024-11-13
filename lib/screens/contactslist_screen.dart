import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:red_plastering/controller/contactslist_controller.dart';
import 'package:red_plastering/models/userDataModel.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';
import 'package:red_plastering/widgets/custom_loader.dart';

class ContactsListScreen extends GetView<ContactsListScreenController> {
  const ContactsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Get.back();
            // controller.removeSelection();
          },
          child: Image.asset(
            "assets/images/back.png",
          ),
        ),
        title: Text(
          "Contacts",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Microsoft YaHei',
              fontWeight: FontWeight.w400,
              fontSize: 15.0,
              color: AppColors.textColor1.withOpacity(0.58)),
        ).tr(),
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
            Container(
              padding: EdgeInsets.only(
                  left: Utils.width! / 20,
                  right: Utils.width! / 20,
                  top: Utils.height! / 8,
                  bottom: Utils.height! / 20),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Obx(() => Container(
                                padding: EdgeInsets.only(
                                    left: Utils.width! / 50,
                                    right: Utils.width! / 50,
                                    top: Utils.height! / 50,
                                    bottom: Utils.height! / 50),
                                decoration: BoxDecoration(
                                    color: AppColors.containerColor6
                                        .withOpacity(0.47),
                                    border: Border.all(
                                        color: AppColors.containerColor4),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: TextField(
                                  controller: controller
                                      .searchTextEditingController.value,
                                  onChanged: (value) {
                                    controller.textSearch.value = value;
                                    if (value == "") {
                                      // controller.getContactsList('');
                                      controller.groupIdsList.clear();

                                      controller.userDataModel.value =
                                          UserDataModel(
                                              name: GetStorage()
                                                  .read('employeeName'),
                                              id: controller
                                                  .currentUserId.value,
                                              phoneNumber: GetStorage()
                                                  .read('employeePhone'),
                                              fcmToken:
                                                  GetStorage().read('fcmtoken'),
                                              email: GetStorage().read('email'),
                                              groupIds: []);
                                      FirebaseFirestore.instance
                                          .collection("UserListing")
                                          .doc(controller.currentUserId.value)
                                          .update(controller.userDataModel.value
                                              .toJson())
                                          .then((value) {
                                        controller.updateSelection(
                                            true,
                                            controller.currentUserId.value,
                                            GetStorage().read('employeeName'),
                                            GetStorage().read('fcmtoken'));
                                      });

                                      // controller.contactListModelListSearch
                                      //     .clear();
                                    } else {
                                      controller.getUserSearchData(value);
                                      // controller.getContactsList(value);
                                      // controller.contactListModelList.clear();
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
                                          fontSize: 14.0,
                                          color: AppColors.textColor1),
                                      suffixIcon: const Icon(
                                        Icons.search,
                                        color: AppColors.containerColor4,
                                      ),
                                      suffixIconConstraints:
                                          const BoxConstraints()),
                                  style: const TextStyle(
                                      fontFamily: 'Microsoft YaHei',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.0,
                                      color: AppColors.textColor1),
                                ))),
                          ),
                          // SizedBox(
                          //   width: Utils.width! / 20,
                          // ),
                          // Expanded(
                          //     child: Obx(() => Transform.scale(
                          //           scale: 1.7,
                          //           child: Checkbox(
                          //             value: controller.selectAll.value,
                          //             onChanged: (value) {
                          //               controller.selectAll.value = value!;
                          //             },
                          //             checkColor: AppColors.textColor3,
                          //             splashRadius: 12.0,
                          //             shape: RoundedRectangleBorder(
                          //                 borderRadius:
                          //                     BorderRadius.circular(4.0)),
                          //             activeColor: AppColors.containerColor6
                          //                 .withOpacity(0.47),
                          //             side: const BorderSide(
                          //                 color: AppColors.containerColor4),
                          //           ),
                          //         )))
                        ],
                      ),
                    ),
                  ),
                  Obx(() => controller.singleChat.value
                      ? controller.isDataLoading.value
                          ? const Loader()
                          : Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: GestureDetector(
                                onTap: () {
                                  controller.checkSize();
                                  // Get.toNamed(RouteConstant.chatScreen);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: Utils.width! / 50,
                                      right: Utils.width! / 50,
                                      top: Utils.height! / 50,
                                      bottom: Utils.height! / 50),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      AppColors.dialogButtonRedGradientColor1,
                                      AppColors.dialogButtonRedGradientColor2
                                    ]),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Send",
                                          style: TextStyle(
                                              fontFamily: 'Microsoft YaHei',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16.0,
                                              color: AppColors.textColor1),
                                        ).tr(),
                                        SizedBox(
                                          width: Utils.width! / 35,
                                        ),
                                        Image.asset(
                                          "assets/images/send.png",
                                          width: Utils.width! / 25,
                                        )
                                      ]),
                                ),
                              ),
                            )
                      : Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              controller.checkSize();
                              // Get.toNamed(RouteConstant.chatScreen);
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: Utils.width! / 50,
                                  right: Utils.width! / 50,
                                  top: Utils.height! / 50,
                                  bottom: Utils.height! / 50),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  AppColors.dialogButtonRedGradientColor1,
                                  AppColors.dialogButtonRedGradientColor2
                                ]),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Send",
                                      style: TextStyle(
                                          fontFamily: 'Microsoft YaHei',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16.0,
                                          color: AppColors.textColor1),
                                    ).tr(),
                                    SizedBox(
                                      width: Utils.width! / 35,
                                    ),
                                    Image.asset(
                                      "assets/images/send.png",
                                      width: Utils.width! / 25,
                                    )
                                  ]),
                            ),
                          ),
                        ))
                ],
              ),
            ),
            Obx(
              () => Positioned(
                top: Utils.height! / 5,
                left: 0.0,
                bottom: Utils.height! / 6,
                right: 0.0,
                child: SizedBox(
                    // height: Utils.height! / 1.8,
                    child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.textSearch.value != ''
                      ? controller.contactListModelListSearch.length
                      : controller.contactListModelList.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(
                          left: Utils.width! / 20,
                          right: Utils.width! / 20,
                          top: Utils.height! / 50,
                          bottom: Utils.height! / 50),
                      child: Row(children: [
                        CircleAvatar(
                          child: controller.textSearch.value != ''
                              ? Text(controller
                                  .contactListModelListSearch[index].name![0]
                                  .toString())
                              : Text(controller
                                  .contactListModelList[index].name![0]
                                  .toString()),
                        ),
                        SizedBox(
                          width: Utils.width! / 20,
                        ),
                        controller.textSearch.value != ''
                            ? Text(
                                controller
                                    .contactListModelListSearch[index].name
                                    .toString(),
                                style: const TextStyle(
                                    fontFamily: 'Microsoft YaHei',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.0,
                                    color: AppColors.textColor1),
                              )
                            : Text(
                                controller.contactListModelList[index].name
                                    .toString(),
                                style: const TextStyle(
                                    fontFamily: 'Microsoft YaHei',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.0,
                                    color: AppColors.textColor1),
                              ),
                        const Spacer(),
                        controller.textSearch.value != ''
                            ? Transform.scale(
                                scale: 1.7,
                                child: Checkbox(
                                  value: controller
                                      .contactListModelListSearch[index]
                                      .isSelected,
                                  onChanged: (value) {
                                    // controller.selectOne[index] = value!;
                                    controller.contactListModelListSearch[index]
                                        .isSelected = value;
                                    controller.contactListModelListSearch
                                        .refresh();
                                    controller.updateSelection(
                                        value,
                                        controller
                                            .contactListModelListSearch[index]
                                            .id
                                            .toString(),
                                        controller
                                            .contactListModelListSearch[index]
                                            .name
                                            .toString(),
                                        controller
                                            .contactListModelListSearch[index]
                                            .fcmToken
                                            .toString());
                                    //  snapshot.data!.docs[index]['isSelected'];
                                  },
                                  checkColor: AppColors.textColor3,
                                  splashRadius: 12.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0)),
                                  activeColor: AppColors.containerColor6
                                      .withOpacity(0.47),
                                  side: const BorderSide(
                                      color: AppColors.containerColor4),
                                ),
                              )
                            : Transform.scale(
                                scale: 1.7,
                                child: Checkbox(
                                  value: controller
                                      .contactListModelList[index].isSelected,
                                  onChanged: (value) {
                                    // controller.selectOne[index] = value!;
                                    controller.contactListModelList[index]
                                        .isSelected = value;
                                    controller.contactListModelList.refresh();
                                    controller.updateSelection(
                                        value,
                                        controller
                                            .contactListModelList[index].id
                                            .toString(),
                                        controller
                                            .contactListModelList[index].name
                                            .toString(),
                                        controller.contactListModelList[index]
                                            .fcmToken
                                            .toString());
                                    //  snapshot.data!.docs[index]['isSelected'];
                                  },
                                  checkColor: AppColors.textColor3,
                                  splashRadius: 12.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0)),
                                  activeColor: AppColors.containerColor6
                                      .withOpacity(0.47),
                                  side: const BorderSide(
                                      color: AppColors.containerColor4),
                                ),
                              ),
                      ]),
                    );
                  },
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
