class EmployeeMonthlyReportModel {
  final List<AttendanceItem> attendanceList;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int vacationCount;
  final double totalHours;

  EmployeeMonthlyReportModel({
    required this.attendanceList,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.vacationCount,
    required this.totalHours,
  });

  factory EmployeeMonthlyReportModel.fromJson(Map<String, dynamic> json) {
    // استخرج الحضور من daily_records
    List<AttendanceItem> list = (json['daily_records'] as List)
        .map((e) => AttendanceItem.fromJson(e))
        .toList();

    // استخرج الملخص
    final summary = json['summary'] ?? {};

    return EmployeeMonthlyReportModel(
      attendanceList: list,
      presentCount: summary['actual_working_days'] ?? 0,
      absentCount: summary['absent_days'] ?? 0,
      lateCount: summary['late_days'] ?? 0,
      vacationCount: summary['vacation_work_days'] ?? 0,
      totalHours: (summary['total_actual_work_hours'] ?? 0).toDouble(),
    );
  }
}

class AttendanceItem {
  final String date;
  final String status;
  final String inTime;
  final String outTime;
  final double hours;

  AttendanceItem({
    required this.date,
    required this.status,
    required this.inTime,
    required this.outTime,
    required this.hours,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) => AttendanceItem(
    date: json['date'],
    status: json['status'],
    inTime: json['actual_check_in'] ?? "-",
    outTime: json['actual_check_out'] ?? "-",
    hours: (json['total_actual_work_hours'] ?? 0).toDouble(),
  );
}
