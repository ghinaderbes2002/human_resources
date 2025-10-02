import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/constant/App_routes.dart';
import 'package:human_resources/core/services/UserService.dart';
import 'package:human_resources/model/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  final UserService _service = UserService();

  UserModel? user;
  Staterequest staterequest = Staterequest.none;

  get passwordUpdateSuccess => null;
  
  


  // جلب بيانات مستخدم حسب الـ id
Future<void> fetchUser(int userId) async {
    staterequest = Staterequest.loading;
    update();

    user = await _service.getUser(userId);

    if (user != null) {
      print("User: ${user!.employee.fullName}");
      print("Branch: ${user!.branch?.name ?? 'لا يوجد فرع'}");
      print("Department: ${user!.department?.name ?? 'لا يوجد قسم'}");

      staterequest = Staterequest.success;
    } else {
      staterequest = Staterequest.failure;
    }

    update();
  }


  Future<void> updatePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    staterequest = Staterequest.loading;
    update();

    final result = await _service.changePassword(
      userId: userId,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    staterequest = result;
    update();

    if (result == Staterequest.success) {
      Get.snackbar("تم", "تم تغيير كلمة المرور بنجاح");
    } else {
      Get.snackbar("فشل", "تعذر تغيير كلمة المرور");
    }
  }

  Future<void> logout() async {
    // 1. مسح أي بيانات مستخدم محفوظة
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // يحذف كل البيانات المخزنة

    // 2. العودة لصفحة تسجيل الدخول
    Get.offAllNamed(AppRoute.login);
  }

}

