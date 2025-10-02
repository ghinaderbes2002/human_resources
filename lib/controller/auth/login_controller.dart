import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/constant/App_routes.dart';
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

  // String? validatePassword(String? value) {
  //   if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
  //   if (value.length < 6) return 'كلمة المرور يجب أن تكون 6 خانات على الأقل';
  //   return null;
  // }

  @override
login() async {
    if (formState.currentState!.validate()) {
      staterequest = Staterequest.loading;
      update();

      staterequest = await authService.loginUser(
        username: username.text,
        password: password.text,
      );

      update();

      if (staterequest == Staterequest.success) {
        Get.offAllNamed(AppRoute.dashboardPage);
      } else {
        Get.snackbar("فشل", "اسم المستخدم أو كلمة المرور غير صحيحة");
      }
    }
  }


  
  }

