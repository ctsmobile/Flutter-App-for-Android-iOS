// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as phandler;
import 'package:red_plastering/main.dart';
// import 'package:location/location.dart';
import 'package:red_plastering/network/dioClient.dart';
import 'package:red_plastering/routes.dart';
import 'package:dio/dio.dart' as dio;
import 'package:red_plastering/utils/app_colors.dart';

class ClockOutScreenController extends GetxController {
  var currentTime = DateFormat.jm().format(DateTime.now()).obs;
  var currentClockTime = DateTime.now().obs;
  var startLunchBreak = false.obs;
  var startTravel = false.obs;
  var clicked = false.obs;
  var isDataLoading = false.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var impMsg = Get.parameters['impMsg'];
  var isShowDialog = false.obs;
  Completer completer = Completer();
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  Location location = new Location();
  StreamSubscription<LocationData>? locationSubscription;

  Timer? mainTimer;
  Timer? breakInTimer;
  Timer? travelInTimer;

  static const methodChannel = MethodChannel('com.redPlas.methodChannel');
  Future callNativeCode(
      {bool removeGeofence = false, bool clockedOut = false}) async {
    if (GetStorage().read('geofenceAssignedLatitude') != null) {
    } else {
      Get.snackbar(tr('Message:'), tr('Something went wrong!!'),
          backgroundColor: AppColors.containerColor8,
          colorText: AppColors.textColor1);
    }
  }

  @override
  void onInit() async {
    super.onInit();

    final status = await phandler.Permission.scheduleExactAlarm.status;
    print('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      print('Requesting schedule exact alarm permission...');
      final res = await phandler.Permission.scheduleExactAlarm.request();
      print(
          'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.');
    }

    print("enter in initt");
    GetStorage().write('isShowDialog', false);

    methodChannel.setMethodCallHandler((call) async {
      try {
        if (call.method == "callMyFunction") {
          print("Received in flutter${call.arguments}");

          var value = call.arguments;
          if (value == 'userExits') {
            callTimer(userExits: true);
          } else if (value == 'userEnters') {
            if (GetStorage().read('isShowDialog') == true) {
              Get.back();
              GetStorage().write('isShowDialog', false);
            }

            if (mainTimer != null) {
              mainTimer!.cancel();
            }
          }
        }
      } catch (e) {
        print("gffg${e.toString()}");
      }
    });

    print("impMsg$impMsg");
    currentClockTime.value = DateTime.now();
    if (impMsg == 'true') {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Get.defaultDialog(
            barrierDismissible: false,
            content: Center(
                child: Text(
              tr('Please do not close the app in background. This is to avoid accurate calculation of work hours.'),
              textAlign: TextAlign.center,
            )),
            onConfirm: () {
              Get.back();
            },
            confirmTextColor: Colors.white);
      });
    }
    // getEmployeeState();
    getCurrentPosition();

    Timer.periodic(const Duration(microseconds: 500), (timer) {
      currentTime.value = DateFormat.jm().format(DateTime.now()).obs.toString();
    });

    callTimer();
  }

  callTimer({bool userExits = false}) {
    if (mainTimer != null) {
      mainTimer!.cancel();
    }

    print("enter in calltimer");
    try {
      if (userExits) {
        GetStorage().write('isShowDialog', true);
        Get.defaultDialog(
            barrierDismissible: false,
            content: const Center(
                child: Text(
              'You are away from the work location',
              textAlign: TextAlign.center,
            )),
            onConfirm: () {
              Get.back();
              GetStorage().write('isShowDialog', false);
            },
            confirmTextColor: Colors.white);
      }
      mainTimer = Timer.periodic(
          userExits ? const Duration(minutes: 5) : const Duration(minutes: 59),
          (timer) async {
        if (userExits && GetStorage().read('employeeState') != 'checkedOut') {
          print("ghhhg");
          // if (GetStorage().read('isShowDialog') == true) {
          //   GetStorage().write('isShowDialog', false);
          //   Navigator.of(Get.overlayContext!).pop();
          // }
          // _isThereCurrentDialogShowing(BuildContext context) {
          //   if (ModalRoute.of(context)?.isCurrent != true) {
          //     Navigator.of(Get.overlayContext!).pop();
          //   }
          // }

          await getCurrentPosition(callFromTimer: true);
        }
      });
    } catch (e) {
      print("gggfgg${e.toString()}");
    }
  }

  // Future<bool> handleLocationPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     Get.snackbar(tr('Message:'),
  //         tr('Location services are disabled. Please enable the services'),
  //         backgroundColor: AppColors.containerColor8,
  //         colorText: AppColors.textColor1);

  //     return false;
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       Get.snackbar(tr('Message:'), tr('Location permissions are denied'),
  //           backgroundColor: AppColors.containerColor8,
  //           colorText: AppColors.textColor1);
  //       return false;
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     Get.snackbar(tr('Message:'),
  //         tr('Location permissions are permanently denied, we cannot request permissions.'),
  //         backgroundColor: AppColors.containerColor8,
  //         colorText: AppColors.textColor1);

  //     return false;
  //   }
  //   return true;
  // }

  // Future<bool> handleLocationPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // _geolocatorPlatform.requestPermission();

  //     return false;
  //   }

  //   permission = await _geolocatorPlatform.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await _geolocatorPlatform.requestPermission();
  //   }

  //   return true;
  // }
  Future<bool> handleLocationPermission() async {
    if (Platform.isIOS) {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      permission = await _geolocatorPlatform.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _geolocatorPlatform.requestPermission();
      }

      return true;
    } else {
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          Get.snackbar(tr('Message:'),
              tr('Location services are disabled. Please enable the services'),
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          return false;
        }
      }

      _permissionGranted = await location.hasPermission();
      print("_permissionGranted$_permissionGranted");
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return true;
        }
      }
      print("_permissionGranted2nd$_permissionGranted");

      return true;
    }
  }

  Future<void> getCurrentPosition(
      {bool onlyGetLocation = false, bool callFromTimer = false}) async {
    if (Platform.isIOS) {
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) return;
      var status = await phandler.Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        var status = await phandler.Permission.locationWhenInUse.request();
        if (status.isGranted) {
          var status = await phandler.Permission.locationAlways.request();
          if (status.isGranted) {
            //Do some stuff
          } else {
            //Do another stuff
          }
        } else {
          //The user deny the permission
        }
        if (status.isPermanentlyDenied) {
          //When the user previously rejected the permission and select never ask again
          //Open the screen of settings
          bool res = await phandler.openAppSettings();
        }
      } else {
        //In use is available, check the always in use
        var status = await phandler.Permission.locationAlways.status;
        if (!status.isGranted) {
          var status = await phandler.Permission.locationAlways.request();
          if (status.isGranted) {
            //Do some stuff
          } else {
            //Do another stuff
          }
        } else {
          //previously available, do some stuff or nothing
        }
      }
      await Geolocator.getCurrentPosition().then((Position position) async {
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        currentClockTime.value = DateTime.now();
        Get.snackbar('Position fetched:',
            latitude.value.toString() + longitude.value.toString(),
            backgroundColor: AppColors.containerColor8,
            colorText: AppColors.textColor1);
        print("LATITUDE,${latitude.value}");
        print("LONGITUDE,${longitude.value}");
        if (!onlyGetLocation) {
          await getEmployeeState();
          await getLocationUpdateApi();
        }
      });
    } else {
      LocationData locationData;
      print("get current position");
      final hasPermission = await handleLocationPermission();
      print("vvv1");

      // await location.enableBackgroundMode(enable: true);
      await enableBackgroundMode();
      print("vvv2$hasPermission");

      if (!hasPermission) throw Exception("Location permission not granted");
      if (callFromTimer) {
        print("hgg");
        locationData = await location.getLocation();
        latitude.value = locationData.latitude!;
        longitude.value = locationData.longitude!;
        currentClockTime.value = DateTime.now();
        Get.snackbar('Position fetched:',
            latitude.value.toString() + longitude.value.toString(),
            backgroundColor: AppColors.containerColor8,
            colorText: AppColors.textColor1);
        print("LATITUDE,${latitude.value}");
        print("LONGITUDE,${longitude.value}");
        if (!onlyGetLocation) {
          await getEmployeeState();
          await getLocationUpdateApi();
        }
      } else {
        print("dertf");
        // locationData = await location.getLocation();
        locationSubscription = location.onLocationChanged.listen((event) async {
          print("vvv3");

          latitude.value = event.latitude!;
          longitude.value = event.longitude!;
          // location

          locationSubscription!.pause();

          currentClockTime.value = DateTime.now();
          Get.snackbar('Position fetched:',
              latitude.value.toString() + longitude.value.toString(),
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          print("LATITUDE,${latitude.value}");
          print("LONGITUDE,${longitude.value}");
          if (!onlyGetLocation) {
            await getEmployeeState();
            await getLocationUpdateApi();
          }
        });
      }
    }
  }

  Future<bool> enableBackgroundMode() async {
    bool _bgModeEnabled = await location.isBackgroundModeEnabled();
    print("_bgModeEnabled$_bgModeEnabled");
    if (_bgModeEnabled) {
      return true;
    } else {
      try {
        await location.enableBackgroundMode();
      } catch (e) {
        print("bvgt65${e.toString()}");
      }
      try {
        _bgModeEnabled = await location.enableBackgroundMode();
      } catch (e) {
        print(e.toString());
      }
      print("jjbbhh$_bgModeEnabled"); //True!
      if (!_bgModeEnabled) {
        _geolocatorPlatform.openAppSettings();
      }
      return _bgModeEnabled;
    }
  }

  Future<dio.Response?> getLocationUpdateApi() async {
    print(
        "inside getlocationupdateapi${latitude.value} ${longitude.value} ${GetStorage().read('token')}");
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
            await DioClient.dio.get(DioClient.baseUrl + "/checkLocation",
                options: dio.Options(
                    headers: {
                      'token': GetStorage().read('token'),
                      'latitude': latitude.value,
                      'longitude': longitude.value
                    },
                    followRedirects: false,
                    validateStatus: (status) {
                      return status! < 500;
                    }));

        print("getlocationupdateapi response.data${response.data} ");

        if (response.data['actionRequired'] == tr("SHOW_ALERT_BOX")) {
          // Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          // GetStorage().write('isShowDialog', true);
          if (GetStorage().read('isShowDialog') == false) {
            GetStorage().write('isShowDialog', true);
            Get.defaultDialog(
                barrierDismissible: false,
                content: Center(
                    child: Text(
                  tr(response.data['message'].toString()),
                  textAlign: TextAlign.center,
                )),
                onConfirm: () {
                  Get.back();
                  GetStorage().write('isShowDialog', false);
                },
                confirmTextColor: Colors.white);
          }
          // Get.defaultDialog(
          //   barrierDismissible: false,
          //   onWillPop: () async => false,
          //   content: Center(child: Text(response.data['message'])),
          //   // onConfirm: () {
          //   //   Future.delayed(Duration(minutes: 10), () {
          //   //     Get.back();
          //   //   });
          //   // },
          //   // confirmTextColor: Colors.white
          // );

          // Get.dialog(
          //     barrierDismissible: false,
          //     Dialog(
          //         backgroundColor: Colors.red,
          //         child: Container(
          //           padding: EdgeInsets.only(
          //               left: Utils.width! / 50,
          //               right: Utils.width! / 50,
          //               top: Utils.height! / 50,
          //               bottom: Utils.height! / 50),
          //           decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(10.0)),
          //           child: Column(
          //             children: [
          //               Text(
          //                 response.data['message'],
          //                 style: const TextStyle(
          //                     fontFamily: 'Microsoft YaHei',
          //                     fontWeight: FontWeight.w400,
          //                     fontSize: 14.0,
          //                     color: AppColors.textColor3),
          //               ),
          //               MaterialButton(
          //                 onPressed: () {},
          //                 color: AppColors.containerColor1,
          //                 child: Text(tr("OK"),
          //                     style: const TextStyle(
          //                         fontFamily: 'Microsoft YaHei',
          //                         fontWeight: FontWeight.w400,
          //                         fontSize: 14.0,
          //                         color: AppColors.textColor1)),
          //               )
          //             ],
          //           ),
          //         )));
          log("alert showw,${response.data}");

          return response;
        } else if (response.data['actionRequired'] == tr("BREAKED_OUT") ||
            response.data['actionRequired'] == tr("TRAVEL_OUT") ||
            response.data['actionRequired'] == tr("CLOCKED_OUT")) {
          // Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          await getEmployeeState();

          log("BODY DATA CURRENT LOCATION,${response.data}");

          return response;
        } else if (response.data['message'] == "Failed") {
          print("enterrrr here");
          // Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          log("BODY DATA CURRENT LOCATION,${response.data}");

          return response;
        } else {
          // Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          log("BODY DATA CURRENT LOCATION,${response.data}");

          return response;
        }
      } catch (e) {
        log('Error while getting data is Location $e');
        print('Error while getting data is $e');
      } finally {
        isDataLoading(false);
      }
    }
  }

  Future<dio.Response?> getEmployeeState() async {
    print("employee state ke ander");
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
        print("employee state response.data${response.data}");
        if (response.data['message'] == "Success") {
          log("EMPLOYEE STATE,${response.data}");
          await GetStorage()
              .write('employeeState', response.data['employeeState']);
          await GetStorage().write(
              'geofenceAssignedLatitude', response.data['latitude'].toString());
          await GetStorage().write('geofenceAssignedLongitude',
              response.data['longitude'].toString());
          await GetStorage().write(
              'geofenceRangeValue', response.data['rangeValue'].toString());
          if (response.data['employeeState'] == 'checkedIn') {
            callNativeCode();
            await Alarm.stop(1);
            await Alarm.stop(2);
          } else if (response.data['employeeState'] == 'breakIn') {
            startLunchBreak.value = true;

            callNativeCode(removeGeofence: true);
            print("nbbb${DateTime.now().toIso8601String()}");
            // await GetStorage()
            //     .write('breakInTime', '2024-05-31T18:21:50.227853');

            if (GetStorage().read('breakInTime') != null) {
              String storedDateTimeString = GetStorage().read('breakInTime');
              DateTime storedDateTime = DateTime.parse(storedDateTimeString);

              // Get the current DateTime
              DateTime currentDateTime = DateTime.now();

              // Calculate the difference in minutes
              int differenceInMinutes =
                  currentDateTime.difference(storedDateTime).inMinutes;

              print("differenceInMinutes$differenceInMinutes");

              int timeToCall = 62 - differenceInMinutes;

              print("timeToCall$timeToCall");

              if (timeToCall > 0) {
                try {
                  breakInTimer = Timer.periodic(Duration(minutes: timeToCall),
                      (timer) async {
                    if (GetStorage().read('employeeState') == 'breakIn') {
                      print("ritik--gyh");
                      GetStorage().write('breakInTime', null);

                      await getCurrentPosition(callFromTimer: true);
                    }

                    breakInTimer!.cancel();
                  });
                } catch (e) {
                  print("gggfgg${e.toString()}");
                }
              }

              await Alarm.stop(2);
              final alarmSettings = AlarmSettings(
                id: 2,
                dateTime: DateTime.now().add(Duration(minutes: timeToCall + 1)),
                assetAudioPath: Platform.isAndroid
                    ? 'assets/music/android_alarm.mp3'
                    : 'assets/music/iphone_alarm.mp3',
                // loopAudio: false,
                vibrate: true,
                volume: 1,
                fadeDuration: 3.0,
                notificationTitle: 'Please open the app!',
                notificationBody:
                    'Do break-out, otherwise you will be clocked-out automatically in next 5 minutes',
              );
              await Alarm.set(alarmSettings: alarmSettings);
            }
          } else if (response.data['employeeState'] == 'breakOut') {
            print(
                "herererrer${response.data} ${GetStorage().read('geofenceAssignedLatitude')}");

            callNativeCode();
            await Alarm.stop(2);

            startLunchBreak.value = false;
          }
          if (response.data['employeeState'] == 'travelIn') {
            startTravel.value = true;
            callNativeCode(removeGeofence: true);

            if (GetStorage().read('travelInTime') != null) {
              String storedDateTimeString = GetStorage().read('travelInTime');
              DateTime storedDateTime = DateTime.parse(storedDateTimeString);

              // Get the current DateTime
              DateTime currentDateTime = DateTime.now();

              // Calculate the difference in minutes
              int differenceInMinutes =
                  currentDateTime.difference(storedDateTime).inMinutes;

              print("differenceInMinutes$differenceInMinutes");

              int timeToCall = 62 - differenceInMinutes;
              if (timeToCall > 0) {
                try {
                  travelInTimer = Timer.periodic(Duration(minutes: timeToCall),
                      (timer) async {
                    if (GetStorage().read('employeeState') == 'travelIn') {
                      GetStorage().write('travelInTime', null);

                      await getCurrentPosition(callFromTimer: true);
                    }
                    travelInTimer!.cancel();
                  });
                } catch (e) {
                  print("gggfgg${e.toString()}");
                }

                await Alarm.stop(1);
                final alarmSettings = AlarmSettings(
                  id: 1,
                  dateTime:
                      DateTime.now().add(Duration(minutes: timeToCall + 1)),
                  assetAudioPath: Platform.isAndroid
                      ? 'assets/music/android_alarm.mp3'
                      : 'assets/music/iphone_alarm.mp3',
                  // loopAudio: false,
                  vibrate: true,
                  volume: 1,
                  fadeDuration: 3.0,
                  notificationTitle: 'Please open the app!',
                  notificationBody:
                      'Do travel-out, otherwise you will be clocked-out automatically in next 5 minutes',
                );
                await Alarm.set(alarmSettings: alarmSettings);
              }
            }
          } else if (response.data['employeeState'] == 'travelOut') {
            startTravel.value = false;

            callNativeCode();
            await Alarm.stop(1);
          }
          if (response.data['frontendMessage'] ==
              "You are forcefully clocked out since you were away from location") {
            // Get.snackbar(tr('Employee state'), response.data['frontendMessage'],
            //     backgroundColor: AppColors.containerColor8,
            //     colorText: AppColors.textColor1);
            await Alarm.stop(1);
            await Alarm.stop(2);
            if (mainTimer != null) {
              mainTimer!.cancel();
            }

            Get.offAllNamed(RouteConstant.clockInScreen,
                parameters: {'forcefullyClockedOut': 'true'});
            Get.snackbar(tr('ClockOut'), response.data['message'],
                backgroundColor: AppColors.containerColor8,
                colorText: AppColors.textColor1);
          }
          return response;
        } else if (response.data['message'] == "Failed") {
          print("entererrr here3");
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          log("BODY DATA EMPLOYEE STATE,${response.data}");
          return response;
        } else {
          log("BODY DATA EMPLOYEE STATE,${response.data}");
          return response;
        }
      } catch (e) {
        Get.snackbar(tr('employeeState'), e.toString(),
            backgroundColor: AppColors.containerColor8,
            colorText: AppColors.textColor1);
        log('Error while getting data is $e');
        print('Error while getting data is $e');
      } finally {
        isDataLoading(false);
      }
    }
  }

  void travelIn() async {
    await travelInApi().then((auth) async {
      if (auth != null) {
        if (auth.data['message'] == "Success") {
          DateTime now = DateTime.now();

          // Convert DateTime to a string
          String formattedDateTime = now.toIso8601String();
          GetStorage().write('travelInTime', formattedDateTime);
          await getEmployeeState().then((value) {
            if (value != null) {
              if (value.data['message'] == "Success") {
                Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
                Get.snackbar(tr('Travel Start'), auth.data['frontendMessage'],
                    backgroundColor: AppColors.containerColor8,
                    colorText: AppColors.textColor1);
              }
            }
          });
          startTravel.value = true;
          // if (startTravel.value == false) {
          //   startTravel.value = true;
          // } else {
          //   startTravel.value = false;
          // }
        } else if (auth.data['message'] == "Failed") {
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          Get.snackbar(tr('Travel Start'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        } else {
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          Get.snackbar(tr('Travel Start'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        }
      }
    });
  }

  Future travelOut() async {
    await travelOutApi().then((auth) async {
      if (auth != null) {
        if (auth.data['message'] == "Success") {
          GetStorage().write(
              'geofenceAssignedLatitude', auth.data['latitude'].toString());
          GetStorage().write(
              'geofenceAssignedLongitude', auth.data['longitude'].toString());
          GetStorage()
              .write('geofenceRangeValue', auth.data['rangeVale'].toString());

          await getEmployeeState().then((value) {
            if (value != null) {
              if (value.data['message'] == "Success") {
                Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
                Get.snackbar(tr('Travel End'), auth.data['frontendMessage'],
                    backgroundColor: AppColors.containerColor8,
                    colorText: AppColors.textColor1);
              }
            }
          });
          startTravel.value = false;
          // if (startLunchBreak.value == false) {
          //   startLunchBreak.value = true;
          // } else {
          //   startLunchBreak.value = false;
          // }
        } else if (auth.data['message'] == "Failed") {
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          Get.snackbar(tr('Travel End'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        } else {
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          Get.snackbar(tr('Travel End'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        }
      }
    });
  }

  Future breakIn({bool callFromTimer = false}) async {
    await breakInApi(callFromTimer: callFromTimer).then((auth) {
      if (auth != null) {
        if (auth.data['message'] == "Success") {
          DateTime now = DateTime.now();

          // Convert DateTime to a string
          String formattedDateTime = now.toIso8601String();
          GetStorage().write('breakInTime', formattedDateTime);
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          Get.snackbar(tr('Break Start'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          getEmployeeState();
          startLunchBreak.value = true;
          // if (startLunchBreak.value == false) {
          //   startLunchBreak.value = true;
          // } else {
          //   startLunchBreak.value = false;
          // }
        } else if (auth.data['message'] == "Failed") {
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          Get.snackbar(tr('Break Start'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        } else {
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          Get.snackbar(tr('Break Start'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        }
      }
    });
  }

  Future breakOut() async {
    await breakOutApi().then((auth) async {
      if (auth != null) {
        if (auth.data['message'] == "Success") {
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          Get.snackbar(tr('Break End'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          GetStorage().write(
              'geofenceAssignedLatitude', auth.data['latitude'].toString());
          GetStorage().write(
              'geofenceAssignedLongitude', auth.data['longitude'].toString());
          GetStorage()
              .write('geofenceRangeValue', auth.data['rangeVale'].toString());

          await getEmployeeState();

          startLunchBreak.value = false;

          print("ddserere");
        } else if (auth.data['message'] == "Failed") {
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          Get.snackbar(tr('Break End'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        } else {
          Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          Get.snackbar(tr('Break End'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        }
      }
    });
  }

  Future clockOut() async {
    await clockOutApi().then((auth) {
      print("bvbvbvb#$auth");
      if (auth != null) {
        if (auth.data['message'] == "Success") {
          callNativeCode(clockedOut: true);
          Get.snackbar(tr('ClockOut'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          getEmployeeState();
          // GetStorage().remove('checkin');
          Get.offAllNamed(RouteConstant.clockInScreen);
        } else if (auth.data['message'] == "Failed") {
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          Get.snackbar(tr('ClockOut'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        } else {
          Get.snackbar(tr('ClockOut'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        }
      }
    });
  }

  Future<dio.Response?> breakOutApi() async {
    await getCurrentPosition(onlyGetLocation: true);
    dynamic response = Future.delayed(Duration(seconds: 5), () async {
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
          print("latitude.breakout${latitude.value}");
          isDataLoading(true);
          dio.Response response =
              await DioClient.dio.get(DioClient.baseUrl + "/breakout",
                  options: dio.Options(
                      headers: {
                        'token': GetStorage().read('token'),
                        'latitude': latitude.value,
                        'longitude': longitude.value
                      },
                      followRedirects: false,
                      validateStatus: (status) {
                        return status! < 500;
                      }));

          if (response.data['message'] == "Success") {
            log("BODY DATA BREAKOUT,${response.data}");
            // GetStorage().write('checkout', response.data['data']['check_out']);
            return response;
          } else {
            Get.snackbar(tr('breakOut'), response.data.toString(),
                backgroundColor: AppColors.containerColor8,
                colorText: AppColors.textColor1);
            log("BODY DATA BREAKOUT,${response.data}");
            return response;
          }
        } catch (e) {
          Get.snackbar(tr('breakOut'), e.toString(),
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          log('Error while getting data is $e');
          print('Error while getting data is $e');
        } finally {
          isDataLoading(false);
        }
      }
    }).then((e) {
      print("bgvv$e");
      return e;
    });
    print("vvvv$response");

    return response;
  }

  Future<dio.Response?> travelOutApi() async {
    await getCurrentPosition(onlyGetLocation: true);
    dynamic response = Future.delayed(Duration(seconds: 5), () async {
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
          print("ggfgfg${latitude.value}");
          print("zzza${longitude.value}");
          isDataLoading(true);
          dio.Response response =
              await DioClient.dio.get(DioClient.baseUrl + "/travelOut",
                  options: dio.Options(
                      headers: {
                        'token': GetStorage().read('token'),
                        'latitude': latitude.value,
                        'longitude': longitude.value
                      },
                      followRedirects: false,
                      validateStatus: (status) {
                        return status! < 500;
                      }));

          if (response.data['message'] == "Success") {
            log("BODY DATA TRAVELOUT,${response.data}");
            // GetStorage().write('checkout', response.data['data']['check_out']);
            return response;
          } else {
            Get.snackbar(tr('travelOut'), response.data.toString(),
                backgroundColor: AppColors.containerColor8,
                colorText: AppColors.textColor1);
            log("BODY DATA TRAVELOUT,${response.data}");
            return response;
          }
        } catch (e) {
          Get.snackbar(tr('travelOut'), e.toString(),
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          log('Error while getting data is $e');
          print('Error while getting data is $e');
        } finally {
          isDataLoading(false);
        }
      }
    }).then((e) {
      return e;
    });

    return response;
  }

  Future<dio.Response?> breakInApi({bool callFromTimer = false}) async {
    await getCurrentPosition(
        onlyGetLocation: true, callFromTimer: callFromTimer);
    dynamic response = await Future.delayed(Duration(seconds: 5), () async {
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
              await DioClient.dio.get(DioClient.baseUrl + "/breakin",
                  options: dio.Options(
                      headers: {
                        'token': GetStorage().read('token'),
                        'latitude': latitude.value,
                        'longitude': longitude.value
                      },
                      followRedirects: false,
                      validateStatus: (status) {
                        return status! < 500;
                      }));

          if (response.data['message'] == "Success") {
            log("BODY DATA BREAKIN,${response.data}");
            // GetStorage().write('checkout', response.data['data']['check_out']);
            return response;
          } else {
            Get.snackbar(tr('breakIn'), response.data.toString(),
                backgroundColor: AppColors.containerColor8,
                colorText: AppColors.textColor1);
            log("error in breakin DATA BREAKIN,${response.data}");
            return response;
          }
        } catch (e) {
          Get.snackbar(tr('breakIn'), e.toString(),
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          log('Error while getting data is $e');
          print('Error while getting data is $e');
        } finally {
          isDataLoading(false);
        }
      }
    }).then((e) {
      return e;
    });

    return response;
  }

  Future<dio.Response?> travelInApi() async {
    await getCurrentPosition(onlyGetLocation: true);
    dynamic response = Future.delayed(Duration(seconds: 5), () async {
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
              await DioClient.dio.get(DioClient.baseUrl + "/travelIn",
                  options: dio.Options(
                      headers: {
                        'token': GetStorage().read('token'),
                        'latitude': latitude.value,
                        'longitude': longitude.value
                      },
                      followRedirects: false,
                      validateStatus: (status) {
                        return status! < 500;
                      }));

          if (response.data['message'] == "Success") {
            log("BODY DATA TRAVELIN,${response.data}");

            // GetStorage().write('checkout', response.data['data']['check_out']);
            return response;
          } else {
            Get.snackbar(tr('travelIn'), response.data.toString(),
                backgroundColor: AppColors.containerColor8,
                colorText: AppColors.textColor1);
            log("BODY DATA TRAVELIN,${response.data}");
            return response;
          }
        } catch (e) {
          Get.snackbar(tr('travelIn'), e.toString(),
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          log('Error while getting data is $e');
          print('Error while getting data is $e');
        } finally {
          isDataLoading(false);
        }
      }
    }).then((e) {
      return e;
    });

    return response;
  }

  Future<dio.Response?> clockOutApi() async {
    await getCurrentPosition(onlyGetLocation: true);
    dynamic response = await Future.delayed(Duration(seconds: 5), () async {
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
          print(
              "bvbvb${GetStorage().read('token')} bvb${latitude.value}  mmn${longitude.value}");
          isDataLoading(true);
          dio.Response response =
              await DioClient.dio.get(DioClient.baseUrl + "/clockout",
                  options: dio.Options(
                      headers: {
                        'token': GetStorage().read('token'),
                        'latitude': latitude.value,
                        'longitude': longitude.value
                      },
                      followRedirects: false,
                      validateStatus: (status) {
                        return status! < 500;
                      }));

          print("response.statusCode${response.data}");

          if (response.data['message'] == "Success") {
            log("BODY DATA CHECKOUT,${response.data}");
            // GetStorage().write('checkout', response.data['data']['check_out']);
            return response;
          } else {
            Get.snackbar(tr('clockOut'), response.data.toString(),
                backgroundColor: AppColors.containerColor8,
                colorText: AppColors.textColor1);
            log("BODY DATA CHECKOUT,${response.data}");
            return response.data;
          }
        } catch (e) {
          Get.snackbar(tr('checkOut!'), e.toString(),
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);

          log('Error while getting data is $e');
          print('Error while getting data is ${e.toString()}');
        } finally {
          isDataLoading(false);
        }
      }
    }).then((e) {
      return e;
    });

    print("bbbb$response");

    return response;
  }
}
