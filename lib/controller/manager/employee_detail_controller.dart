// employee_detail_controller.dart
// متحكم صفحة تفاصيل الموظف: الإضافات والخصومات، التواريخ، المرفقات، والصورة.
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/employee_manager_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/manager/employee_manager_service.dart';
import 'package:human_resources/model/manager/employee_models.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class EmployeeDetailController extends GetxController {
  final int employeeId;
  ManagedEmployee _fallback;

  EmployeeDetailController(ManagedEmployee employee)
      : employeeId = employee.id,
        _fallback = employee;

  EmployeeManagerController get list => EmployeeManagerController.to;

  /// أحدث نسخة من الموظف (من القائمة بعد أي تحديث)
  ManagedEmployee get employee {
    final e = list.byId(employeeId);
    if (e != null) _fallback = e;
    return _fallback;
  }

  /// عملية جارية على الموظف نفسه (صورة/تفعيل/حذف)
  bool busy = false;
  String? busyLabel;

  Staterequest componentsStatus = Staterequest.none;
  String? componentsError;
  List<SalaryComponent> components = [];

  Staterequest datesStatus = Staterequest.none;
  String? datesError;
  List<EmployeeCustomDate> dates = [];

  Staterequest attachmentsStatus = Staterequest.none;
  String? attachmentsError;
  List<EmployeeAttachmentItem> attachments = [];

  /// مرفقات يتم فتحها/حذفها حالياً
  final Set<int> busyAttachments = {};

  bool uploading = false;

  @override
  void onInit() {
    super.onInit();
    loadAll();
    if (employee.shiftId != null) {
      list.shifts().then((_) => update());
    }
  }

  Future<void> loadAll() async {
    await Future.wait([loadComponents(), loadDates(), loadAttachments()]);
  }

  Future<void> refreshEmployee() async {
    await list.load(silent: true);
    update();
  }

  // ---------------------------------------------------- الإضافات والخصومات

  List<SalaryComponent> get additions => components.where((c) => c.isAddition).toList();
  List<SalaryComponent> get deductions => components.where((c) => !c.isAddition).toList();

  double get totalAdditions =>
      additions.where((c) => c.isActive).fold(0, (s, c) => s + c.amount);
  double get totalDeductions =>
      deductions.where((c) => c.isActive).fold(0, (s, c) => s + c.amount);

  Future<void> loadComponents() async {
    componentsStatus = Staterequest.loading;
    componentsError = null;
    update();
    final r = await EmployeeManagerService.fetchSalaryComponents(employeeId);
    if (r.ok) {
      components = r.items;
      componentsStatus = components.isEmpty ? Staterequest.empty : Staterequest.success;
    } else {
      componentsStatus = Staterequest.failure;
      componentsError = r.error;
    }
    update();
  }

  /// إضافة أو تعديل مكوّن. يُرجع true عند النجاح (لإغلاق النافذة).
  Future<bool> saveComponent({
    SalaryComponent? existing,
    required String name,
    required double amount,
    required String componentType,
    String? notes,
  }) async {
    final body = {
      'name': name,
      'amount': amount,
      'component_type': componentType,
      'notes': (notes ?? '').isEmpty ? null : notes,
    };
    final r = existing == null
        ? await EmployeeManagerService.createSalaryComponent(employeeId, body)
        : await EmployeeManagerService.updateSalaryComponent(existing.id, body);
    if (r.ok) {
      MDialogs.success(existing == null ? 'تمت الإضافة بنجاح' : 'تم التعديل بنجاح');
      await loadComponents();
      return true;
    }
    MDialogs.error(r.messageOr('تعذر حفظ البيان'));
    return false;
  }

  Future<void> toggleComponentActive(SalaryComponent c) async {
    final r = await EmployeeManagerService.updateSalaryComponent(
        c.id, {'is_active': !c.isActive});
    if (r.ok) {
      await loadComponents();
    } else {
      MDialogs.error(r.messageOr('تعذر تحديث الحالة'));
    }
  }

  Future<void> deleteComponent(SalaryComponent c) async {
    final ok = await employeeConfirm(
      title: c.isAddition ? 'حذف الإضافة' : 'حذف الخصم',
      message: 'هل تريد حذف "${c.name}"؟',
      confirmText: 'حذف',
      confirmColor: MColors.danger,
    );
    if (!ok) return;
    final r = await EmployeeManagerService.deleteSalaryComponent(c.id);
    if (r.ok) {
      MDialogs.success('تم الحذف');
      await loadComponents();
    } else {
      MDialogs.error(r.messageOr('تعذر الحذف'));
    }
  }

  // ------------------------------------------------------ التواريخ الإضافية

  Future<void> loadDates() async {
    datesStatus = Staterequest.loading;
    datesError = null;
    update();
    final r = await EmployeeManagerService.fetchCustomDates(employeeId);
    if (r.ok) {
      dates = r.items;
      datesStatus = dates.isEmpty ? Staterequest.empty : Staterequest.success;
    } else {
      datesStatus = Staterequest.failure;
      datesError = r.error;
    }
    update();
  }

  Future<bool> saveDate({
    EmployeeCustomDate? existing,
    required String label,
    required String dateValue,
    String? notes,
  }) async {
    final body = {
      'label': label,
      'date_value': dateValue,
      'notes': (notes ?? '').isEmpty ? null : notes,
    };
    final r = existing == null
        ? await EmployeeManagerService.createCustomDate(employeeId, body)
        : await EmployeeManagerService.updateCustomDate(existing.id, body);
    if (r.ok) {
      MDialogs.success(existing == null ? 'تمت إضافة التاريخ' : 'تم تعديل التاريخ');
      await loadDates();
      return true;
    }
    MDialogs.error(r.messageOr('تعذر حفظ التاريخ'));
    return false;
  }

  Future<void> deleteDate(EmployeeCustomDate d) async {
    final ok = await employeeConfirm(
      title: 'حذف التاريخ',
      message: 'هل تريد حذف "${d.label}"؟',
      confirmText: 'حذف',
      confirmColor: MColors.danger,
    );
    if (!ok) return;
    final r = await EmployeeManagerService.deleteCustomDate(d.id);
    if (r.ok) {
      MDialogs.success('تم الحذف');
      await loadDates();
    } else {
      MDialogs.error(r.messageOr('تعذر الحذف'));
    }
  }

  // --------------------------------------------------------------- المرفقات

  Future<void> loadAttachments() async {
    attachmentsStatus = Staterequest.loading;
    attachmentsError = null;
    update();
    final r = await EmployeeManagerService.fetchAttachments(employeeId);
    if (r.ok) {
      attachments = r.items.where((a) => !a.isPhoto).toList();
      attachmentsStatus =
          attachments.isEmpty ? Staterequest.empty : Staterequest.success;
    } else {
      attachmentsStatus = Staterequest.failure;
      attachmentsError = r.error;
    }
    update();
  }

  /// اختيار ملف مرفق مع التحقق من النوع والحجم. يُرجع الملف أو null.
  Future<PlatformFile?> pickAttachmentFile() async {
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: EmployeeManagerService.allowedAttachmentExtensions,
    );
    if (res == null || res.files.isEmpty) return null;
    final f = res.files.first;
    if (f.path == null) {
      MDialogs.error('تعذر قراءة الملف المختار');
      return null;
    }
    final ext = (f.extension ?? '').toLowerCase();
    if (!EmployeeManagerService.allowedAttachmentExtensions.contains(ext)) {
      MDialogs.error('نوع الملف غير مسموح');
      return null;
    }
    if (f.size > EmployeeManagerService.maxAttachmentBytes) {
      MDialogs.error('حجم الملف يتجاوز الحد المسموح (16 ميجابايت)');
      return null;
    }
    return f;
  }

  Future<bool> uploadAttachment({
    required String label,
    required String filePath,
    String? notes,
  }) async {
    if (label.trim() == EmployeeLabels.photoLabel) {
      MDialogs.error('هذه التسمية محجوزة لصورة الموظف');
      return false;
    }
    uploading = true;
    update();
    final r = await EmployeeManagerService.uploadAttachment(
      employeeId,
      label: label.trim(),
      filePath: filePath,
      notes: notes,
    );
    uploading = false;
    update();
    if (r.ok) {
      MDialogs.success('تم رفع المرفق بنجاح');
      await loadAttachments();
      return true;
    }
    MDialogs.error(r.messageOr('تعذر رفع المرفق'));
    return false;
  }

  Future<void> openAttachment(EmployeeAttachmentItem a) async {
    busyAttachments.add(a.id);
    update();
    final err = await EmployeeManagerService.openAttachment(a);
    busyAttachments.remove(a.id);
    update();
    if (err != null) MDialogs.error(err);
  }

  Future<void> deleteAttachment(EmployeeAttachmentItem a) async {
    final ok = await employeeConfirm(
      title: 'حذف المرفق',
      message: 'هل تريد حذف "${a.label}"؟',
      confirmText: 'حذف',
      confirmColor: MColors.danger,
    );
    if (!ok) return;
    busyAttachments.add(a.id);
    update();
    final r = await EmployeeManagerService.deleteAttachment(a.id);
    busyAttachments.remove(a.id);
    if (r.ok) {
      MDialogs.success('تم حذف المرفق');
      await loadAttachments();
    } else {
      update();
      MDialogs.error(r.messageOr('تعذر حذف المرفق'));
    }
  }

  // ---------------------------------------------------------------- الصورة

  void _setBusy(String? label) {
    busy = label != null;
    busyLabel = label;
    update();
  }

  Future<void> changePhoto() async {
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    if (f.path == null) {
      MDialogs.error('تعذر قراءة الصورة المختارة');
      return;
    }
    final ext = (f.extension ?? '').toLowerCase();
    if (!['png', 'jpg', 'jpeg'].contains(ext)) {
      MDialogs.error('يُسمح بصور بصيغة PNG أو JPG فقط');
      return;
    }
    if (f.size > EmployeeManagerService.maxAttachmentBytes) {
      MDialogs.error('حجم الصورة يتجاوز الحد المسموح (16 ميجابايت)');
      return;
    }
    final oldId = employee.photoAttachmentId;
    _setBusy('جاري رفع الصورة...');
    final r = await EmployeeManagerService.uploadAttachment(
      employeeId,
      label: EmployeeLabels.photoLabel,
      filePath: f.path!,
    );
    if (!r.ok) {
      _setBusy(null);
      MDialogs.error(r.messageOr('تعذر رفع الصورة'));
      return;
    }
    if (oldId != null) {
      await EmployeeManagerService.deleteAttachment(oldId);
      list.forgetPhoto(oldId);
    }
    await list.load(silent: true);
    _setBusy(null);
    MDialogs.success('تم تحديث صورة الموظف');
  }

  Future<void> deletePhoto() async {
    final oldId = employee.photoAttachmentId;
    if (oldId == null) return;
    final ok = await employeeConfirm(
      title: 'حذف الصورة',
      message: 'هل تريد حذف صورة الموظف؟',
      confirmText: 'حذف',
      confirmColor: MColors.danger,
    );
    if (!ok) return;
    _setBusy('جاري حذف الصورة...');
    final r = await EmployeeManagerService.deleteAttachment(oldId);
    if (r.ok) {
      list.forgetPhoto(oldId);
      await list.load(silent: true);
      _setBusy(null);
      MDialogs.success('تم حذف الصورة');
    } else {
      _setBusy(null);
      MDialogs.error(r.messageOr('تعذر حذف الصورة'));
    }
  }

  // ------------------------------------------------------ الحالة والحذف

  bool get statusBusy => list.busyIds.contains(employeeId);

  Future<void> toggleActive() async {
    await list.toggleActive(employee);
    update();
  }

  /// يُرجع true عند الحذف (لتغلق الصفحة نفسها)
  Future<bool> deleteEmployee() => list.deleteEmployee(employee);
}
