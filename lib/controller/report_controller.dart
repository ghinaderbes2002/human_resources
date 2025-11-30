// attendance_controller.dart
import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/report_service.dart';
import 'package:human_resources/model/EmployeeMonthlyReportModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceController extends GetxController {
  final AttendanceService _service = AttendanceService();

  Staterequest staterequest = Staterequest.none;
  EmployeeMonthlyReportModel? monthlyReport;

  /// لتخزين آخر فترة مختارة
  String? startDate;
  String? endDate;

  /// جلب بيانات المستخدم من SharedPreferences (token + employeeId)
  Future<Map<String, dynamic>?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final employeeId = prefs.getInt("employee_id"); // <<< مهم: هنا

    if (token != null && employeeId != null) {
      return {"token": token, "employeeId": employeeId};
    }
    return null;
  }

  /// جلب تقرير الموظف الشهري
  Future<void> fetchEmployeeMonthlyReport({
    required String startDateParam,
    required String endDateParam,
  }) async {
    // خزّن التاريخ داخل الكنترولر
    startDate = startDateParam;
    endDate = endDateParam;

    staterequest = Staterequest.loading;
    update(); // لتحديث الواجهة

    final userData = await _getUserData();
    if (userData == null) {
      staterequest = Staterequest.failure;
      update();
      Get.snackbar("خطأ", "لم يتم العثور على بيانات المستخدم");
      return;
    }

    final result = await _service.getEmployeeMonthlyReport(
      employeeId: userData["employeeId"],
      startDate: startDate!,
      endDate: endDate!,
      token: userData["token"],
    );

    if (result.isSuccess) {
      monthlyReport = result.data;
      staterequest = Staterequest.success;
    } else {
      staterequest = Staterequest.failure;
      Get.snackbar("خطأ", result.message ?? "فشل جلب البيانات");
    }

    update(); // لتحديث الواجهة
  }
}
