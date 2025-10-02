import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/auth/login_controller.dart';
import 'package:human_resources/core/services/SharedPreferences.dart';
import 'package:human_resources/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    Get.put(LoginControllerImp(), permanent: true);

  await initialServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      getPages: routes,
    );
  }
}
