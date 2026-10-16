// employee_models.dart
// نماذج بيانات شاشة "إدارة الموظفين" للمدراء (تحليل دفاعي للأرقام والنصوص)
import 'package:human_resources/view/widget/manager/manager_widgets.dart'
    show mToDouble, mToInt;

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty || s == 'null' || s == 'None') return null;
  return s;
}

bool _bool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase().trim();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// تسميات ثابتة لأنظمة العمل وأنواع الموظفين
class EmployeeLabels {
  static const String photoLabel = 'employee_photo';

  static String workSystem(String? v) {
    switch (v) {
      case 'shift':
        return 'نظام الورديات';
      case 'hours':
        return 'نظام الساعات';
      case 'months':
      case 'monthly':
        return 'النظام الشهري';
      case 'productivity':
        return 'نظام الإنتاج';
      case 'custom':
        return 'نظام مخصص';
      case null:
      case '':
        return '-';
      default:
        return v;
    }
  }

  static String employeeType(String? v) {
    switch (v) {
      case 'permanent':
        return 'دائم';
      case 'temporary':
        return 'مؤقت';
      default:
        return '-';
    }
  }

  /// تحويل اسم النظام القادم من /job_titles/{id}/enabled_systems إلى قيمة نظام العمل
  static String? systemFromBackend(String name) {
    switch (name) {
      case 'Production System':
        return 'productivity';
      case 'Shift System':
        return 'shift';
      case 'Month System':
        return 'months';
      case 'Custom System':
        return 'custom';
    }
    return null;
  }

  /// أنظمة العمل للموظف المؤقت (ثابتة)
  static const List<String> temporarySystems = ['hours', 'monthly'];

  /// أنظمة الموظف الدائم (احتياطي عند تعذر جلب أنظمة المسمى الوظيفي)
  static const List<String> permanentSystems = ['productivity', 'shift', 'months'];
}

class ManagedEmployee {
  final int id;
  final String? fingerprintId;
  final String fullName;
  final String? employeeType;
  final String? position;
  final String? profession;
  final double? salary;
  final double? allowances;
  final double? insuranceDeduction;
  final String? insuranceStartDate;
  final String? insuranceEndDate;
  final double? advancePercentage;
  final String? workSystem;
  final String? certificates;
  final String? dateOfBirth;
  final String? placeOfBirth;
  final String? dateOfJoining;
  final String? idCardNumber;
  final String? nationalId;
  final String? residence;
  final String? mobile1;
  final String? mobile2;
  final String? mobile3;
  final int? shiftId;
  final String? workerAgreement;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  final int? branchId;
  final String? branchName;
  final int? departmentId;
  final String? departmentName;
  final bool isDepartmentHead;
  final double? overtimeMultiplier;
  final double? dailyRate;
  final double? hourlyRate;
  final bool isActive;
  final String? deactivatedAt;
  final int? photoAttachmentId;

  ManagedEmployee({
    required this.id,
    required this.fullName,
    this.fingerprintId,
    this.employeeType,
    this.position,
    this.profession,
    this.salary,
    this.allowances,
    this.insuranceDeduction,
    this.insuranceStartDate,
    this.insuranceEndDate,
    this.advancePercentage,
    this.workSystem,
    this.certificates,
    this.dateOfBirth,
    this.placeOfBirth,
    this.dateOfJoining,
    this.idCardNumber,
    this.nationalId,
    this.residence,
    this.mobile1,
    this.mobile2,
    this.mobile3,
    this.shiftId,
    this.workerAgreement,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.branchId,
    this.branchName,
    this.departmentId,
    this.departmentName,
    this.isDepartmentHead = false,
    this.overtimeMultiplier,
    this.dailyRate,
    this.hourlyRate,
    this.isActive = true,
    this.deactivatedAt,
    this.photoAttachmentId,
  });

  factory ManagedEmployee.fromJson(Map<String, dynamic> j) => ManagedEmployee(
        id: mToInt(j['id']) ?? 0,
        fingerprintId: _str(j['fingerprint_id']),
        fullName: _str(j['full_name']) ?? '-',
        employeeType: _str(j['employee_type']),
        position: _str(j['position']),
        profession: _str(j['profession']),
        salary: mToDouble(j['salary']),
        allowances: mToDouble(j['allowances']),
        insuranceDeduction: mToDouble(j['insurance_deduction']),
        insuranceStartDate: _str(j['insurance_start_date']),
        insuranceEndDate: _str(j['insurance_end_date']),
        advancePercentage: mToDouble(j['advancePercentage']),
        workSystem: _str(j['work_system']),
        certificates: _str(j['certificates']),
        dateOfBirth: _str(j['date_of_birth']),
        placeOfBirth: _str(j['place_of_birth']),
        dateOfJoining: _str(j['date_of_joining']),
        idCardNumber: _str(j['id_card_number']),
        nationalId: _str(j['national_id']),
        residence: _str(j['residence']),
        mobile1: _str(j['mobile_1']),
        mobile2: _str(j['mobile_2']),
        mobile3: _str(j['mobile_3']),
        shiftId: mToInt(j['shift_id']),
        workerAgreement: _str(j['worker_agreement']),
        notes: _str(j['notes']),
        createdAt: _str(j['created_at']),
        updatedAt: _str(j['updated_at']),
        branchId: mToInt(j['branch_id']),
        branchName: _str(j['branch_name']),
        departmentId: mToInt(j['department_id']),
        departmentName: _str(j['department_name']),
        isDepartmentHead: _bool(j['is_department_head']),
        overtimeMultiplier: mToDouble(j['overtime_multiplier']),
        dailyRate: mToDouble(j['daily_rate']),
        hourlyRate: mToDouble(j['hourly_rate']),
        isActive: _bool(j['is_active'], fallback: true),
        deactivatedAt: _str(j['deactivated_at']),
        photoAttachmentId: mToInt(j['photo_attachment_id']),
      );

  bool get isPermanent => employeeType == 'permanent';
  bool get isTemporary => employeeType == 'temporary';

  String get typeLabel => EmployeeLabels.employeeType(employeeType);
  String get workSystemLabel => EmployeeLabels.workSystem(workSystem);

  /// المسمى الوظيفي (للدائم) أو المهنة (للمؤقت)
  String get jobLabel =>
      (isPermanent ? position : profession) ?? position ?? profession ?? '-';

  String get scopeLabel {
    final parts = [branchName, departmentName].whereType<String>().toList();
    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty || fullName == '-') return '؟';
    if (parts.length == 1) return parts.first.characters1;
    // فاصل غير رابط حتى لا تتصل الحروف العربية
    return '${parts.first.characters1}‌${parts[1].characters1}';
  }

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [fullName, fingerprintId, nationalId, mobile1, mobile2, mobile3]
        .whereType<String>()
        .any((v) => v.toLowerCase().contains(q));
  }
}

extension _FirstChar on String {
  String get characters1 => isEmpty ? '' : substring(0, 1);
}

class SalaryComponent {
  final int id;
  final int? employeeId;
  final String name;
  final double amount;
  final String componentType; // addition | deduction
  final bool isActive;
  final String? notes;

  SalaryComponent({
    required this.id,
    required this.name,
    required this.amount,
    required this.componentType,
    this.employeeId,
    this.isActive = true,
    this.notes,
  });

  factory SalaryComponent.fromJson(Map<String, dynamic> j) => SalaryComponent(
        id: mToInt(j['id']) ?? 0,
        employeeId: mToInt(j['employee_id']),
        name: _str(j['name']) ?? '-',
        amount: mToDouble(j['amount']) ?? 0,
        componentType: _str(j['component_type']) ?? 'addition',
        isActive: _bool(j['is_active'], fallback: true),
        notes: _str(j['notes']),
      );

  bool get isAddition => componentType == 'addition';
}

/// مكوّن راتب مبدئي في نموذج الإضافة (يُرسل بعد إنشاء الموظف)
class SalaryComponentDraft {
  String name;
  double amount;
  String componentType;
  String? notes;

  SalaryComponentDraft({
    required this.name,
    required this.amount,
    required this.componentType,
    this.notes,
  });

  bool get isAddition => componentType == 'addition';

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'component_type': componentType,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

class EmployeeCustomDate {
  final int id;
  final String label;
  final String? dateValue;
  final String? notes;

  EmployeeCustomDate({
    required this.id,
    required this.label,
    this.dateValue,
    this.notes,
  });

  factory EmployeeCustomDate.fromJson(Map<String, dynamic> j) => EmployeeCustomDate(
        id: mToInt(j['id']) ?? 0,
        label: _str(j['label']) ?? '-',
        dateValue: _str(j['date_value']),
        notes: _str(j['notes']),
      );
}

class EmployeeAttachmentItem {
  final int id;
  final String label;
  final String? filePath;
  final String? originalFilename;
  final String? fileType;
  final int? fileSize;
  final String? notes;
  final String? createdAt;

  EmployeeAttachmentItem({
    required this.id,
    required this.label,
    this.filePath,
    this.originalFilename,
    this.fileType,
    this.fileSize,
    this.notes,
    this.createdAt,
  });

  factory EmployeeAttachmentItem.fromJson(Map<String, dynamic> j) =>
      EmployeeAttachmentItem(
        id: mToInt(j['id']) ?? 0,
        label: _str(j['label']) ?? '-',
        filePath: _str(j['file_path']),
        originalFilename: _str(j['original_filename']),
        fileType: _str(j['file_type']),
        fileSize: mToInt(j['file_size']),
        notes: _str(j['notes']),
        createdAt: _str(j['created_at']),
      );

  bool get isPhoto => label == EmployeeLabels.photoLabel;

  String get fileName {
    if (originalFilename != null) return originalFilename!;
    final p = filePath;
    if (p != null && p.contains('/')) return p.split('/').last;
    return 'attachment_$id${fileType != null ? '.$fileType' : ''}';
  }

  String get extension {
    if (fileType != null) return fileType!.toLowerCase();
    final n = fileName;
    return n.contains('.') ? n.split('.').last.toLowerCase() : '';
  }

  String get sizeLabel {
    final s = fileSize;
    if (s == null || s <= 0) return '';
    if (s < 1024) return '$s B';
    if (s < 1024 * 1024) return '${(s / 1024).toStringAsFixed(1)} KB';
    return '${(s / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class JobTitleItem {
  final int id;
  final String name;
  JobTitleItem({required this.id, required this.name});

  factory JobTitleItem.fromJson(Map<String, dynamic> j) => JobTitleItem(
        id: mToInt(j['id']) ?? 0,
        name: _str(j['title_name']) ?? _str(j['name']) ?? '-',
      );
}

class ProfessionItem {
  final int id;
  final String name;
  final double? hourlyRate;
  final double? dailyRate;
  ProfessionItem({required this.id, required this.name, this.hourlyRate, this.dailyRate});

  factory ProfessionItem.fromJson(Map<String, dynamic> j) => ProfessionItem(
        id: mToInt(j['id']) ?? 0,
        name: _str(j['name']) ?? '-',
        hourlyRate: mToDouble(j['hourly_rate']),
        dailyRate: mToDouble(j['daily_rate']),
      );
}

class ShiftItem {
  final int id;
  final String name;
  ShiftItem({required this.id, required this.name});

  factory ShiftItem.fromJson(Map<String, dynamic> j) => ShiftItem(
        id: mToInt(j['id']) ?? 0,
        name: _str(j['name']) ?? 'وردية ${j['id']}',
      );
}

/// نتيجة جلب قائمة: العناصر أو رسالة خطأ
class ListResult<T> {
  final List<T> items;
  final String? error;
  ListResult(this.items, {this.error});
  ListResult.failure(String message)
      : items = <T>[],
        error = message;
  bool get ok => error == null;
}

/// استخراج خريطة من استجابة (مثلاً employee داخل الاستجابة)
Map<String, dynamic> employeeMapOf(dynamic data) => _map(data);
