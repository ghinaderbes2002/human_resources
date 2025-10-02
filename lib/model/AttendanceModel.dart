// class AttendanceModel {
//   final int id;
//   final int empId;
//   final String date;
//   final String? checkInTime;
//   final String? checkInReason;
//   final String? checkOutTime;
//   final String? checkOutReason;
//   final String status;
//   final String? productionQuantity; // ⚡ nullable

//   AttendanceModel({
//     required this.id,
//     required this.empId,
//     required this.date,
//     this.checkInTime,
//     this.checkInReason,
//     this.checkOutTime,
//     this.checkOutReason,
//     required this.status,
//     this.productionQuantity,
//   });

//   factory AttendanceModel.fromJson(Map<String, dynamic> json) {
//     return AttendanceModel(
//       id: json['id'],
//       empId: json['empId'],
//       date: json['date'],
//       checkInTime: json['checkInTime']?.toString(),
//       checkInReason: json['checkInReason']?.toString(),
//       checkOutTime: json['checkOutTime']?.toString(),
//       checkOutReason: json['checkOutReason']?.toString(),
//       status: json['status']?.toString() ?? "pending",
//       productionQuantity: json['productionQuantity']?.toString(),
//     );
//   }
// }


// class TodayAttendanceModel {
//   final String checkInReason;
//   final String checkInTime;
//   final String? checkOutReason;
//   final String? checkOutTime;
//   final String createdAt;
//   final int empId;
//   final int id;
//   final String? productionQuantity;
//   final String status;
//   final String employeeName;

//   TodayAttendanceModel({
//     required this.checkInReason,
//     required this.checkInTime,
//     this.checkOutReason,
//     this.checkOutTime,
//     required this.createdAt,
//     required this.empId,
//     required this.id,
//     this.productionQuantity,
//     required this.status,
//     required this.employeeName,
//   });

//   factory TodayAttendanceModel.fromJson(Map<String, dynamic> json) {
//     return TodayAttendanceModel(
//       checkInReason: json['checkInReason'] ?? "بدون سبب",
//       checkInTime: json['checkInTime'] ?? "",
//       checkOutReason: json['checkOutReason']?.toString(), // nullable + safe
//       checkOutTime: json['checkOutTime']?.toString(),
//       createdAt: json['createdAt'] ?? "",
//       empId: json['empId'] ?? 0,
//       id: json['id'] ?? 0,
//       productionQuantity: json['productionQuantity']?.toString(),
//       status: json['status'] ?? "pending",
//       employeeName: json['employee']?['full_name'] ?? "غير معروف",
//     );
//   }
// }



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

// class TodayAttendanceModel {
//   final String checkInReason;
//   final String checkInTime;
//   final String? checkOutReason;
//   final String? checkOutTime;
//   final String createdAt;
//   final int empId;
//   final int id;
//   final String? productionQuantity;
//   final String status;
//   final String employeeName;

//   TodayAttendanceModel({
//     required this.checkInReason,
//     required this.checkInTime,
//     this.checkOutReason,
//     this.checkOutTime,
//     required this.createdAt,
//     required this.empId,
//     required this.id,
//     this.productionQuantity,
//     required this.status,
//     required this.employeeName,
//   });

//   factory TodayAttendanceModel.fromJson(Map<String, dynamic> json) {
//     return TodayAttendanceModel(
//       checkInReason: json['checkInReason']?.toString() ?? "بدون سبب",
//       checkInTime: json['checkInTime']?.toString() ?? "",
//       checkOutReason: json['checkOutReason']?.toString(),
//       checkOutTime: json['checkOutTime']?.toString(),
//       createdAt: json['createdAt']?.toString() ?? "",
//       empId: json['empId'] ?? 0,
//       id: json['id'] ?? 0,
//       productionQuantity: json['productionQuantity']?.toString(),
//       status: json['status']?.toString() ?? "pending",
//       employeeName: json['employee']?['full_name']?.toString() ?? "غير معروف",
//     );
//   }

//   // ✅ إضافة Getter لحساب ساعات اليوم
//   double get totalHours {
//     if (checkOutTime == null || checkInTime.isEmpty) return 0;
//     try {
//       final checkIn = DateTime.parse("1970-01-01 $checkInTime");
//       final checkOut = DateTime.parse("1970-01-01 $checkOutTime");
//       final diff = checkOut.difference(checkIn);
//       return diff.inMinutes / 60; // عدد الساعات كساعات عشرية
//     } catch (e) {
//       return 0;
//     }
//   }
// }

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

  // Getter لتعرف إذا الموظف مسجل حضور اليوم
  bool get isCheckedIn => hasAttendance != null;

  // Getter لتعرف إذا الموظف لم يسجل حضور اليوم
  bool get isNotCheckedIn => noAttendance != null;

  // للحصول على اسم الموظف
  String get employeeName =>
      hasAttendance?.employeeName ?? noAttendance?.employeeName ?? '';
}

class AttendanceEmployee {
  final int employeeId;
  final String employeeName;

  AttendanceEmployee({required this.employeeId, required this.employeeName});

  factory AttendanceEmployee.fromJson(Map<String, dynamic> json) {
    return AttendanceEmployee(
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
    );
  }
}
