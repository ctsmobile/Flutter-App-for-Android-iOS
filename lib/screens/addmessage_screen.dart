import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:red_plastering/controller/addmessage_controller.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';

class AddMessageScreen extends GetView<AddMessageScreenController> {
  const AddMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    left: Utils.width! / 20,
                    right: Utils.width! / 20,
                    top: Utils.height! / 8,
                    bottom: Utils.height! / 20),
                child: Column(
                  children: [
                    Text(
                      controller.formattedDate.value,
                      style: TextStyle(
                          fontFamily: 'Microsoft YaHei',
                          fontWeight: FontWeight.w400,
                          fontSize: 15.0,
                          color: AppColors.textColor1.withOpacity(0.58)),
                    ),
                    SizedBox(
                      height: Utils.height! / 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: Utils.width! / 20,
                        right: Utils.width! / 20,
                      ),
                      height: Utils.height! / 4,
                      decoration: BoxDecoration(
                          color: AppColors.containerColor7,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: TextFormField(
                        maxLines: null,
                        controller: controller.textMessage.value,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: tr("Text Message..."),
                            hintStyle: GoogleFonts.roboto(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: AppColors.textColor1)),
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: AppColors.textColor1),
                      ),
                    ),
                    SizedBox(
                      height: Utils.height! / 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (controller.textMessage.value.text
                            .trim()
                            .isNotEmpty) {
                          Get.toNamed(RouteConstant.contactsListScreen,
                                  parameters: {
                                'textMessage':
                                    controller.textMessage.value.text.toString()
                              })!
                              .then((value) {
                            controller.removeSelection();
                          });
                        } else {
                          Get.snackbar(tr('Message'), tr('Please add msg.'),
                              backgroundColor: AppColors.containerColor8,
                              colorText: AppColors.textColor1);
                        }
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
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
