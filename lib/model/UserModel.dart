class UserModel {
  final int id;
  final String username;
  final String userType;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final Employee employee;
  final Branch? branch;
  final Department? department;

  UserModel({
    required this.id,
    required this.username,
    required this.userType,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.employee,
    this.branch,
    this.department,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'],
    userType: json['user_type'],
    isActive: json['is_active'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
    employee: Employee.fromJson(json['employee']),
    branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
    department: json['department'] != null
        ? Department.fromJson(json['department'])
        : null,
  );
}

class Employee {
  final int id;
  final String fullName;
  final String fingerprintId;
  final int? branchId;
  final int? departmentId;

  Employee({
    required this.id,
    required this.fullName,
    required this.fingerprintId,
    this.branchId,
    this.departmentId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'],
    fullName: json['full_name'],
    fingerprintId: json['fingerprint_id'],
    branchId: json['branch_id'],
    departmentId: json['department_id'],
  );
}

class Branch {
  final int id;
  final String name;

  Branch({required this.id, required this.name});

  factory Branch.fromJson(Map<String, dynamic> json) =>
      Branch(id: json['id'], name: json['name']);
}

class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) =>
      Department(id: json['id'], name: json['name']);
}
