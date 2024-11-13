// import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:red_plastering/controller/clockin_controller.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';
import 'package:analog_clock/analog_clock.dart';

class ClockInScreen extends GetView<ClockInScreenController> {
  const ClockInScreen({super.key});

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
            //     padding: EdgeInsets.only(bottom: Utils.height! / 20),
            //     child: Image.asset(
            //       "assets/images/clocksbackgreen.png",
            //     ),
            //   ),
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Flexible(
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
                ),
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/clocksbackgreen.png",
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
                            width: Utils.width! / 1.6,
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
                      //     width: Utils.width! / 1.7,
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
                            // controller.clockIn();
                            // GetStorage().remove('userid');
                            // Get.offNamed(RouteConstant.loginScreen);
                            Get.toNamed(RouteConstant.profileSelectionScreen);
                          },
                          child: Image.asset(
                            "assets/images/start.png",
                            width: Utils.width! / 6,
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
}
