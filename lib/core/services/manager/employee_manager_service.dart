// employee_manager_service.dart
// طبقة الوصول لنقاط "إدارة الموظفين" (للمدراء). لا ترمي استثناءات.
import 'dart:io';
import 'dart:typed_data';

import 'package:human_resources/core/classes/manager_api.dart';
import 'package:human_resources/model/manager/employee_models.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class EmployeeManagerService {
  EmployeeManagerService._();

  static ManagerApi get _api => ManagerApi.instance;

  static ListResult<T> _parseList<T>(
    ApiResult r,
    T Function(Map<String, dynamic>) parse,
    String fallback,
  ) {
    if (!r.ok) return ListResult.failure(r.messageOr(fallback));
    dynamic data = r.data;
    if (data is Map && data['data'] is List) data = data['data'];
    if (data is! List) return ListResult.failure(fallback);
    final items = <T>[];
    for (final e in data) {
      if (e is Map) {
        try {
          items.add(parse(Map<String, dynamic>.from(e)));
        } catch (_) {}
      }
    }
    return ListResult(items);
  }

  // ---------------------------------------------------------------- الموظفون

  static Future<ListResult<ManagedEmployee>> fetchEmployees() async {
    final r = await _api.get('/employees', query: {'include_inactive': 'true'});
    return _parseList(r, ManagedEmployee.fromJson, 'تعذر تحميل الموظفين');
  }

  /// إنشاء موظف (multipart لدعم الصورة والشهادة)
  static Future<ApiResult> createEmployee(
    Map<String, dynamic> fields, {
    String? photoPath,
    String? certificatePath,
  }) {
    return _api.postMultipart(
      '/employees',
      fields: fields,
      files: {
        if (photoPath != null) 'photo': photoPath,
        if (certificatePath != null) 'certificates': certificatePath,
      },
    );
  }

  static Future<ApiResult> updateEmployee(int id, Map<String, dynamic> body) =>
      _api.put('/employees/$id', body: body);

  static Future<ApiResult> deleteEmployee(int id) => _api.delete('/employees/$id');

  static Future<ApiResult> toggleActive(int id, bool active) =>
      _api.put('/employees/$id/toggle-active', body: {'is_active': active});

  // ---------------------------------------------------- الإضافات والخصومات

  static Future<ListResult<SalaryComponent>> fetchSalaryComponents(int employeeId) async {
    final r = await _api.get('/employees/$employeeId/salary-components');
    return _parseList(r, SalaryComponent.fromJson, 'تعذر تحميل الإضافات والخصومات');
  }

  static Future<ApiResult> createSalaryComponent(int employeeId, Map<String, dynamic> body) =>
      _api.post('/employees/$employeeId/salary-components', body: body);

  static Future<ApiResult> updateSalaryComponent(int id, Map<String, dynamic> body) =>
      _api.put('/salary-components/$id', body: body);

  static Future<ApiResult> deleteSalaryComponent(int id) =>
      _api.delete('/salary-components/$id');

  // ------------------------------------------------------ التواريخ الإضافية

  static Future<ListResult<EmployeeCustomDate>> fetchCustomDates(int employeeId) async {
    final r = await _api.get('/employees/$employeeId/custom-dates');
    return _parseList(r, EmployeeCustomDate.fromJson, 'تعذر تحميل التواريخ');
  }

  static Future<ApiResult> createCustomDate(int employeeId, Map<String, dynamic> body) =>
      _api.post('/employees/$employeeId/custom-dates', body: body);

  static Future<ApiResult> updateCustomDate(int id, Map<String, dynamic> body) =>
      _api.put('/custom-dates/$id', body: body);

  static Future<ApiResult> deleteCustomDate(int id) => _api.delete('/custom-dates/$id');

  // --------------------------------------------------------------- المرفقات

  static const allowedAttachmentExtensions = [
    'pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx', 'xlsx', 'xls', 'txt', 'zip', 'rar',
  ];
  static const maxAttachmentBytes = 16 * 1024 * 1024;

  static Future<ListResult<EmployeeAttachmentItem>> fetchAttachments(int employeeId) async {
    final r = await _api.get('/employees/$employeeId/attachments');
    return _parseList(r, EmployeeAttachmentItem.fromJson, 'تعذر تحميل المرفقات');
  }

  static Future<ApiResult> uploadAttachment(
    int employeeId, {
    required String label,
    required String filePath,
    String? notes,
  }) {
    return _api.postMultipart(
      '/employees/$employeeId/attachments',
      fields: {
        'label': label,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      files: {'file': filePath},
    );
  }

  static Future<ApiResult> deleteAttachment(int id) => _api.delete('/attachments/$id');

  static Future<Uint8List?> downloadAttachment(int id) =>
      _api.downloadBytes('/attachments/$id/download');

  /// تنزيل المرفق إلى مجلد مؤقت ثم فتحه. يُرجع رسالة خطأ أو null عند النجاح.
  static Future<String?> openAttachment(EmployeeAttachmentItem a) async {
    final bytes = await downloadAttachment(a.id);
    if (bytes == null) return 'تعذر تنزيل الملف';
    try {
      final dir = await getTemporaryDirectory();
      final safeName = a.fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final file = File('${dir.path}${Platform.pathSeparator}${a.id}_$safeName');
      await file.writeAsBytes(bytes, flush: true);
      final res = await OpenFilex.open(file.path);
      if (res.type != ResultType.done) {
        return res.type == ResultType.noAppToOpen
            ? 'لا يوجد تطبيق لفتح هذا النوع من الملفات'
            : 'تعذر فتح الملف';
      }
      return null;
    } catch (_) {
      return 'تعذر حفظ الملف على الجهاز';
    }
  }

  // ------------------------------------------------------------ القوائم المساعدة

  static Future<ListResult<JobTitleItem>> fetchJobTitles() async {
    final r = await _api.get('/job_titles');
    return _parseList(r, JobTitleItem.fromJson, 'تعذر تحميل المسميات الوظيفية');
  }

  static Future<ListResult<ProfessionItem>> fetchProfessions() async {
    final r = await _api.get('/professions');
    return _parseList(r, ProfessionItem.fromJson, 'تعذر تحميل المهن');
  }

  static Future<ListResult<ShiftItem>> fetchShifts() async {
    final r = await _api.get('/shifts');
    return _parseList(r, ShiftItem.fromJson, 'تعذر تحميل الورديات');
  }

  /// أنظمة العمل المفعّلة لمسمى وظيفي (قيم: productivity/shift/months/custom)
  static Future<ListResult<String>> fetchEnabledSystems(int jobTitleId) async {
    final r = await _api.get('/job_titles/$jobTitleId/enabled_systems');
    if (!r.ok) return ListResult.failure(r.messageOr('تعذر تحميل أنظمة العمل'));
    final data = r.data;
    final list = data is Map ? data['enabled_systems'] : null;
    if (list is! List) return ListResult(const []);
    final systems = <String>[];
    for (final s in list) {
      final v = EmployeeLabels.systemFromBackend(s.toString());
      if (v != null && !systems.contains(v)) systems.add(v);
    }
    return ListResult(systems);
  }
}
