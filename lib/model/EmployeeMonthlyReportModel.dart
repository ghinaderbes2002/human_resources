class EmployeeMonthlyReportModel {
  final List<AttendanceItem> attendanceList;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int vacationCount;
  final double totalHours;

  // الحقول الإضافية من summary
  final double attendancePercentage;
  final int actualWorkingDays;
  final int absentDays;
  final int lateDays;
  final int vacationDays;
  final int holidayWorkDays;
  final double totalLateHours;
  final double netOvertime;
  final double netLate;
  final double requiredWorkHours;
  final double totalActualWorkHours;
  final int earlyLeaveDays;
  final double totalEarlyLeaveHours;
  final double totalOvertimeHours;

  EmployeeMonthlyReportModel({
    required this.attendanceList,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.vacationCount,
    required this.totalHours,
    required this.attendancePercentage,
    required this.actualWorkingDays,
    required this.absentDays,
    required this.lateDays,
    required this.vacationDays,
    required this.holidayWorkDays,
    required this.totalLateHours,
    required this.netOvertime,
    required this.netLate,
    required this.requiredWorkHours,
    required this.totalActualWorkHours,
    required this.earlyLeaveDays,
    required this.totalEarlyLeaveHours,
    required this.totalOvertimeHours,
  });

  factory EmployeeMonthlyReportModel.fromJson(Map<String, dynamic> json) {
    // استخرج الحضور من daily_records
    final dailyRecordsList = json['daily_records'] as List;
    List<AttendanceItem> list = dailyRecordsList
        .map((e) => AttendanceItem.fromJson(e))
        .toList();

    // استخرج الملخص
    final summary = json['summary'] ?? {};

    // حساب عدد أيام الإجازة (is_vacation_day = true)
    final vacationDaysCount = dailyRecordsList
        .where((record) => record['is_vacation_day'] == true)
        .length;

    return EmployeeMonthlyReportModel(
      attendanceList: list,
      presentCount: summary['actual_working_days'] ?? 0,
      absentCount: summary['absent_days'] ?? 0,
      lateCount: summary['late_days'] ?? 0,
      vacationCount: summary['vacation_work_days'] ?? 0,
      totalHours: (summary['total_actual_work_hours'] ?? 0).toDouble(),
      attendancePercentage: (summary['attendance_percentage'] ?? 0).toDouble(),
      actualWorkingDays: summary['actual_working_days'] ?? 0,
      absentDays: summary['absent_days'] ?? 0,
      lateDays: summary['late_days'] ?? 0,
      vacationDays: vacationDaysCount,
      holidayWorkDays: summary['vacation_work_days'] ?? 0,
      totalLateHours: (summary['total_late_hours'] ?? 0).toDouble(),
      netOvertime: (summary['net_overtime'] ?? 0).toDouble(),
      netLate: (summary['net_late'] ?? 0).toDouble(),
      requiredWorkHours: (summary['required_work_hours'] ?? 0).toDouble(),
      totalActualWorkHours: (summary['total_actual_work_hours'] ?? 0).toDouble(),
      earlyLeaveDays: summary['early_leave_days'] ?? 0,
      totalEarlyLeaveHours: (summary['total_early_leave_hours'] ?? 0).toDouble(),
      totalOvertimeHours: (summary['total_overtime_hours'] ?? 0).toDouble(),
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
