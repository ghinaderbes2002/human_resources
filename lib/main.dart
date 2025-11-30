import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/core/constant/App_routes.dart';
import 'package:human_resources/core/services/SharedPreferences.dart';
import 'package:human_resources/routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل الخدمات
  await initialServices();
  final myServices = await Get.putAsync(() => MyServices().init());

  bool isLoggedIn = myServices.sharedPref.getBool("isLoggedIn") ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
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
