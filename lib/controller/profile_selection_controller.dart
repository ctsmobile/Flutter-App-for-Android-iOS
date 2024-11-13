import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:permission_handler/permission_handler.dart' as phandler;
import 'package:red_plastering/models/profileListmodel.dart';
import 'package:red_plastering/network/dioClient.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/utils/app_colors.dart';
import 'package:location/location.dart';

class ProfileSelectionScreenController extends GetxController {
  var currentTime = DateFormat.jm().format(DateTime.now()).obs;
  var isDataLoading = false.obs;
  var isGetDataLoading = false.obs;
  var listGet = true.obs;
  final profileListDataModel = ProfileList().obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  Location location = new Location();
  StreamSubscription<LocationData>? locationSubscription;
  final methodChannel = MethodChannel('com.redPlas.methodChannel');

  Future<String> callNativeCode() async {
    String lat = GetStorage().read('geofenceAssignedLatitude');
    String lon = GetStorage().read('geofenceAssignedLongitude');
    String token = GetStorage().read('token');
    String rang = GetStorage().read('geofenceRangeValue');
    try {
      const double milesToMeters = 1609.34;
      double miles = double.parse(rang);
      double rangeInmeters = miles * milesToMeters;

      if (rangeInmeters < 100) {
        rangeInmeters = 100;
      }

      print("lat $lat lon $lon token $token rang ${rangeInmeters.toString()}");
      var data = await methodChannel.invokeMethod('messageFunction', {
        "lat": lat,
        "lon": lon,
        "removeGeofence": "no",
        "token": token,
        "rang": rangeInmeters.toString()
      });

      print("datagg$data");
      return data;
    } on PlatformException catch (e) {
      print("dataggty${e.message}");

      return "Failed to Invoke: '${e.message}'.";
    }
  }

  @override
  void onInit() async {
    super.onInit();
    // await Alarm.stop(2);
    // final alarmSettings = AlarmSettings(
    //   id: 2,
    //   dateTime: DateTime.now().add(Duration(seconds: 30)),
    //   assetAudioPath: Platform.isAndroid
    //       ? 'assets/music/android_alarm.mp3'
    //       : 'assets/music/iphone_alarm.mp3',
    //   // loopAudio: false,
    //   vibrate: true,

    //   volume: 1,
    //   fadeDuration: 3.0,
    //   notificationTitle: 'Please open the app!',
    //   notificationBody:
    //       'Do break-out, otherwise you will be clocked-out automatically in next 5 minutes',
    // );
    // await Alarm.set(alarmSettings: alarmSettings);
    await getCurrentPosition();

    // getEmployeeState();
    await getProfileListData().then((value) {
      if (value != null) {
        listGet.value = false;
      }
    });
    Timer.periodic(const Duration(microseconds: 500), (timer) {
      currentTime.value = DateFormat.jm().format(DateTime.now()).obs.toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Future<bool> handleLocationPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
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

  // Future<void> getCurrentPosition() async {
  //   isDataLoading(true);
  //   final hasPermission = await handleLocationPermission();
  //   if (!hasPermission) return;

  //   if (Platform.isIOS) {
  //     var status = await Permission.locationWhenInUse.status;
  //     if (!status.isGranted) {
  //       var status = await Permission.locationWhenInUse.request();
  //       if (status.isGranted) {
  //         var status = await Permission.locationAlways.request();
  //         if (status.isGranted) {
  //           //Do some stuff
  //         } else {
  //           //Do another stuff
  //         }
  //       } else {
  //         //The user deny the permission
  //       }
  //       if (status.isPermanentlyDenied) {
  //         //When the user previously rejected the permission and select never ask again
  //         //Open the screen of settings
  //         bool res = await openAppSettings();
  //       }
  //     } else {
  //       //In use is available, check the always in use
  //       var status = await Permission.locationAlways.status;
  //       if (!status.isGranted) {
  //         var status = await Permission.locationAlways.request();
  //         if (status.isGranted) {
  //           //Do some stuff
  //         } else {
  //           //Do another stuff
  //         }
  //       } else {
  //         //previously available, do some stuff or nothing
  //       }
  //     }
  //   } else {
  //     var backgroundStatus = await Permission.locationAlways.request();

  //     if (!backgroundStatus.isGranted) {
  //       // Handle background permission denied
  //       return;
  //     }
  //   }

  //   //  await location.enableBackgroundMode(enable: true);
  //   await Geolocator.getCurrentPosition().then((Position position) async {
  //     latitude.value = position.latitude;
  //     longitude.value = position.longitude;
  //     isDataLoading(false);
  //     Get.snackbar('Position fetched:',
  //         latitude.value.toString() + longitude.value.toString(),
  //         backgroundColor: AppColors.containerColor8,
  //         colorText: AppColors.textColor1);
  //     print("LATITUDE,${latitude.value}");
  //     print("LONGITUDE,${longitude.value}");
  //   });
  // }

  Future<bool> enableBackgroundMode() async {
    bool _bgModeEnabled = await location.isBackgroundModeEnabled();
    if (_bgModeEnabled) {
      return true;
    } else {
      try {
        await location.enableBackgroundMode();
      } catch (e) {
        print(e.toString());
      }
      try {
        _bgModeEnabled = await location.enableBackgroundMode();
      } catch (e) {
        print(e.toString());
      }
      print(_bgModeEnabled);
      //True!
      if (!_bgModeEnabled) {
        _geolocatorPlatform.openAppSettings();
      }
      return _bgModeEnabled;
    }
  }

  Future<void> getCurrentPosition() async {
    isDataLoading(true);
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
        isDataLoading(false);
        Get.snackbar('Position fetched:',
            latitude.value.toString() + longitude.value.toString(),
            backgroundColor: AppColors.containerColor8,
            colorText: AppColors.textColor1);
        print("LATITUDE,${latitude.value}");
        print("LONGITUDE,${longitude.value}");
      });
    } else {
      final hasPermission = await handleLocationPermission();
      print("hasPermission$hasPermission");

      if (!await location.isBackgroundModeEnabled()) {
        print("hasPe");

        await enableBackgroundMode();
      }

      if (!hasPermission) return;
      print("hasPe2");
      locationSubscription = location.onLocationChanged.listen((event) {
        latitude.value = event.latitude!;
        longitude.value = event.longitude!;
        isDataLoading(false);
        Get.snackbar('Position fetched:',
            latitude.value.toString() + longitude.value.toString(),
            backgroundColor: AppColors.containerColor8,
            colorText: AppColors.textColor1);
        print("LATITUDE34,${latitude.value}");
        print("LONGITUDE21,${longitude.value}");
        locationSubscription!.pause();
      });
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
        print("TOKkEN,${GetStorage().read('token')}");
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
        } else if (response.data['message'] == "Failed") {
          print("entererrr here45");
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

  void clockIn(int jobId) {
    //callNativeCode("1234567","1234567","1234567","1234567");

    // getCurrentPosition();
    clockInApi(jobId).then((auth) async {
      if (auth != null) {
        print("auth.data${auth.data}");

        if (auth.data['message'] == "Success") {
          Get.snackbar(tr('ClockIn'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
          print("LATITUDE NEW,${auth.data}");
          await GetStorage().write(
              'geofenceAssignedLatitude', auth.data['latitude'].toString());
          await GetStorage().write(
              'geofenceAssignedLongitude', auth.data['longitude'].toString());
          await GetStorage()
              .write('geofenceRangeValue', auth.data['rangeVale'].toString());

          // callNativeCode();

          getEmployeeState();
          Get.offAllNamed(RouteConstant.clockOutScreen,
              parameters: {'impMsg': 'true'});
        } else if (auth.data['message'] == "Failed") {
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          Get.snackbar(tr('ClockIn'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        } else {
          // if (auth.data['frontendMessage'] ==
          //         "You are not in assigned location" ||
          //     auth.data['frontendMessage'] ==
          //         "Shift time has not started yet for this location" ||
          //     auth.data['frontendMessage'] ==
          //         "You cannot clock in twice in a day") {
          Get.back();
          // Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          Get.snackbar(tr('ClockIn'), auth.data['frontendMessage'],
              backgroundColor: AppColors.containerColor8,
              colorText: AppColors.textColor1);
        }
        //   } else {
        //     Get.snackbar(tr('ClockIn'), auth.data['frontendMessage'],
        //         backgroundColor: AppColors.containerColor8,
        //         colorText: AppColors.textColor1);
        //   }
        // }
      }
    });
  }

  Future<dio.Response?> clockInApi(int jobId) async {
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
          'jobId': jobId,
        };
        print("PARAMs,${params} ${latitude.value} ${longitude.value}");
        dio.Response response =
            await DioClient.dio.post(DioClient.baseUrl + "/clockin",
                data: params,
                options: dio.Options(
                    headers: {
                      'token': GetStorage().read('token'),
                      'latitude': latitude.value,
                      'longitude': longitude.value
                      // 'latitude': 28.781080,
                      // 'longitude': 77.497036
                    },
                    followRedirects: false,
                    validateStatus: (status) {
                      return status! < 500;
                    }));

        if (response.data['message'] == "Success") {
          log("BODY DATA CHECKIN,${response.data}");
          // GetStorage().write('checkin', response.data['data']['check_in']);
          print("BODY DATA STATUS CHECKIN,${response.data['frontendMessage']}");
          print("BODY DATA MESSAGE CHECKIN,${response.data['message']}");
          return response;
        } else {
          log("BODY DATA CHECKIN,${response.data}");
          print("BODY DATA STATUS CHECKIN,${response.data['frontendMessage']}");
          print("BODY DATA MESSAGE CHECKIN,${response.data['message']}");
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

  Future<ProfileList?> getProfileListData() async {
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
        isGetDataLoading(true);
        print("TOKEN,${GetStorage().read('token')}");
        dio.Response response = await DioClient.dio.get(
          DioClient.baseUrl + "/getJobTypes",
          options: dio.Options(
            headers: {
              'token': GetStorage().read('token'),
            },
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        );
        if (response.data['message'] == "Success") {
          profileListDataModel.value = ProfileList.fromJson(response.data);

          // log("BODY DATA PROFILE LIST,${response.data}");
          // print("BODY DATA STATUS PROFILE LIST,${response.data['status']}");
          print("BODY DATA MESSAGE PROFILE LIST,${response.data['message']}");
          return profileListDataModel.value;
        } else if (response.data['message'] == "Failed") {
          GetStorage().write('token', null);
          GetStorage().write('employeeState', null);
          Get.offAllNamed(RouteConstant.loginScreen);

          log("BODY DATA,${response.data}");
          // print("BODY DATA STATUS PROFILE LIST,${response.data['status']}");
          print("BODY DATA MESSAGE PROFILE LIST,${response.data['message']}");
          return profileListDataModel.value;
        } else {
          log("BODY DATA,${response.data}");
          // print("BODY DATA STATUS PROFILE LIST,${response.data['status']}");
          print("BODY DATA MESSAGE PROFILE LIST,${response.data['message']}");
          return profileListDataModel.value;
        }
      } catch (e) {
        log('Error while getting data is $e');
        print('Error while getting data is $e');
      } finally {
        isGetDataLoading(false);
      }
    }
  }
}
