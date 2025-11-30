import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/core/constant/App_routes.dart';
import 'package:human_resources/core/services/SharedPreferences.dart';

class AuthMiddleware extends GetMiddleware {
  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    bool isLoggedIn = myServices.sharedPref.getBool("isLoggedIn") ?? false;

    if (!isLoggedIn) {
      // إذا المستخدم غير مسجل دخول → Login
      return RouteSettings(name: AppRoute.login);
    } else {
      // إذا مسجل دخول → Dashboard مباشرة
      return RouteSettings(name: AppRoute.dashboardPage);
    }
  }
}
