import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/Fingerprint_service.dart';
import 'package:human_resources/model/AttendanceModel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FingerprintController extends GetxController {
  final FingerprintService _service = FingerprintService();

  Staterequest staterequest = Staterequest.none;
  AttendanceModel? attendance;
  bool isCheckedIn = false;
  int? empId;

  TodayAttendanceModel? todayAttendance;

  List<AttendanceModel> attendanceHistory = [];

  @override
  void onInit() {
    super.onInit();
    loadEmployeeId(); // يقرأ الـ empId أول ما ينعمل init للكنترولر
  }

  Future<void> loadEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    empId = prefs.getInt("employee_id"); // نفس المفتاح وقت التخزين
    update();
  }

  String _getCurrentTime() {
    return DateFormat("HH:mm").format(DateTime.now());
  }

  Future<void> checkIn(int empId, {String reason = "دوام"}) async {
    staterequest = Staterequest.loading;
    update();

    final result = await _service.checkIn(
      checkInTime: _getCurrentTime(),
      checkInReason: reason,
      empId: empId,
    );

    if (result != null) {
      attendance = result;
      isCheckedIn = true;
      await fetchTodayAttendance(); // تحديث حالة اليوم بعد تسجيل الدخول
      staterequest = Staterequest.success;
      Get.snackbar("نجاح", "تم تسجيل الدخول بنجاح");
    } else {
      staterequest = Staterequest.failure;
    }
    update();
  }

  Future<void> checkOut(int empId, {String reason = "انتهاء الدوام"}) async {
    if (!(todayAttendance?.isCheckedIn ?? false)) {
      Get.snackbar("تنبيه", "لا يمكنك تسجيل الخروج بدون تسجيل الدخول أولاً");
      return;
    }

    staterequest = Staterequest.loading;
    update();

    final result = await _service.checkOut(
      checkOutTime: _getCurrentTime(),
      checkOutReason: reason,
      empId: empId,
    );

    if (result != null) {
      attendance = result;
      isCheckedIn = false;
      await fetchTodayAttendance(); // تحديث حالة اليوم بعد تسجيل الخروج
      staterequest = Staterequest.success;
      Get.snackbar("نجاح", "تم تسجيل الخروج بنجاح");
    } else {
      staterequest = Staterequest.failure;
    }
    update();
  }

  Future<void> fetchTodayAttendance() async {
    if (empId == null) {
      Get.snackbar("خطأ", "لم يتم العثور على رقم الموظف");
      return;
    }

    staterequest = Staterequest.loading;
    update();

    final result = await _service.getTodayAttendance(empId!);

    if (result != null) {
      todayAttendance = result;
      isCheckedIn = todayAttendance?.isCheckedIn ?? false;
      staterequest = Staterequest.success;
    } else {
      todayAttendance = null;
      isCheckedIn = false;
      staterequest = Staterequest.failure;
    }

    update();
  }
}
