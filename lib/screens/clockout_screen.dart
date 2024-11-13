import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:red_plastering/controller/clockout_controller.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:red_plastering/widgets/custom_loader.dart';

class ClockOutScreen extends GetView<ClockOutScreenController> {
  const ClockOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: EdgeInsets.only(bottom: Utils.height! / 6.3),
            //     child: Image.asset(
            //       "assets/images/clocksbackred.png",
            //     ),
            //   ),
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Padding(
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
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/clocksbackred.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Obx(
                        () => Align(
                          alignment: Alignment.center,
                          child: AnalogClock(
                            decoration: const BoxDecoration(
                                // border: Border.all(
                                //     width: 15.0, color: AppColors.containerColor5),
                                color: AppColors.containerColor4,
                                shape: BoxShape.circle),
                            width: Utils.width! / 2,
                            isLive: true,
                            hourHandColor: AppColors.containerColor1,
                            minuteHandColor: AppColors.containerColor1,
                            showSecondHand: true,
                            numberColor: AppColors.containerColor1,
                            showNumbers: true,
                            showAllNumbers: true,
                            textScaleFactor: 1,
                            tickColor: AppColors.containerColor1,
                            showTicks: true,
                            showDigitalClock: false,
                            datetime: controller.currentClockTime.value,
                          ),
                        ),
                      ),
                      // Align(
                      //   alignment: Alignment.center,
                      //   child: SizedBox(
                      //     width: Utils.width! / 2.12,
                      //     child: AnalogClock(
                      //       hourHandColor: AppColors.containerColor1,
                      //       minuteHandColor: AppColors.containerColor1,
                      //       isKeepTime: true,
                      //       dateTime: DateTime.now(),
                      //     ),
                      //   ),
                      // ),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            controller.clockOut();
                            // Get.offNamed(RouteConstant.clockInScreen);
                          },
                          child: Image.asset(
                            "assets/images/stop.png",
                            // width: Utils.width! / 6,
                            width: Utils.width! / 8,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Flexible(
                            child: GestureDetector(
                              onTap: () {
                                if (controller.startTravel.value == true) {
                                  Get.snackbar(tr('Message'),
                                      tr('You cannot start break in between your travel.'),
                                      backgroundColor:
                                          AppColors.containerColor8,
                                      colorText: AppColors.textColor1);
                                } else {
                                  controller.clicked.value = false;
                                  breakStartStopDialog(context);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50.0),
                                    border: Border.all(
                                        color:
                                            AppColors.breakTravelBorderColor),
                                    gradient: controller
                                                .startLunchBreak.value ==
                                            true
                                        ? const LinearGradient(colors: [
                                            AppColors.breakTravelGradientColor1,
                                            AppColors.breakTravelGradientColor2,
                                          ])
                                        : null),
                                padding: EdgeInsets.only(
                                    left: Utils.width! / 50,
                                    right: Utils.width! / 50,
                                    top: Utils.height! / 50,
                                    bottom: Utils.height! / 50),
                                width: Utils.width! / 3,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/break.png",
                                        width: Utils.width! / 15,
                                      ),
                                      SizedBox(
                                        width: Utils.width! / 50,
                                      ),
                                      const Text(
                                        "Break",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Microsoft YaHei',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.0,
                                            color: AppColors.textColor1),
                                      ).tr(),
                                    ]),
                              ),
                            ),
                          )),
                      SizedBox(
                        width: Utils.width! / 15,
                      ),
                      Obx(
                        () => Flexible(
                          child: GestureDetector(
                            onTap: () {
                              if (controller.startLunchBreak.value == true) {
                                Get.snackbar(tr('Message'),
                                    tr('You cannot start travel in between your break.'),
                                    backgroundColor: AppColors.containerColor8,
                                    colorText: AppColors.textColor1);
                              } else {
                                controller.clicked.value = false;
                                travelStartStopDialog(context);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0),
                                  border: Border.all(
                                      color: AppColors.breakTravelBorderColor),
                                  gradient: controller.startTravel.value == true
                                      ? const LinearGradient(colors: [
                                          AppColors.breakTravelGradientColor1,
                                          AppColors.breakTravelGradientColor2,
                                        ])
                                      : null),
                              padding: EdgeInsets.only(
                                  left: Utils.width! / 50,
                                  right: Utils.width! / 50,
                                  top: Utils.height! / 50,
                                  bottom: Utils.height! / 50),
                              width: Utils.width! / 3,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/travel.png",
                                      width: Utils.width! / 15,
                                    ),
                                    SizedBox(
                                      width: Utils.width! / 50,
                                    ),
                                    const Text(
                                      "Travel",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Microsoft YaHei',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15.0,
                                          color: AppColors.textColor1),
                                    ).tr(),
                                  ]),
                            ),
                          ),
                        ),
                      )
                    ],
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
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> breakStartStopDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              decoration: const BoxDecoration(
                  color: AppColors.containerColor4,
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              padding: EdgeInsets.only(
                  left: Utils.width! / 50,
                  right: Utils.width! / 50,
                  top: Utils.height! / 50,
                  bottom: Utils.height! / 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  controller.startLunchBreak.value
                      ? Text(
                          "Do you want to end your lunch break?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ).tr()
                      : Text(
                          "Do you want to start your lunch break?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ).tr(),
                  SizedBox(
                    height: Utils.height! / 20,
                  ),
                  Obx(() => controller.clicked.value
                      ? const Center(child: Loader())
                      : Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.clicked.value = true;
                                  if (controller.startLunchBreak.value ==
                                      false) {
                                    controller.breakIn();
                                  } else if (controller.startLunchBreak.value ==
                                      true) {
                                    controller.breakOut();
                                  }
                                },
                                child: Container(
                                  height: Utils.height! / 20,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      gradient: const LinearGradient(colors: [
                                        AppColors
                                            .dialogButtonGreenGradientColor1,
                                        AppColors
                                            .dialogButtonGreenGradientColor2
                                      ])),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "Yes",
                                      style: TextStyle(
                                          fontFamily: 'Microsoft YaHei',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18.0,
                                          color: AppColors.textColor1),
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Utils.width! / 20,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(Get.overlayContext!,
                                          rootNavigator: true)
                                      .pop();
                                  controller.clicked.value = true;
                                },
                                child: Container(
                                  height: Utils.height! / 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    gradient: const LinearGradient(colors: [
                                      AppColors.dialogButtonRedGradientColor1,
                                      AppColors.dialogButtonRedGradientColor2
                                    ]),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "No",
                                      style: TextStyle(
                                          fontFamily: 'Microsoft YaHei',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18.0,
                                          color: AppColors.textColor1),
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                ],
              ),
            ),
          );
        });
  }

  Future<dynamic> travelStartStopDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              decoration: const BoxDecoration(
                  color: AppColors.containerColor4,
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              padding: EdgeInsets.only(
                  left: Utils.width! / 50,
                  right: Utils.width! / 50,
                  top: Utils.height! / 50,
                  bottom: Utils.height! / 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  controller.startTravel.value
                      ? Text(
                          "Have you reached your job location?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ).tr()
                      : Text(
                          "Do you want to travel to another job location?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ).tr(),
                  SizedBox(
                    height: Utils.height! / 20,
                  ),
                  Obx(() => controller.clicked.value
                      ? const Center(child: Loader())
                      : Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.clicked.value = true;
                                  if (controller.startTravel.value == false) {
                                    controller.travelIn();
                                  } else if (controller.startTravel.value ==
                                      true) {
                                    controller.travelOut();
                                  }
                                },
                                child: Container(
                                  height: Utils.height! / 20,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      gradient: const LinearGradient(colors: [
                                        AppColors
                                            .dialogButtonGreenGradientColor1,
                                        AppColors
                                            .dialogButtonGreenGradientColor2
                                      ])),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "Yes",
                                      style: TextStyle(
                                          fontFamily: 'Microsoft YaHei',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18.0,
                                          color: AppColors.textColor1),
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Utils.width! / 20,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(Get.overlayContext!,
                                          rootNavigator: true)
                                      .pop();
                                  controller.clicked.value = true;
                                },
                                child: Container(
                                  height: Utils.height! / 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    gradient: const LinearGradient(colors: [
                                      AppColors.dialogButtonRedGradientColor1,
                                      AppColors.dialogButtonRedGradientColor2
                                    ]),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "No",
                                      style: TextStyle(
                                          fontFamily: 'Microsoft YaHei',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18.0,
                                          color: AppColors.textColor1),
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                ],
              ),
            ),
          );
        });
  }
}
