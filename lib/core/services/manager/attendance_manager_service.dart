// attendance_manager_service.dart
// نداءات الخادم لشاشة "إدارة الحضور" للمدراء
import 'package:human_resources/core/classes/manager_api.dart';
import 'package:human_resources/model/manager/attendance_models.dart';

class AttendanceManagerService {
  final ManagerApi _api = ManagerApi.instance;

  /// ملخص حضور يوم محدد. عند عدم وجود سجلات يُرجع الخادم كائناً {message} فنعتبره قائمة فارغة.
  Future<AttendanceResult<List<AttendanceSummaryRecord>>> fetchSummary({
    required String date,
    bool incompleteOnly = false,
  }) async {
    final res = await _api.get('/attendances/summary', query: {
      'startDate': date,
      if (incompleteOnly) 'incomplete': 1,
    });
    if (!res.ok) {
      return AttendanceResult(ok: false, message: res.messageOr('فشل جلب سجلات الحضور'));
    }
    final data = res.data;
    if (data is List) {
      final list = <AttendanceSummaryRecord>[];
      for (final e in data) {
        if (e is Map) {
          try {
            list.add(AttendanceSummaryRecord.fromJson(Map<String, dynamic>.from(e)));
          } catch (_) {}
        }
      }
      list.sort((a, b) => a.employee.fullName.compareTo(b.employee.fullName));
      return AttendanceResult(ok: true, data: list);
    }
    return const AttendanceResult(ok: true, data: []);
  }

  /// الموظفون الغائبون في تاريخ محدد (ضمن نطاق المدير)
  Future<AttendanceResult<List<AbsentEmployee>>> fetchAbsent(String date) async {
    final res = await _api.get('/employees/absent', query: {'date': date});
    if (!res.ok) {
      return AttendanceResult(ok: false, message: res.messageOr('فشل جلب الغائبين'));
    }
    final data = res.data;
    if (data is List) {
      final list = data
          .whereType<Map>()
          .map((e) => AbsentEmployee.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
      return AttendanceResult(ok: true, data: list);
    }
    return const AttendanceResult(ok: true, data: []);
  }

  Future<BulkActionResult> checkIn(List<AttendancePunchEntry> entries) {
    final items = entries.map((e) => e.toCheckInJson()).toList();
    return _bulk('/attendances/checkin', items, 'فشل تسجيل الحضور');
  }

  Future<BulkActionResult> checkOut(List<AttendancePunchEntry> entries) {
    final items = entries.map((e) => e.toCheckOutJson()).toList();
    return _bulk('/attendances/checkout', items, 'فشل تسجيل الانصراف');
  }

  Future<BulkActionResult> _bulk(
    String path,
    List<Map<String, dynamic>> items,
    String fallback,
  ) async {
    final body = items.length == 1 ? items.first : {'employees': items};
    final res = await _api.post(path, body: body);
    final data = res.data;
    if (data is Map && data['results'] is List) {
      return BulkActionResult.fromJson(Map<String, dynamic>.from(data));
    }
    return BulkActionResult.error(res.messageOr(fallback), items.length);
  }

  /// حذف جميع سجلات الموظف في يوم محدد
  Future<ApiResult> deleteDay(int empId, String date) =>
      _api.delete('/attendances/employee/$empId/date/$date');

  /// حذف فترة حضور واحدة
  Future<ApiResult> deletePeriod(int empId, String date, int attendanceId) =>
      _api.delete('/attendances/employee/$empId/date/$date/period/$attendanceId');
}
