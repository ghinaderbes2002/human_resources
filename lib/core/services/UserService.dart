import 'package:get/get.dart';
import 'package:human_resources/core/classes/api_client.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/constant/App_link.dart';
import 'package:human_resources/model/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final ApiClient apiClient = ApiClient();
Future<UserModel?> getUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = '${ServerConfig().serverLink}/users/$userId';
      print("Fetch User URL: $url");

      final response = await apiClient.getData(
        url: url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("User Response Status: ${response.statusCode}");
      print("User Response Data: ${response.data}");

      if (response.statusCode == 200) {
        // تحويل JSON إلى UserModel مع branch و department
        final data = response.data;

        return UserModel(
          id: data['id'],
          username: data['username'],
          userType: data['user_type'],
          isActive: data['is_active'],
          createdAt: data['created_at'],
          updatedAt: data['updated_at'],
          employee: Employee.fromJson(data['employee']),
          branch: data['branch'] != null
              ? Branch.fromJson(data['branch'])
              : null,
          department: data['department'] != null
              ? Department.fromJson(data['department'])
              : null,
        );
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      Get.snackbar("خطأ", "تعذر جلب بيانات المستخدم");
      return null;
    }
  }


  Future<Staterequest> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = '${ServerConfig().serverLink}/users/$userId/change-password';
      print("Change Password URL: $url");

      final response = await apiClient.putData(
        url: url,
        data: {"old_password": oldPassword, "new_password": newPassword},
        headers: {"Authorization": "Bearer $token"},
      );

      print("Change Password Status: ${response.statusCode}");
      print("Change Password Data: ${response.data}");

      if (response.statusCode == 200) {
        return Staterequest.success;
      }
      return Staterequest.failure;
    } catch (e) {
      print("Error changing password: $e");
      Get.snackbar("خطأ", "تعذر تغيير كلمة المرور");
      return Staterequest.failure;
    }
  }




}
