import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:human_resources/controller/auth/login_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginControllerImp());
  }
}
