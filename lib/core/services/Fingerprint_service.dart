import 'package:get/get.dart';
import 'package:human_resources/core/classes/api_client.dart';
import 'package:human_resources/core/constant/App_link.dart';
import 'package:human_resources/model/AttendanceModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FingerprintService {
  final ApiClient apiClient = ApiClient();

  /// Check-In
  Future<AttendanceModel?> checkIn({
    required String checkInTime,
    required String checkInReason,
    required int empId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = '${ServerConfig().serverLink}/attendances/checkin';
      print("Check-In URL: $url");

      final response = await apiClient.postData(
        url: url,
        data: {
          "checkInTime": checkInTime,
          "checkInReason": checkInReason,
          "empId": empId,
        },
        headers: {"Authorization": "Bearer $token"},
      );

      print("Check-In Status: ${response.statusCode}");
      print("Check-In Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AttendanceModel.fromJson(response.data['attendance']);
      }
      return null;
    } catch (e) {
      print("Error in checkIn: $e");
      Get.snackbar("خطأ", "تعذر تسجيل الدخول بالبصمة");
      return null;
    }
  }

  /// Check-Out
  Future<AttendanceModel?> checkOut({
    required String checkOutTime,
    required String checkOutReason,
    required int empId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = '${ServerConfig().serverLink}/attendances/checkout';
      print("Check-Out URL: $url");

      final response = await apiClient.postData(
        url: url,
        data: {
          "checkOutTime": checkOutTime,
          "checkOutReason": checkOutReason,
          "empId": empId,
        },
        headers: {"Authorization": "Bearer $token"},
      );

      print("Check-Out Status: ${response.statusCode}");
      print("Check-Out Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AttendanceModel.fromJson(response.data['attendance']);
      }
      return null;
    } catch (e) {
      print("Error in checkOut: $e");
      Get.snackbar("خطأ", "تعذر تسجيل الخروج بالبصمة");
      return null;
    }
  }


/// Get Attendance by Employee
  Future<List<AttendanceModel>> getAttendanceByEmployee(int empId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = '${ServerConfig().serverLink}/attendances/employee/$empId';
      print("Get Attendance URL: $url");

      final response = await apiClient.getData(
        url: url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("Get Attendance Status: ${response.statusCode}");
      print("Get Attendance Data: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => AttendanceModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error in getAttendanceByEmployee: $e");
      Get.snackbar("خطأ", "تعذر جلب سجلات الحضور");
      return [];
    }
  }


  /// جلب حالة حضور اليوم للموظف
  Future<TodayAttendanceModel?> getTodayAttendance(int empId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url =
          '${ServerConfig().serverLink}/employees/attendance-today/$empId';
      print("Get Today Attendance URL: $url");

      final response = await apiClient.getData(
        url: url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return TodayAttendanceModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Error in getTodayAttendance: $e");
      Get.snackbar("خطأ", "تعذر جلب حالة الحضور اليوم");
      return null;
    }
  }


}
