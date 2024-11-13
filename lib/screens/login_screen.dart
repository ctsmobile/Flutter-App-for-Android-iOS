import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:red_plastering/controller/login_controller.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:red_plastering/utils/utils.dart';
import 'package:red_plastering/widgets/custom_loader.dart';
import 'package:toggle_switch/toggle_switch.dart';

class LoginScreen extends GetView<LoginScreenController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: Utils.width,
          height: Utils.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "assets/images/background.png",
                fit: BoxFit.cover,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: Utils.height! / 20,
                  ),
                  Expanded(
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: Utils.width! / 1.4,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Container(
                        width: Utils.width,
                        padding: EdgeInsets.only(
                            left: Utils.width! / 20,
                            right: Utils.width! / 20,
                            top: Utils.height! / 20,
                            bottom: Utils.height! / 20),
                        decoration: const BoxDecoration(
                            color: AppColors.containerColor1,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40.0),
                                topRight: Radius.circular(40.0))),
                        child: Form(
                          key: controller.loginFormKey,
                          child: Column(
                            children: [
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
                                initialLabelIndex: 0,
                                totalSwitches: 2,
                                labels: const ['English', 'Español'],
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
                                  controller.switchLanguage.value = index!;
                                  print('switched to: $index');
                                },
                              ),
                              SizedBox(
                                height: Utils.height! / 30,
                              ),
                              Obx(() => TextFormField(
                                    controller: controller.emailController,
                                    validator:
                                        controller.switchLanguage.value == 0
                                            ? controller.emailValidationEnglish
                                            : controller.emailValidationSpanish,
                                    textInputAction: TextInputAction.next,
                                    autofocus: true,
                                    onFieldSubmitted: (v) {
                                      FocusScope.of(context).requestFocus(
                                          controller.passwordFocus);
                                    },
                                    style: TextStyle(
                                        fontFamily: 'Microsoft YaHei',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.0,
                                        color: AppColors.textColor1
                                            .withOpacity(0.5)),
                                    decoration: InputDecoration(
                                      hintText:
                                          controller.switchLanguage.value == 0
                                              ? "Enter Email"
                                              : "Ingresar Correo electrónico",
                                      hintStyle: TextStyle(
                                          fontFamily: 'Microsoft YaHei',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15.0,
                                          color: AppColors.textColor1
                                              .withOpacity(0.5)),
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.only(
                                            left: Utils.width! / 50,
                                            right: Utils.width! / 50),
                                        child: Image.asset(
                                            "assets/images/user.png"),
                                      ),
                                      fillColor: AppColors.textColor1
                                          .withOpacity(0.05),
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.containerColor2
                                                  .withOpacity(0.7)),
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.containerColor2
                                                  .withOpacity(0.7)),
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.containerColor8),
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.containerColor8),
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                    ),
                                  )),
                              SizedBox(
                                height: Utils.height! / 50,
                              ),
                              Obx(() => TextFormField(
                                    controller: controller.passwordController,
                                    focusNode: controller.passwordFocus,
                                    validator: controller
                                                .switchLanguage.value ==
                                            0
                                        ? controller.passwordValidationEnglish
                                        : controller.passwordValidationSpanish,
                                    style: TextStyle(
                                        fontFamily: 'Microsoft YaHei',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.0,
                                        color: AppColors.textColor1
                                            .withOpacity(0.5)),
                                    decoration: InputDecoration(
                                      hintText:
                                          controller.switchLanguage.value == 0
                                              ? "Enter Password"
                                              : "Ingresar Contraseña",
                                      hintStyle: TextStyle(
                                          fontFamily: 'Microsoft YaHei',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15.0,
                                          color: AppColors.textColor1
                                              .withOpacity(0.5)),
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.only(
                                            left: Utils.width! / 50,
                                            right: Utils.width! / 50),
                                        child: Image.asset(
                                            "assets/images/password.png"),
                                      ),
                                      fillColor: AppColors.textColor1
                                          .withOpacity(0.05),
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.containerColor2
                                                  .withOpacity(0.7)),
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.containerColor2
                                                  .withOpacity(0.7)),
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.containerColor8),
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.containerColor8),
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                    ),
                                  )),
                              SizedBox(
                                height: Utils.height! / 20,
                              ),
                              Obx(
                                () => controller.isDataLoading.value
                                    ? const Loader()
                                    : GestureDetector(
                                        onTap: () {
                                          if (controller.switchLanguage.value ==
                                              0) {
                                            context
                                                .setLocale(const Locale('en'));
                                            Get.updateLocale(
                                                const Locale('en'));
                                          } else if (controller
                                                  .switchLanguage.value ==
                                              1) {
                                            context
                                                .setLocale(const Locale('es'));
                                            Get.updateLocale(
                                                const Locale('es'));
                                          }
                                          controller.login();
                                          // Get.offNamed(RouteConstant.clockInScreen);
                                        },
                                        child: controller
                                                    .switchLanguage.value ==
                                                0
                                            ? Image.asset(
                                                "assets/images/login.png")
                                            : Image.asset(
                                                "assets/images/spanishLogin.png")),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
