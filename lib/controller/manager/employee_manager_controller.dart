// employee_manager_controller.dart
// متحكم قائمة "إدارة الموظفين": التحميل، البحث والتصفية، التفعيل والحذف، وذاكرة الصور.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/manager/employee_manager_service.dart';
import 'package:human_resources/core/services/user_session.dart';
import 'package:human_resources/model/manager/employee_models.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

/// نافذة تأكيد بعد إغلاق أي إشعار مفتوح
/// (Get.back داخل نافذة التأكيد يغلق الإشعار بدلاً من النافذة إذا كان ظاهراً)
Future<bool> employeeConfirm({
  required String title,
  required String message,
  String confirmText = 'تأكيد',
  Color confirmColor = MColors.primary,
}) {
  if (Get.isSnackbarOpen) Get.closeAllSnackbars();
  return MDialogs.confirm(
    title: title,
    message: message,
    confirmText: confirmText,
    confirmColor: confirmColor,
  );
}

enum EmployeeActiveFilter { all, active, inactive }

enum EmployeeTypeFilter { all, permanent, temporary }

class EmployeeManagerController extends GetxController {
  Staterequest status = Staterequest.none;
  String? errorMessage;
  List<ManagedEmployee> employees = [];

  UserSession? session;

  final TextEditingController searchCtrl = TextEditingController();
  String search = '';
  EmployeeActiveFilter activeFilter = EmployeeActiveFilter.all;
  EmployeeTypeFilter typeFilter = EmployeeTypeFilter.all;

  /// موظفون تجري عليهم عملية (تفعيل/حذف) حالياً
  final Set<int> busyIds = {};

  // ------------------------------------------------------------ ذاكرة الصور
  final Map<int, Uint8List> photoCache = {};
  final Map<int, Future<Uint8List?>> _photoFutures = {};

  // ------------------------------------------------------ القوائم المساعدة
  List<JobTitleItem>? _jobTitles;
  List<ProfessionItem>? _professions;
  List<ShiftItem>? _shifts;

  @override
  void onInit() {
    super.onInit();
    UserSession.load().then((s) {
      session = s;
      update();
    });
    load();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent || employees.isEmpty) {
      status = Staterequest.loading;
      errorMessage = null;
      update();
    }
    final res = await EmployeeManagerService.fetchEmployees();
    _failedPhotos.clear();
    if (res.ok) {
      employees = res.items
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
      status = employees.isEmpty ? Staterequest.empty : Staterequest.success;
      errorMessage = null;
    } else if (!silent || employees.isEmpty) {
      status = Staterequest.failure;
      errorMessage = res.error;
    } else {
      MDialogs.error(res.error ?? 'تعذر تحديث القائمة');
    }
    update();
  }

  // ------------------------------------------------------- البحث والتصفية

  void onSearch(String v) {
    search = v;
    update();
  }

  void clearSearch() {
    searchCtrl.clear();
    search = '';
    update();
  }

  void setActiveFilter(EmployeeActiveFilter f) {
    activeFilter = f;
    update();
  }

  void setTypeFilter(EmployeeTypeFilter f) {
    typeFilter = typeFilter == f ? EmployeeTypeFilter.all : f;
    update();
  }

  List<ManagedEmployee> get filtered => employees.where((e) {
        if (activeFilter == EmployeeActiveFilter.active && !e.isActive) return false;
        if (activeFilter == EmployeeActiveFilter.inactive && e.isActive) return false;
        if (typeFilter == EmployeeTypeFilter.permanent && !e.isPermanent) return false;
        if (typeFilter == EmployeeTypeFilter.temporary && !e.isTemporary) return false;
        return e.matches(search);
      }).toList();

  int get totalCount => employees.length;
  int get activeCount => employees.where((e) => e.isActive).length;
  int get inactiveCount => employees.where((e) => !e.isActive).length;
  int get permanentCount => employees.where((e) => e.isPermanent).length;
  int get temporaryCount => employees.where((e) => e.isTemporary).length;

  ManagedEmployee? byId(int id) {
    for (final e in employees) {
      if (e.id == id) return e;
    }
    return null;
  }

  // ------------------------------------------------------------- العمليات

  /// تفعيل/إلغاء تفعيل (مع تأكيد عند الإلغاء). يُرجع true عند النجاح.
  Future<bool> toggleActive(ManagedEmployee e) async {
    final activate = !e.isActive;
    if (!activate) {
      final ok = await employeeConfirm(
        title: 'إلغاء تفعيل الموظف',
        message:
            'هل تريد إلغاء تفعيل "${e.fullName}"؟\nلن يظهر في أي مكان بالنظام ولن يحتسب في الرواتب.',
        confirmText: 'إلغاء التفعيل',
        confirmColor: MColors.warning,
      );
      if (!ok) return false;
    }
    busyIds.add(e.id);
    update();
    final r = await EmployeeManagerService.toggleActive(e.id, activate);
    busyIds.remove(e.id);
    if (r.ok) {
      MDialogs.success(r.messageOr(activate ? 'تم تفعيل الموظف' : 'تم إلغاء تفعيل الموظف'));
      await load(silent: true);
      return true;
    }
    update();
    MDialogs.error(r.messageOr('تعذر تغيير حالة الموظف'));
    return false;
  }

  /// حذف موظف بعد التأكيد. يُرجع true عند النجاح.
  Future<bool> deleteEmployee(ManagedEmployee e) async {
    final ok = await employeeConfirm(
      title: 'حذف الموظف',
      message: 'هل أنت متأكد من حذف "${e.fullName}"؟ لا يمكن التراجع عن هذه العملية.',
      confirmText: 'حذف',
      confirmColor: MColors.danger,
    );
    if (!ok) return false;
    busyIds.add(e.id);
    update();
    final r = await EmployeeManagerService.deleteEmployee(e.id);
    busyIds.remove(e.id);
    if (r.ok) {
      MDialogs.success('تم حذف الموظف بنجاح');
      employees.removeWhere((x) => x.id == e.id);
      await load(silent: true);
      return true;
    }
    update();
    MDialogs.error(r.messageOr('تعذر حذف الموظف'));
    return false;
  }

  // ---------------------------------------------------------------- الصور

  /// جلب صورة (مع ذاكرة مؤقتة). لا يستدعي update().
  Future<Uint8List?> photo(int attachmentId) {
    final cached = photoCache[attachmentId];
    if (cached != null) return Future.value(cached);
    if (_failedPhotos.contains(attachmentId)) return Future.value(null);
    return _photoFutures.putIfAbsent(attachmentId, () async {
      final bytes = await EmployeeManagerService.downloadAttachment(attachmentId);
      if (bytes != null && bytes.isNotEmpty) {
        photoCache[attachmentId] = bytes;
        return bytes;
      }
      // لا نعيد المحاولة إلا بعد تحديث القائمة
      _failedPhotos.add(attachmentId);
      Future.microtask(() => _photoFutures.remove(attachmentId));
      return null;
    });
  }

  final Set<int> _failedPhotos = {};

  void forgetPhoto(int? attachmentId) {
    if (attachmentId == null) return;
    photoCache.remove(attachmentId);
    _photoFutures.remove(attachmentId);
    _failedPhotos.remove(attachmentId);
  }

  // ------------------------------------------------------- القوائم المساعدة

  Future<ListResult<JobTitleItem>> jobTitles({bool force = false}) async {
    if (_jobTitles != null && !force) return ListResult(_jobTitles!);
    final r = await EmployeeManagerService.fetchJobTitles();
    if (r.ok) _jobTitles = r.items;
    return r;
  }

  Future<ListResult<ProfessionItem>> professions({bool force = false}) async {
    if (_professions != null && !force) return ListResult(_professions!);
    final r = await EmployeeManagerService.fetchProfessions();
    if (r.ok) _professions = r.items;
    return r;
  }

  Future<ListResult<ShiftItem>> shifts({bool force = false}) async {
    if (_shifts != null && !force) return ListResult(_shifts!);
    final r = await EmployeeManagerService.fetchShifts();
    if (r.ok) _shifts = r.items;
    return r;
  }

  String? shiftName(int? id) {
    if (id == null) return null;
    for (final s in _shifts ?? const <ShiftItem>[]) {
      if (s.id == id) return s.name;
    }
    return null;
  }

  /// الوصول للمتحكم من الشاشات الفرعية (ينشئه إن لم يكن موجوداً)
  static EmployeeManagerController get to =>
      Get.isRegistered<EmployeeManagerController>()
          ? Get.find<EmployeeManagerController>()
          : Get.put(EmployeeManagerController());
}
