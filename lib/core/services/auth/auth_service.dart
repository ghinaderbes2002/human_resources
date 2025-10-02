import 'dart:convert';
import 'package:get/get.dart';
import 'package:human_resources/core/classes/api_client.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/constant/App_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient apiClient = ApiClient();


Future<Staterequest> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final url = '${ServerConfig().serverLink}/auth/login';
      print("Full login URL: $url");

      ApiResponse<dynamic> response = await apiClient.postData(
        url: url,
        data: {'username': username.trim(), 'password': password.trim()},
      );

      print("Login Response Status: ${response.statusCode}");
      print("Login Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final token = responseData["token"];
          final user = responseData["user"];

          // استخراج id و full_name الموظف
          final employeeId = user["employee"]?["id"];
          final employeeName =
              user["employee"]?["full_name"]; // ✅ تعديل المفتاح

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('user', jsonEncode(user));

          if (employeeId != null) {
            await prefs.setInt('employee_id', employeeId);
            print("✅ Employee ID saved: $employeeId");
          }

          if (employeeName != null) {
            await prefs.setString('employee_name', employeeName);
            print("✅ Employee Name saved: $employeeName");
          }

          Get.snackbar("تم", "تم تسجيل الدخول بنجاح");
          return Staterequest.success;
        }
      }

      Get.snackbar("فشل", "اسم المستخدم أو كلمة المرور غير صحيحة");
      return Staterequest.failure;
    } catch (error) {
      print("Login error: $error");
      Get.snackbar("خطأ", "حدث خطأ غير متوقع، تأكد من الاتصال بالإنترنت.");
      return Staterequest.failure;
    }
  }

}
