class DailyRecordModel {
  final String date;
  final String status;
  final String? checkIn;
  final String? checkOut;

  DailyRecordModel({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
  });

  factory DailyRecordModel.fromJson(Map<String, dynamic> json) {
    return DailyRecordModel(
      date: json['date'],
      status: json['status'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],
    );
  }
}
