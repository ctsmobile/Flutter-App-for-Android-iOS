import 'dart:developer';
import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:red_plastering/models/userDataModel.dart';
import 'package:red_plastering/network/dioClient.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';

class LoginScreenController extends GetxController {
  var switchLanguage = 0.obs;
  var isDataLoading = false.obs;
  // final passwordController = TextEditingController(text: '123456');
  // final emailController = TextEditingController(text: 'ritik@gmail.com');
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final passwordFocus = FocusNode();
  final loginFormKey = GlobalKey<FormState>();
  final deviceId = "".obs;
  var result = "".obs;
  final _auth = FirebaseAuth.instance.obs;
  final _firestore = FirebaseFirestore.instance.obs;
  final userDataModel = UserDataModel().obs;
  var groupIdList = <GroupIds>[].obs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    if (GetStorage().read('userid') != null &&
        GetStorage().read('checkin') !=
            DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      Get.offNamed(RouteConstant.clockInScreen);
    } else if (GetStorage().read('userid') != null &&
        GetStorage().read('checkin') ==
            DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      Get.offNamed(RouteConstant.clockOutScreen);
    }
    getDeviceID().then((value) {
      deviceId.value = value!;
    });
    requestNotificationPermissions();
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    Get.delete<LoginScreenController>();
    super.dispose();
  }

  getFirebaseToken() async {
    await FirebaseMessaging.instance.getToken().then(
      (value) {
        if (value != null) {
          print("Token,${value}");
          GetStorage().write('fcmtoken', value);
          getFirebaseMessages();
        }
      },
    );
  }

  getFirebaseMessages() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
// var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, sound: true, badge: true);
    FirebaseMessaging.onMessage.listen((event) {
      print("Message Title,${event.notification!.title}");
      print("Message Data,${event.data}");
      print("Message Body,${event.notification!.body}");
      // print("ID,${jsonDecode(event.data['payload'])}");
      // print("ID,${event.data['payload']}");
      // print("ID,${event.data['data_id']}");

      RemoteNotification notification = event.notification!;
      AndroidNotification android = event.notification!.android!;
      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      // ignore: unnecessary_null_comparison
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: android.smallIcon,
                // other properties...
              ),
            ));
      }

      // dashboardScreenController.getTodaysAssignTaskList();
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      print("Message Title Opened App,${event.notification!.title}");
      print("Message Body Opened App,${event.notification!.body}");
      await GetStorage().write('ChatIndex', 0);
      Get.toNamed(RouteConstant.chatScreen);
      if (event.data.isNotEmpty) {
        _handleMessage(event);
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    print("Message Data,${message.data}");
  }

  Future<void> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      final PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        // Notification permissions granted
        getFirebaseToken();
      } else if (status.isDenied) {
        // Notification permissions denied
        Permission.notification.request();
      }
      // else if (status.isPermanentlyDenied) {
      //   // Notification permissions permanently denied, open app settings
      //   await openAppSettings();
      // }
    } else if (Platform.isIOS) {
      FirebaseMessaging.instance.requestPermission().then((value) {
        getFirebaseToken();
      });
    }
  }

  Future<String?> getDeviceID() async {
    // var deviceInfo = DeviceInfoPlugin();

    var androidIdPlugin = AndroidId();
    if (Platform.isAndroid) {
      var androidId = await androidIdPlugin.getId();
      return androidId; // unique ID on Android
    } else if (Platform.isIOS) {
      // var iosDeviceInfo = await deviceInfo.iosInfo;
      return await FlutterUdid.udid; // unique ID on iOS
    }
    return null;
  }

  String? passwordValidationEnglish(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please fill this field';
    }
    return null;
  }

  String? passwordValidationSpanish(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor llenar esta campo';
    }
    return null;
  }

  String? emailValidationEnglish(String? value) {
    RegExp regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (value == null || value.isEmpty) {
      return 'Please fill this field';
    } else if (!regex.hasMatch(value)) {
      return 'Enter valid Email';
    }
    return null;
  }

  String? emailValidationSpanish(String? value) {
    RegExp regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (value == null || value.isEmpty) {
      return 'Por favor llenar esta campo';
    } else if (!regex.hasMatch(value)) {
      return 'Ingresar válida Correo electrónico';
    }
    return null;
  }

  void login() {
    if (loginFormKey.currentState!.validate()) {
      loginApi(emailController.text, passwordController.text)
          .then((auth) async {
        if (auth != null) {
          print("auth.data${auth.data}");

          if (auth.data['message'] == "Success") {
            if (auth.data['uid'] == null) {
              await registerUserFirebase(
                  emailController.text,
                  passwordController.text,
                  auth.data['name'],
                  auth.data['phoneNumber']);

              // Get.offNamed(RouteConstant.clockInScreen);
            } else {
              print("ssaweer");

              logInUserFirebase(emailController.text, passwordController.text)
                  .then((value) {
                if (value == 'success') {
                  Get.snackbar(tr('Login'), tr('Successful login'),
                      backgroundColor: AppColors.containerColor8,
                      colorText: AppColors.textColor1);
                  if (GetStorage().read('employeeState') == "checkedIn" ||
                      GetStorage().read('employeeState') == "travelIn" ||
                      GetStorage().read('employeeState') == "travelOut" ||
                      GetStorage().read('employeeState') == "breakIn" ||
                      GetStorage().read('employeeState') == "breakOut") {
                    Get.offNamed(RouteConstant.clockOutScreen);
                  } else {
                    Get.offNamed(RouteConstant.clockInScreen);
                  }
                } else {
                  Get.snackbar(tr('Login'), tr(value.toString()),
                      backgroundColor: AppColors.containerColor8,
                      colorText: AppColors.textColor1);
                }
              });
            }
            // Get.snackbar(tr('Login'), tr(auth.data['frontendMessage']),
            //     backgroundColor: AppColors.containerColor8,
            //     colorText: AppColors.textColor1);
            // Get.offNamed(RouteConstant.clockInScreen);
          } else {
            Get.snackbar(tr('Login'), auth.data['frontendMessage'],
                backgroundColor: AppColors.containerColor8,
                colorText: AppColors.textColor1);
          }
        }
      });
    }
  }

  void addUID(String uid, String name, String number) {
    addUIDApi(uid, name, number).then((auth) {
      if (auth != null) {
        if (auth.data['message'] == "Success") {
          Get.snackbar(tr('Login'), auth.data['message'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          Get.offNamed(RouteConstant.clockInScreen);
        } else {
          Get.snackbar(tr('Login'), auth.data['message'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        }
      }
    });
  }

  Future<String> registerUserFirebase(String? email, String? password,
      String? name, String? phoneNumber) async {
    result.value = 'Some error occurred';
    try {
      print("bvbvbvb");

      if (email!.isNotEmpty || password!.isNotEmpty) {
        print("jhjjhhj$email");
        await _auth.value
            .createUserWithEmailAndPassword(email: email, password: password!)
            .then((value) {
          print("dddID,${value.user!.uid}");

          addUID(value.user!.uid, name.toString(), phoneNumber.toString());
        });
      }
    } catch (err) {
      print("eee${err.toString()}");
      if (err
          .toString()
          .contains('email address is already in use by another account')) {
        if (GetStorage().read('employeeState') == "checkedIn" ||
            GetStorage().read('employeeState') == "travelIn" ||
            GetStorage().read('employeeState') == "travelOut" ||
            GetStorage().read('employeeState') == "breakIn" ||
            GetStorage().read('employeeState') == "breakOut") {
          Get.offNamed(RouteConstant.clockOutScreen);
        } else {
          Get.offNamed(RouteConstant.clockInScreen);
        }
      } else {
        result.value = err.toString();
        Get.snackbar(tr('Register'), tr(err.toString()),
            backgroundColor: AppColors.containerColor8,
            colorText: AppColors.textColor1);
      }
    }
    return result.value;
  }

  Future<String> logInUserFirebase(
    String email,
    String password,
  ) async {
    result.value = 'Some error occurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        print("email$email password$password");
        // Get.snackbar(tr('Login-firebase'),
        //     tr("${email.toString()}, ${password.toString()}"),
        //     backgroundColor: AppColors.containerColor8,
        //     colorText: AppColors.textColor1);
        await _auth.value
            .signInWithEmailAndPassword(email: email, password: password);
        result.value = 'success';
      }
    } catch (err) {
      if (err.toString().contains('user may have been deleted')) {
        result.value = 'success';
      } else {
        result.value = err.toString();
      }
    }
    return result.value;
  }

  Future<dio.Response?> addUIDApi(
      String uid, String name, String phoneNumber) async {
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

        var params = {
          'uid': uid,
        };
        print("PARAMs,${params}");
        dio.Response response =
            await DioClient.dio.post(DioClient.baseUrl + "/addUid",
                data: params,
                options: dio.Options(
                    headers: {
                      'token': GetStorage().read('token'),
                    },
                    followRedirects: false,
                    validateStatus: (status) {
                      return status! < 500;
                    }));

        if (response.data['message'] == "Success") {
          // GroupIds groupIds = GroupIds();
          // groupIds.peerId = uid;
          // groupIds.peerName = name;
          // groupIdList.add(groupIds);
          userDataModel.value = UserDataModel(
              name: name,
              id: uid,
              phoneNumber: phoneNumber,
              groupIds: [],
              email: GetStorage().read('email'),
              fcmToken: GetStorage().read('fcmtoken'));
          print("USERDATA MODEL ID,${userDataModel.value.id}");
          print("USERDATA MODEL NAME,${userDataModel.value.name}");
          print("USERDATA MODEL NUMBER,${userDataModel.value.phoneNumber}");

          await _firestore.value.collection('UserListing').doc(uid).set(
                userDataModel.value.toJson(),
              );
          result.value = 'success';
          log("BODY DATA ADD UID,${response.data}");
          print("BODY DATA STATUS ADD UID,${response.data['message']}");
          print(
              "BODY DATA MESSAGE ADD UID,${response.data['frontendMessage']}");
          return response;
        } else {
          log("BODY DATA ADD UID,${response.data}");
          print("BODY DATA STATUS ADD UID,${response.data['message']}");
          print(
              "BODY DATA MESSAGE ADD UID,${response.data['frontendMessage']}");
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

        if (response.data['message'] == "Success") {
          log("BODY DATA EMPLOYEE STATE,${response.data}");
          GetStorage().write('employeeState', response.data['employeeState']);
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

  Future<dio.Response?> loginApi(String email, String password) async {
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
        print("DEVICE ID,${deviceId.toString()}");
        var params = {
          'email': email,
          'password': password,
          'deviceId': deviceId.toString(),
          // 'device': Platform.isIOS ? 'ios' : 'android',
          "fcmKey": GetStorage().read('fcmtoken')
        };
        print("PARAMs,${params}");
        dio.Response response =
            await DioClient.dio.post(DioClient.baseUrl + "/login",
                data: params,
                options: dio.Options(
                    headers: {
                      'lang': switchLanguage.value == 0 ? "en" : "es",
                    },
                    followRedirects: false,
                    validateStatus: (status) {
                      return status! < 500;
                    }));

        if (response.data['message'] == "Success") {
          log("BODY DATA LOGIN,${response.data}");
          GetStorage().write('email', email);
          GetStorage().write('token', response.data['token']);
          GetStorage().write('employeeName', response.data['name']);
          GetStorage().write('employeePhone', response.data['phoneNumber']);
          await getEmployeeState();
          // GetStorage().write('userid', response.data['data']['user_id']);
          // if (response.data['data']['checkin'] != "") {
          //   GetStorage().write('checkin', response.data['data']['checkin']);
          // }
          print("API TOKEN,${response.data['token']}");
          print("BODY DATA STATUS LOGIN,${response.data['message']}");
          print("BODY DATA MESSAGE LOGIN,${response.data['frontendMessage']}");
          return response;
        } else {
          log("BODY DATA LOGIN,${response.data}");
          print("BODY DATA STATUS LOGIN,${response.data['message']}");
          print("BODY DATA MESSAGE LOGIN,${response.data['frontendMessage']}");
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
