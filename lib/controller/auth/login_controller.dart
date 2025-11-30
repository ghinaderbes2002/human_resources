import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/constant/App_routes.dart';
import 'package:human_resources/core/services/SharedPreferences.dart';
import 'package:human_resources/core/services/auth/auth_service.dart';

abstract class LoginController extends GetxController {
  login();
}

class LoginControllerImp extends LoginController {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController username;
  late TextEditingController password;

  Staterequest staterequest = Staterequest.none;
  bool isPasswordHidden = true;

  final AuthService authService = AuthService();
  MyServices myServices = Get.find();

  @override
  void onInit() {
    username = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  @override
  login() async {
    if (formState.currentState!.validate()) {
      staterequest = Staterequest.loading;
      update(); // لتحديث واجهة المستخدم وإظهار loading

      staterequest = await authService.loginUser(
        username: username.text,
        password: password.text,
      );

      update(); // لتحديث واجهة المستخدم بعد النتيجة

      if (staterequest == Staterequest.success) {
        await myServices.sharedPref.setBool("isLoggedIn", true);
        Get.offAllNamed(
          AppRoute.dashboardPage,
        ); // يروح للداشبورد ويمنع الرجوع للـ Login
      } else {
        Get.snackbar("فشل", "اسم المستخدم أو كلمة المرور غير صحيحة");
      }
    }
  }
}
