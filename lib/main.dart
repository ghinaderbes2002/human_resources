import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/core/constant/App_routes.dart';
import 'package:human_resources/core/services/SharedPreferences.dart';
import 'package:human_resources/core/services/push_notification_service.dart';
import 'package:human_resources/firebase_options.dart';
import 'package:human_resources/routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (الإشعارات الفورية)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  await PushNotificationService.instance.init();

  // تحميل الخدمات
  await initialServices();
  final myServices = await Get.putAsync(() => MyServices().init());

  bool isLoggedIn = myServices.sharedPref.getBool("isLoggedIn") ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));

  if (isLoggedIn) {
    PushNotificationService.instance.registerDevice();
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HR App",
      initialRoute: isLoggedIn ? AppRoute.dashboardPage : AppRoute.login,
      getPages: routes,
    );
  }
}
