import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import 'package:red_plastering/network/dioClient.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';

class ClockInScreenController extends GetxController {
  var currentTime = DateFormat.jm().format(DateTime.now()).obs;
  var currentClockTime = DateTime.now().obs;
  var isDataLoading = false.obs;
  var forcefullyClockedOut = Get.parameters['forcefullyClockedOut'];

  @override
  void onInit() {
    super.onInit();
    print("forcefullyClockedOut$forcefullyClockedOut");
    if (forcefullyClockedOut == 'true') {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Get.defaultDialog(
            barrierDismissible: false,
            content: Center(
                child: Text(
              tr('You are forcefully clocked out since you were away from location'),
              textAlign: TextAlign.center,
            )),
            onConfirm: () {
              Get.back();
            },
            confirmTextColor: Colors.white);
      });
    }

    Timer.periodic(const Duration(microseconds: 500), (timer) {
      currentTime.value = DateFormat.jm().format(DateTime.now()).obs.toString();
    });

    try {
      Timer.periodic(const Duration(minutes: 5), (timer) {
        getEmployeeState();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<dio.Response?> getEmployeeState() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
          msg: tr(
              "No internet connection available. Please turn on your wifi or mobile data"),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.containerColor8,
          textColor: AppColors.textColor1,
          fontSize: 16.0);
      return null;
    } else {
      try {
        isDataLoading(true);
        print("TOKEN,${GetStorage().read('token')}");
        dio.Response response =
            await DioClient.dio.get(DioClient.baseUrl + "/getEmployeeState",
                options: dio.Options(
                    headers: {
                      'token': GetStorage().read('token'),
                    },
                    followRedirects: false,
                    validateStatus: (status) {
                      return status! < 500;
                    }));
        print("employeestateresponse.data${response.data}");
        if (response.data['message'] == "Success") {
          log("BODY DATA EMPLOYEE STATE,${response.data}");
          GetStorage().write('employeeState', response.data['employeeState']);
          print(
              "BODY DATA STATUS EMPLOYEE STATE,${response.data['frontendMessage']}");
          print("BODY DATA MESSAGE EMPLOYEE STATE,${response.data['message']}");
          return response;
        } else if (response.data['message'] == "Failed") {
          print("entererrr here2");
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          log("BODY DATA EMPLOYEE STATE,${response.data}");
          print(
              "BODY DATA STATUS EMPLOYEE STATE,${response.data['frontendMessage']}");
          print("BODY DATA MESSAGE EMPLOYEE STATE,${response.data['message']}");
          return response;
        } else {
          log("BODY DATA EMPLOYEE STATE,${response.data}");
          print(
              "BODY DATA STATUS EMPLOYEE STATE,${response.data['frontendMessage']}");
          print("BODY DATA MESSAGE EMPLOYEE STATE,${response.data['message']}");
          return response;
        }
      } catch (e) {
        log('Error while getting data is $e');
        print('Error while getting data is $e');
      } finally {
        isDataLoading(false);
      }
    }
  }
}
