// attendance_models.dart
// نماذج شاشة "إدارة الحضور" للمدراء (ملخص الحضور اليومي، الغائبون، نتائج التسجيل الجماعي)
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

/// نتيجة عملية خدمة مع بيانات مُحوّلة
class AttendanceResult<T> {
  final bool ok;
  final T? data;
  final String? message;

  const AttendanceResult({required this.ok, this.data, this.message});
}

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  if (s.isEmpty || s == 'None' || s == 'null') return null;
  return s;
}

/// بيانات الموظف المختصرة القادمة مع سجل الحضور
class AttendanceEmployee {
  final int id;
  final String fullName;
  final String? fingerprintId;
  final String? workSystem;
  final String? mobile;
  final String? nationalId;

  AttendanceEmployee({
    required this.id,
    required this.fullName,
    this.fingerprintId,
    this.workSystem,
    this.mobile,
    this.nationalId,
  });

  factory AttendanceEmployee.fromJson(Map<String, dynamic> j) {
    return AttendanceEmployee(
      id: mToInt(j['id']) ?? 0,
      fullName: _str(j['full_name']) ?? '-',
      fingerprintId: _str(j['fingerprint_id']),
      workSystem: _str(j['work_system']),
      mobile: _str(j['mobile_1']),
      nationalId: _str(j['national_id']),
    );
  }

  String get workSystemLabel {
    switch (workSystem) {
      case 'shift':
        return 'ورديات';
      case 'hours':
        return 'ساعات';
      default:
        return workSystem ?? '-';
    }
  }
}

/// فترة حضور واحدة (سجل دخول/خروج)
class AttendancePeriod {
  final int? attendanceId;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInReason;
  final String? checkOutReason;

  AttendancePeriod({
    this.attendanceId,
    this.checkInTime,
    this.checkOutTime,
    this.checkInReason,
    this.checkOutReason,
  });

  factory AttendancePeriod.fromJson(Map<String, dynamic> j) {
    return AttendancePeriod(
      attendanceId: mToInt(j['attendanceId']),
      checkInTime: _str(j['checkInTime']),
      checkOutTime: _str(j['checkOutTime']),
      checkInReason: _str(j['checkInReason']),
      checkOutReason: _str(j['checkOutReason']),
    );
  }
}

/// ملخص حضور موظف في يوم محدد (من /attendances/summary)
class AttendanceSummaryRecord {
  final AttendanceEmployee employee;
  final String? requiredCheckIn;
  final String? requiredCheckOut;
  final String? actualCheckIn;
  final String? checkInStatus;
  final String? actualCheckOut;
  final String? checkOutStatus;
  final String? totalWorkTime;
  final String? totalBreakTime;
  final String? nextAction;
  final String? firstCheckIn;
  final String? lastCheckOut;
  final List<AttendancePeriod> periods;

  AttendanceSummaryRecord({
    required this.employee,
    this.requiredCheckIn,
    this.requiredCheckOut,
    this.actualCheckIn,
    this.checkInStatus,
    this.actualCheckOut,
    this.checkOutStatus,
    this.totalWorkTime,
    this.totalBreakTime,
    this.nextAction,
    this.firstCheckIn,
    this.lastCheckOut,
    this.periods = const [],
  });

  factory AttendanceSummaryRecord.fromJson(Map<String, dynamic> j) {
    final emp = j['employee'];
    final rawPeriods = j['attendancePeriods'];
    return AttendanceSummaryRecord(
      employee: AttendanceEmployee.fromJson(
        emp is Map ? Map<String, dynamic>.from(emp) : <String, dynamic>{},
      ),
      requiredCheckIn: _str(j['requiredCheckIn']),
      requiredCheckOut: _str(j['requiredCheckOut']),
      actualCheckIn: _str(j['actualCheckIn']),
      checkInStatus: _str(j['checkInStatus']),
      actualCheckOut: _str(j['actualCheckOut']),
      checkOutStatus: _str(j['checkOutStatus']),
      totalWorkTime: _str(j['totalWorkTime']),
      totalBreakTime: _str(j['totalBreakTime']),
      nextAction: _str(j['nextAction']),
      firstCheckIn: _str(j['firstCheckIn']),
      lastCheckOut: _str(j['lastCheckOut']),
      periods: rawPeriods is List
          ? rawPeriods
              .whereType<Map>()
              .map((e) => AttendancePeriod.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  int get empId => employee.id;

  bool get hasCheckIn => actualCheckIn != null;
  bool get isLate => checkInStatus == 'Late';
  bool get canCheckOut => nextAction == 'check-out';
  bool get missingCheckOut => checkOutStatus == 'No Check-out' || canCheckOut;

  /// إجمالي دقائق العمل من "H hours M minutes"
  int get workMinutes => parseDurationMinutes(totalWorkTime);
  int get breakMinutes => parseDurationMinutes(totalBreakTime);

  /// نسبة العمل من 8 ساعات (0..1)
  double get workProgress => (workMinutes / 480).clamp(0.0, 1.0).toDouble();

  String get workTimeShort => formatMinutes(workMinutes);
  String get breakTimeShort => formatMinutes(breakMinutes);

  static int parseDurationMinutes(String? s) {
    if (s == null) return 0;
    final h = RegExp(r'(\d+)\s*hour').firstMatch(s);
    final m = RegExp(r'(\d+)\s*minute').firstMatch(s);
    return (int.tryParse(h?.group(1) ?? '') ?? 0) * 60 +
        (int.tryParse(m?.group(1) ?? '') ?? 0);
  }

  /// 125 -> "2:05"
  static String formatMinutes(int minutes) =>
      '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';

  static String checkInStatusLabel(String? s) {
    switch (s) {
      case 'Late':
        return 'متأخر';
      case 'On Time':
        return 'في الوقت';
      case 'Recorded':
        return 'مسجل';
      case 'Out of Shift':
        return 'خارج الوردية';
      default:
        return s ?? '-';
    }
  }

  static String checkOutStatusLabel(String? s) {
    switch (s) {
      case 'Early':
        return 'مبكر';
      case 'On Time':
        return 'في الوقت';
      case 'No Check-out':
        return 'لم يسجل خروج';
      case 'Recorded':
        return 'مسجل';
      case 'Out of Shift':
        return 'خارج الوردية';
      default:
        return s ?? '-';
    }
  }
}

/// موظف غائب (من /employees/absent)
class AbsentEmployee {
  final int id;
  final String fullName;

  AbsentEmployee({required this.id, required this.fullName});

  factory AbsentEmployee.fromJson(Map<String, dynamic> j) => AbsentEmployee(
        id: mToInt(j['id']) ?? 0,
        fullName: _str(j['full_name']) ?? '-',
      );
}

/// عنصر تسجيل حضور/انصراف يُرسل للخادم
class AttendancePunchEntry {
  final int empId;
  final String time; // HH:MM:SS
  final String reason;
  final String date; // YYYY-MM-DD

  AttendancePunchEntry({
    required this.empId,
    required this.time,
    required this.reason,
    required this.date,
  });

  Map<String, dynamic> toCheckInJson() => {
        'empId': empId,
        'checkInTime': time,
        'checkInReason': reason,
        'date': date,
      };

  Map<String, dynamic> toCheckOutJson() => {
        'empId': empId,
        'checkOutTime': time,
        'checkOutReason': reason,
        'date': date,
      };
}

class BulkItemResult {
  final int index;
  final bool success;
  final String message;

  BulkItemResult({required this.index, required this.success, required this.message});

  factory BulkItemResult.fromJson(Map<String, dynamic> j) => BulkItemResult(
        index: mToInt(j['index']) ?? 0,
        success: j['success'] == true,
        message: _str(j['message']) ?? '',
      );
}

/// استجابة /attendances/checkin و /attendances/checkout
class BulkActionResult {
  final String? message;
  final int total;
  final int success;
  final int failed;
  final List<BulkItemResult> results;

  BulkActionResult({
    this.message,
    this.total = 0,
    this.success = 0,
    this.failed = 0,
    this.results = const [],
  });

  factory BulkActionResult.fromJson(Map<String, dynamic> j) {
    final raw = j['results'];
    final results = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => BulkItemResult.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <BulkItemResult>[];
    final success = mToInt(j['success']) ?? results.where((r) => r.success).length;
    final total = mToInt(j['total']) ?? results.length;
    return BulkActionResult(
      message: _str(j['message']),
      total: total,
      success: success,
      failed: mToInt(j['failed']) ?? (total - success),
      results: results,
    );
  }

  /// فشل كامل مع رسالة واحدة (خطأ شبكة مثلاً)
  factory BulkActionResult.error(String message, int total) => BulkActionResult(
        message: message,
        total: total,
        success: 0,
        failed: total,
      );

  List<BulkItemResult> get failures => results.where((r) => !r.success).toList();
}
