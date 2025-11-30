
class AttendanceModel {
  final int id;
  final int empId;
  final String date;
  final String? checkInTime;
  final String? checkInReason;
  final String? checkOutTime;
  final String? checkOutReason;
  final String status;
  final String? productionQuantity;

  AttendanceModel({
    required this.id,
    required this.empId,
    required this.date,
    this.checkInTime,
    this.checkInReason,
    this.checkOutTime,
    this.checkOutReason,
    required this.status,
    this.productionQuantity,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      empId: json['empId'] ?? 0,
      date: json['date'] ?? "",
      checkInTime: json['checkInTime']?.toString(),
      checkInReason: json['checkInReason']?.toString() ?? "بدون سبب",
      checkOutTime: json['checkOutTime']?.toString(),
      checkOutReason: json['checkOutReason']?.toString(),
      status: json['status']?.toString() ?? "pending",
      productionQuantity: json['productionQuantity']?.toString(),
    );
  }
}

class TodayAttendanceModel {
  final AttendanceEmployee? hasAttendance;
  final AttendanceEmployee? noAttendance;

  TodayAttendanceModel({this.hasAttendance, this.noAttendance});

  factory TodayAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TodayAttendanceModel(
      hasAttendance: json['hasAttendance'] != null
          ? AttendanceEmployee.fromJson(json['hasAttendance'])
          : null,
      noAttendance: json['noAttendance'] != null
          ? AttendanceEmployee.fromJson(json['noAttendance'])
          : null,
    );
  }

  bool get isCheckedIn => hasAttendance != null;
  bool get isNotCheckedIn => noAttendance != null;

  String get employeeName =>
      hasAttendance?.employeeName ?? noAttendance?.employeeName ?? '';
}



class AttendanceEmployee {
  final int attendanceId;
  final int employeeId;
  final String employeeName;
  final String? checkInTime; // <-- ممكن يكون null
  final String? checkOutTime; // <-- ممكن يكون null
  final String? createdAt; // <-- ممكن يكون null
  final String? notes;
  final String status;
  final String? workingHours;

  AttendanceEmployee({
    required this.attendanceId,
    required this.employeeId,
    required this.employeeName,
    this.checkInTime,
    this.checkOutTime,
    this.createdAt,
    this.notes,
    required this.status,
    this.workingHours,
  });

  factory AttendanceEmployee.fromJson(Map<String, dynamic> json) {
    return AttendanceEmployee(
      attendanceId: json['attendanceId'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      createdAt: json['createdAt'],
      notes: json['notes'],
      status: json['status'],
      workingHours: json['workingHours'],
    );
  }
}
