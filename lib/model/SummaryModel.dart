class SummaryModel {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int earlyLeaveDays;

  SummaryModel({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.earlyLeaveDays,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      totalDays: json['total_days'],
      presentDays: json['present_days'],
      absentDays: json['absent_days'],
      lateDays: json['late_days'],
      earlyLeaveDays: json['early_leave_days'],
    );
  }
}
