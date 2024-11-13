import 'package:alarm/alarm.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:red_plastering/binding/addmessage_binding.dart';
import 'package:red_plastering/binding/chat_binding.dart';
import 'package:red_plastering/binding/clockin_binding.dart';
import 'package:red_plastering/binding/clockout_binding.dart';
import 'package:red_plastering/binding/contactslist_binding.dart';
import 'package:red_plastering/binding/conversation_binding.dart';
import 'package:red_plastering/binding/login_binding.dart';
import 'package:red_plastering/binding/profile_selection_binding.dart';
import 'package:red_plastering/routes.dart';
import 'package:red_plastering/screens/addmessage_screen.dart';
import 'package:red_plastering/screens/chat_screen.dart';
import 'package:red_plastering/screens/clockin_screen.dart';
import 'package:red_plastering/screens/clockout_screen.dart';
import 'package:red_plastering/screens/contactslist_screen.dart';
import 'package:red_plastering/screens/conversation_screen.dart';
import 'package:red_plastering/screens/login_screen.dart';
import 'package:red_plastering/screens/profile_selection_screen.dart';
import 'package:red_plastering/utils/firebase_options.dart';
import 'package:red_plastering/utils/utils.dart';

Future<void> main() async {
  await GetStorage.init();

  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  await EasyLocalization.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path:
            'assets/translation', // <-- change the path of the translation files
        fallbackLocale: const Locale('en'),
        child: MyApp()),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Utils.width = MediaQuery.of(context).size.width;
    Utils.height = MediaQuery.of(context).size.height;
    print(
        "sssdddf${GetStorage().read('token')}  nnn${GetStorage().read('employeeState')}");
    return GetMaterialApp(
        title: 'Red\'s Plastering',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        // initialRoute: GetStorage().read('userid') != null &&
        //         GetStorage().read('checkin') !=
        //             DateFormat('yyyy-MM-dd').format(DateTime.now())
        //     ? RouteConstant.clockInScreen
        //     : GetStorage().read('userid') != null &&
        //             GetStorage().read('checkin') ==
        //                 DateFormat('yyyy-MM-dd').format(DateTime.now())
        //         ? RouteConstant.clockOutScreen
        //         : RouteConstant.loginScreen,
        initialRoute: GetStorage().read('token') != null &&
                    GetStorage().read('employeeState') == null ||
                GetStorage().read('employeeState') == 'checkedOut'
            ? RouteConstant.clockInScreen
            : GetStorage().read('token') != null &&
                        GetStorage().read('employeeState') == "checkedIn" ||
                    GetStorage().read('employeeState') == "travelIn" ||
                    GetStorage().read('employeeState') == "travelOut" ||
                    GetStorage().read('employeeState') == "breakIn" ||
                    GetStorage().read('employeeState') == "breakOut"
                ? RouteConstant.clockOutScreen
                : RouteConstant.loginScreen,
        theme: ThemeData(primaryColor: Colors.blueAccent),
        getPages: getPages);
  }

  List<GetPage> getPages = [
    GetPage(
        name: RouteConstant.loginScreen,
        page: () => const LoginScreen(),
        binding: LoginScreenBinding()),
    GetPage(
        name: RouteConstant.clockInScreen,
        page: () => const ClockInScreen(),
        binding: ClockInScreenBinding()),
    GetPage(
        name: RouteConstant.profileSelectionScreen,
        page: () => const ProfileSelectionScreen(),
        binding: ProfileSelectionScreenBinding()),
    GetPage(
        name: RouteConstant.clockOutScreen,
        page: () => const ClockOutScreen(),
        binding: ClockOutScreenBinding()),
    GetPage(
        name: RouteConstant.chatScreen,
        page: () => const ChatScreen(),
        binding: ChatScreenBinding()),
    GetPage(
        name: RouteConstant.addMessageScreen,
        page: () => const AddMessageScreen(),
        binding: AddMessageScreenBinding()),
    GetPage(
        name: RouteConstant.contactsListScreen,
        page: () => ContactsListScreen(),
        binding: ContactsListScreenBinding()),
    GetPage(
        name: RouteConstant.conversationScreen,
        page: () => const ConversationScreen(),
        binding: ConversationScreenBinding()),
  ];
}
