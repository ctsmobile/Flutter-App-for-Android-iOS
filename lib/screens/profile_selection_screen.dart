import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:red_plastering/controller/profile_selection_controller.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';
import 'package:red_plastering/widgets/custom_loader.dart';

class ProfileSelectionScreen extends GetView<ProfileSelectionScreenController> {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
      () => SizedBox(
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
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: Utils.height! / 10,
                    ),
                    child: Text(
                      controller.currentTime.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Microsoft YaHei',
                          fontWeight: FontWeight.w400,
                          fontSize: 32.0,
                          color: AppColors.textColor1),
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
                          Image.asset(
                            "assets/images/clockin.png",
                            width: Utils.width! / 5,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await GetStorage().write('ChatIndex', 0);
                              Get.toNamed(RouteConstant.chatScreen);
                            },
                            child: Image.asset(
                              "assets/images/chat.png",
                              width: Utils.width! / 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Obx(() => Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                controller.clockIn(1);
                                // controller.callNativeCode();
                              },
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Image.asset(
                                    "assets/images/img1.png",
                                    width: Utils.width! / 3,
                                    // height: Utils.height! / 2,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: Utils.height! / 100),
                                    child: Text(tr("Scaffold"),
                                        style: const TextStyle(
                                            fontFamily: 'Microsoft YaHei',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.0,
                                            color: AppColors.textColor3)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: Utils.width! / 50,
                            ),
                            InkWell(
                              onTap: () {
                                controller.clockIn(2);
                              },
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Image.asset(
                                    "assets/images/img4.png",
                                    width: Utils.width! / 3,
                                    // height: Utils.height! / 2,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: Utils.height! / 100),
                                    child: Text(tr("Lather"),
                                        style: const TextStyle(
                                            fontFamily: 'Microsoft YaHei',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.0,
                                            color: AppColors.textColor3)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Utils.height! / 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                controller.clockIn(3);
                              },
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Image.asset(
                                    "assets/images/img3.png",
                                    width: Utils.width! / 3,
                                    // height: Utils.height! / 2,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: Utils.height! / 100),
                                    child: Text(tr("Plasterer"),
                                        style: const TextStyle(
                                            fontFamily: 'Microsoft YaHei',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.0,
                                            color: AppColors.textColor3)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: Utils.width! / 50,
                            ),
                            InkWell(
                              onTap: () {
                                controller.clockIn(4);
                              },
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Image.asset(
                                    "assets/images/img2.png",
                                    width: Utils.width! / 3,
                                    // height: Utils.height! / 2,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: Utils.height! / 100),
                                    child: Text(tr("Travel"),
                                        style: const TextStyle(
                                            fontFamily: 'Microsoft YaHei',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.0,
                                            color: AppColors.textColor3)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    controller.isDataLoading.value
                        ? const Center(child: Loader())
                        : Container(),
                  ],
                ))
            // controller.listGet.value
            //     ? const Center(
            //         child: CircularProgressIndicator(),
            //       )
            //     : Positioned(
            //         top: Utils.height! / 4.2,
            //         bottom: Utils.height! / 5.5,
            //         // bottom: Utils.height! / 3.8,
            //         left: 0.0,
            //         right: 0.0,
            //         child: SizedBox(
            //           height: Utils.height! / 4,
            //           child: GridView.builder(
            //               shrinkWrap: true,
            //               padding: EdgeInsets.only(
            //                   // top: Utils.height! / 10,
            //                   // bottom: Utils.height! / 10,
            //                   right: Utils.width! / 10,
            //                   left: Utils.width! / 10),
            //               gridDelegate:
            //                   SliverGridDelegateWithFixedCrossAxisCount(
            //                       crossAxisCount: 2,
            //                       crossAxisSpacing: Utils.width! / 40,
            //                       mainAxisSpacing: Utils.height! / 60),
            //               itemCount: controller
            //                   .profileListDataModel.value.data!.length,
            //               itemBuilder: (context, index) {
            //                 return GestureDetector(
            //                   onTap: () {
            //                     controller.clockIn(controller
            //                         .profileListDataModel
            //                         .value
            //                         .data![index]
            //                         .jobId!);
            //                     // Get.offNamed(RouteConstant.clockOutScreen);
            //                     // Get.offNamed(RouteConstant.clockOutScreen);
            //                   },
            //                   // child: Text(
            //                   //   controller.profileListDataModel.value
            //                   //       .data![index].jobName
            //                   //       .toString(),
            //                   //   style: TextStyle(
            //                   //       fontFamily: 'Microsoft YaHei',
            //                   //       fontWeight: FontWeight.w400,
            //                   //       fontSize: 15.0,
            //                   //       color: AppColors.textColor1),
            //                   //   // width: Utils.width! / 4.5,
            //                   // ),
            //                   child: Stack(
            //                     children: [
            //                       SizedBox(
            //                         height: Utils.height! / 5,
            //                         child: ClipRRect(
            //                           borderRadius: const BorderRadius.only(
            //                               topLeft: Radius.circular(15.0),
            //                               topRight: Radius.circular(15.0),
            //                               bottomLeft: Radius.circular(15.0)),
            //                           child: Image.network(
            //                             controller.profileListDataModel.value
            //                                 .data![index].imageName
            //                                 .toString(),
            //                             width: Utils.width! / 2.5,
            //                             fit: BoxFit.cover,
            //                             loadingBuilder:
            //                                 (context, child, loadingProgress) {
            //                               if (loadingProgress == null)
            //                                 return child;
            //                               return Column(
            //                                 children: [
            //                                   const CupertinoActivityIndicator(
            //                                     color:
            //                                         AppColors.containerColor4,
            //                                   ),
            //                                   const Text(
            //                                     "Image Loading...",
            //                                     style: TextStyle(
            //                                         fontFamily:
            //                                             'Microsoft YaHei',
            //                                         fontWeight: FontWeight.w400,
            //                                         fontSize: 8.0,
            //                                         color:
            //                                             AppColors.textColor1),
            //                                   ).tr(),
            //                                 ],
            //                               );
            //                             },
            //                           ),
            //                         ),
            //                       ),
            //                       // Image.asset("assets/images/img1.png",
            //                       //     width: Utils.width! / 2.5),
            //                       Positioned(
            //                         // top: Utils.height! / 50,
            //                         // left: Utils.width! / 8,
            //                         child: Container(
            //                           width: Utils.width,
            //                           padding: EdgeInsets.only(
            //                               top: Utils.height! / 100,
            //                               bottom: Utils.height! / 100),
            //                           decoration: BoxDecoration(
            //                             color: AppColors.containerColor4
            //                                 .withOpacity(0.7),
            //                             borderRadius: const BorderRadius.only(
            //                               topLeft: Radius.circular(15.0),
            //                               topRight: Radius.circular(15.0),
            //                             ),
            //                           ),
            //                           child: Text(
            //                             controller.profileListDataModel.value
            //                                 .data![index].jobName
            //                                 .toString(),
            //                             textAlign: TextAlign.center,
            //                             style: const TextStyle(
            //                                 fontFamily: 'Microsoft YaHei',
            //                                 fontWeight: FontWeight.w400,
            //                                 fontSize: 15.0,
            //                                 color: AppColors.containerColor1),
            //                           ),
            //                         ),
            //                       )
            //                     ],
            //                   ),
            //                 );
            //               }),
            //         ),
            //       )
          ],
        ),
      ),
    ));
  }
}
