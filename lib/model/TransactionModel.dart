class TransactionModel {
  final int id;
  final String transactionType;
  final int employeeId;

  // للسلف
  final double? amount;
  final String? documentNumber;
  final String? date;
  final String? notes;

  // للإجازة اليومية
  final String? startDate;
  final String? endDate;
  final int? days;
  final String? reason;

  // للإجازة الساعية
  final String? leaveDate;
  final int? hours;
  final String? startTime;
  final String? endTime;

  final String? status; // حالة الطلب (موافقة/رفض/قيد المعالجة)

  TransactionModel({
    required this.id,
    required this.transactionType,
    required this.employeeId,
    this.amount,
    this.documentNumber,
    this.date,
    this.notes,
    this.startDate,
    this.endDate,
    this.days,
    this.reason,
    this.leaveDate,
    this.hours,
    this.startTime,
    this.endTime,
    this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final details = json['details'] ?? {};

    return TransactionModel(
      id: json['id'] ?? 0,
      transactionType: json['transaction_type'] ?? '',
      employeeId: json['employee']?['id'] ?? json['employee_id'] ?? 0,

      // advance
      amount: details['amount'] != null
          ? (details['amount'] as num).toDouble()
          : null,
      documentNumber: details['document_number'],
      date: details['date'],
      notes: details['notes'] ?? json['notes'],

      // daily leave
      startDate: details['start_date'],
      endDate: details['end_date'],
      days: details['days'] != null ? details['days'] as int : null,

      // hourly leave
      leaveDate: details['leave_date'],
      hours: details['hours'] != null ? details['hours'] as int : null,
      startTime: details['start_time'],
      endTime: details['end_time'],

      status: json['status'],
      reason: details['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    final details = <String, dynamic>{};

    // advance
    if (amount != null) details["amount"] = amount;
    if (documentNumber != null) details["document_number"] = documentNumber;
    if (date != null) details["date"] = date;
    if (notes != null) details["notes"] = notes;

    // daily leave
    if (startDate != null) details["start_date"] = startDate;
    if (endDate != null) details["end_date"] = endDate;
    if (days != null) details["days"] = days;
    if (reason != null) details["reason"] = reason;

    // hourly leave
    if (leaveDate != null) details["leave_date"] = leaveDate;
    if (hours != null) details["hours"] = hours;
    if (startTime != null) details["start_time"] = startTime;
    if (endTime != null) details["end_time"] = endTime;

    return {
      "id": id,
      "transaction_type": transactionType,
      "employee_id": employeeId,
      if (status != null) "status": status,
      "details": details,
    };
  }
}
