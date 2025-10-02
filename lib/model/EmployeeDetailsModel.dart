class EmployeeDetailsModel {
  final int id;
  final String name;
  final String department;
  final String role;

  EmployeeDetailsModel({
    required this.id,
    required this.name,
    required this.department,
    required this.role,
  });

  factory EmployeeDetailsModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailsModel(
      id: json['id'],
      name: json['name'],
      department: json['department'],
      role: json['role'],
    );
  }
}
