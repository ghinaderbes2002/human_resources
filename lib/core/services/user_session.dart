// user_session.dart
// معلومات المستخدم الحالي وصلاحياته (من بيانات تسجيل الدخول المحفوظة)
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final int? userId;
  final String username;
  final String userType;
  final int? employeeId;
  final String? branchName;
  final String? departmentName;

  UserSession({
    this.userId,
    required this.username,
    required this.userType,
    this.employeeId,
    this.branchName,
    this.departmentName,
  });

  static const managerTypes = [
    'branch_head',
    'branch_deputy',
    'department_head',
    'department_deputy',
  ];

  /// رئيس/نائب فرع أو قسم (أو المدير العام)
  bool get isManager =>
      managerTypes.contains(userType) || isSuperAdmin;

  bool get isSuperAdmin => userType == 'super_admin' || userType == 'dev';

  bool get isBranchRole =>
      userType == 'branch_head' || userType == 'branch_deputy';

  String get roleLabel {
    switch (userType) {
      case 'branch_head':
        return 'رئيس فرع';
      case 'branch_deputy':
        return 'نائب رئيس فرع';
      case 'department_head':
        return 'رئيس قسم';
      case 'department_deputy':
        return 'نائب رئيس قسم';
      case 'super_admin':
      case 'dev':
        return 'مدير النظام';
      default:
        return 'موظف';
    }
  }

  /// اسم الفرع/القسم الذي يديره
  String? get scopeName => isBranchRole ? branchName : departmentName;

  static Future<UserSession> load() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> user = {};
    try {
      final raw = prefs.getString('user');
      if (raw != null) user = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {}
    return UserSession(
      userId: user['id'],
      username: user['username'] ?? '',
      userType: user['user_type'] ?? 'employee',
      employeeId: user['employee']?['id'] ?? prefs.getInt('employee_id'),
      branchName: user['branch']?['name'],
      departmentName: user['department']?['name'],
    );
  }
}
