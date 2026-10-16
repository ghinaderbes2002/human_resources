// attendance_manager_controller.dart
// منطق شاشة "إدارة الحضور" للمدراء: ملخص اليوم، الغائبون، التسجيل والحذف (فردي وجماعي)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/manager/attendance_manager_service.dart';
import 'package:human_resources/model/manager/attendance_models.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class AttendanceManagerController extends GetxController {
  final AttendanceManagerService _service = AttendanceManagerService();

  Staterequest staterequest = Staterequest.none;
  String? errorMessage;

  DateTime selectedDate = DateTime.now();
  String get dateStr => MFormat.date(selectedDate);

  List<AttendanceSummaryRecord> records = [];
  List<AbsentEmployee> absent = [];
  bool absentLoading = false;
  String? absentError;

  // الفلاتر
  String search = '';
  bool incompleteOnly = false;

  // التحديد المتعدد
  final Set<int> selectedIds = {};
  bool get selectionMode => selectedIds.isNotEmpty;

  /// عملية جارية (تسجيل/حذف)
  bool busy = false;

  int _loadToken = 0;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  // ---------------------------------------------------------------------------
  // البيانات المشتقة
  // ---------------------------------------------------------------------------

  List<AttendanceSummaryRecord> get filtered {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return records;
    return records.where((r) {
      return r.employee.fullName.toLowerCase().contains(q) ||
          (r.employee.fingerprintId ?? '').toLowerCase().contains(q);
    }).toList();
  }

  int get presentCount => records.where((r) => r.hasCheckIn).length;
  int get lateCount => records.where((r) => r.isLate).length;
  int get noCheckOutCount => records.where((r) => r.missingCheckOut).length;
  int get absentCount => absent.length;

  List<AttendanceSummaryRecord> get selectedRecords =>
      records.where((r) => selectedIds.contains(r.empId)).toList();

  List<AttendanceSummaryRecord> get selectedCheckoutable =>
      selectedRecords.where((r) => r.canCheckOut).toList();

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  // ---------------------------------------------------------------------------
  // التحميل
  // ---------------------------------------------------------------------------

  /// تحميل السجلات والغائبين. [silent] يُبقي البيانات الحالية ظاهرة أثناء التحديث.
  Future<void> loadAll({bool silent = false}) async {
    final token = ++_loadToken;
    if (!silent || staterequest != Staterequest.success) {
      staterequest = Staterequest.loading;
      errorMessage = null;
    }
    absentLoading = true;
    update();

    final (summary, absentRes) = await (
      _service.fetchSummary(date: dateStr, incompleteOnly: incompleteOnly),
      _service.fetchAbsent(dateStr),
    ).wait;
    if (token != _loadToken) return; // طلب أحدث قيد التنفيذ

    if (summary.ok) {
      records = summary.data ?? [];
      staterequest = Staterequest.success;
      errorMessage = null;
      // إزالة المحددين الذين لم يعودوا في القائمة
      final ids = records.map((r) => r.empId).toSet();
      selectedIds.removeWhere((id) => !ids.contains(id));
    } else {
      records = [];
      selectedIds.clear();
      staterequest = Staterequest.failure;
      errorMessage = summary.message;
    }

    absentLoading = false;
    if (absentRes.ok) {
      absent = absentRes.data ?? [];
      absentError = null;
    } else {
      absent = [];
      absentError = absentRes.message;
    }
    update();
  }

  Future<void> refreshData() => loadAll(silent: true);

  void setDate(DateTime d) {
    selectedDate = DateTime(d.year, d.month, d.day);
    selectedIds.clear();
    loadAll();
  }

  void shiftDate(int days) => setDate(selectedDate.add(Duration(days: days)));

  void setSearch(String v) {
    search = v;
    update();
  }

  void toggleIncomplete(bool v) {
    incompleteOnly = v;
    selectedIds.clear();
    loadAll();
  }

  void clearFilters() {
    search = '';
    if (incompleteOnly) {
      toggleIncomplete(false);
    } else {
      update();
    }
  }

  // ---------------------------------------------------------------------------
  // التحديد
  // ---------------------------------------------------------------------------

  void toggleSelect(AttendanceSummaryRecord r) {
    if (!selectedIds.remove(r.empId)) selectedIds.add(r.empId);
    update();
  }

  void selectAllVisible() {
    final visible = filtered.map((r) => r.empId).toSet();
    if (visible.every(selectedIds.contains)) {
      selectedIds.removeAll(visible);
    } else {
      selectedIds.addAll(visible);
    }
    update();
  }

  void clearSelection() {
    selectedIds.clear();
    update();
  }

  // ---------------------------------------------------------------------------
  // الإجراءات
  // ---------------------------------------------------------------------------

  void _setBusy(bool v) {
    busy = v;
    update();
  }

  /// تسجيل حضور لموظف واحد أو أكثر. يُرجع true عند نجاح واحد على الأقل.
  Future<bool> checkIn(List<AbsentEmployee> employees, TimeOfDay time, String reason) async {
    if (employees.isEmpty) return false;
    final t = MFormat.timeOfDay(time);
    _setBusy(true);
    final res = await _service.checkIn(employees
        .map((e) => AttendancePunchEntry(empId: e.id, time: t, reason: reason, date: dateStr))
        .toList());
    _setBusy(false);
    _showOutcome(res, employees.map((e) => e.fullName).toList(),
        successText: 'تم تسجيل الحضور بنجاح', title: 'نتيجة تسجيل الحضور');
    if (res.success > 0) await refreshData();
    return res.success > 0;
  }

  /// تسجيل انصراف لموظف واحد أو أكثر
  Future<bool> checkOut(
    List<AttendanceSummaryRecord> targets,
    TimeOfDay time,
    String reason,
  ) async {
    final list = targets.where((r) => r.canCheckOut).toList();
    if (list.isEmpty) {
      MDialogs.error('لا يوجد موظفون بحاجة لتسجيل انصراف');
      return false;
    }
    final t = MFormat.timeOfDay(time);
    _setBusy(true);
    final res = await _service.checkOut(list
        .map((r) => AttendancePunchEntry(empId: r.empId, time: t, reason: reason, date: dateStr))
        .toList());
    _setBusy(false);
    _showOutcome(res, list.map((r) => r.employee.fullName).toList(),
        successText: 'تم تسجيل الانصراف بنجاح', title: 'نتيجة تسجيل الانصراف');
    if (res.success > 0) {
      selectedIds.removeAll(list.map((r) => r.empId));
      await refreshData();
    }
    return res.success > 0;
  }

  Future<bool> bulkCheckOut(TimeOfDay time, String reason) =>
      checkOut(selectedCheckoutable, time, reason);

  /// حذف سجل اليوم لموظف (مع تأكيد)
  Future<bool> deleteDay(AttendanceSummaryRecord r) async {
    final confirmed = await MDialogs.confirm(
      title: 'حذف سجل اليوم',
      message: 'هل تريد حذف جميع سجلات حضور "${r.employee.fullName}" بتاريخ $dateStr؟',
      confirmText: 'حذف',
      confirmColor: MColors.danger,
    );
    if (!confirmed) return false;
    _setBusy(true);
    final res = await _service.deleteDay(r.empId, dateStr);
    _setBusy(false);
    if (res.ok) {
      selectedIds.remove(r.empId);
      MDialogs.success('تم حذف سجل اليوم لـ ${r.employee.fullName}');
      await refreshData();
      return true;
    }
    MDialogs.error(res.messageOr('فشل حذف السجل'));
    return false;
  }

  /// حذف فترة حضور واحدة (مع تأكيد)
  Future<bool> deletePeriod(AttendanceSummaryRecord r, AttendancePeriod p) async {
    if (p.attendanceId == null) return false;
    final confirmed = await MDialogs.confirm(
      title: 'حذف الفترة',
      message:
          'هل تريد حذف الفترة (${MFormat.time(p.checkInTime)} - ${MFormat.time(p.checkOutTime)}) للموظف "${r.employee.fullName}"؟',
      confirmText: 'حذف',
      confirmColor: MColors.danger,
    );
    if (!confirmed) return false;
    _setBusy(true);
    final res = await _service.deletePeriod(r.empId, dateStr, p.attendanceId!);
    _setBusy(false);
    if (res.ok) {
      MDialogs.success('تم حذف الفترة بنجاح');
      await refreshData();
      return true;
    }
    MDialogs.error(res.messageOr('فشل حذف الفترة'));
    return false;
  }

  /// حذف سجلات اليوم للموظفين المحددين (بالتتابع)
  Future<void> deleteSelected() async {
    final list = selectedRecords;
    if (list.isEmpty) return;
    final confirmed = await MDialogs.confirm(
      title: 'حذف المحدد',
      message: 'هل تريد حذف سجلات حضور ${list.length} موظف بتاريخ $dateStr؟',
      confirmText: 'حذف',
      confirmColor: MColors.danger,
    );
    if (!confirmed) return;
    _setBusy(true);
    int ok = 0;
    final failures = <String>[];
    for (final r in list) {
      final res = await _service.deleteDay(r.empId, dateStr);
      if (res.ok) {
        ok++;
        selectedIds.remove(r.empId);
      } else {
        failures.add('${r.employee.fullName}: ${res.messageOr('فشل الحذف')}');
      }
    }
    _setBusy(false);
    if (failures.isEmpty) {
      MDialogs.success('تم حذف سجلات $ok موظف');
    } else if (ok == 0) {
      MDialogs.error(failures.join('\n'));
    } else {
      _showFailuresDialog('نتيجة الحذف', 'نجح $ok / فشل ${failures.length}', failures);
    }
    if (ok > 0) await refreshData();
  }

  // ---------------------------------------------------------------------------
  // عرض النتائج
  // ---------------------------------------------------------------------------

  void _showOutcome(
    BulkActionResult res,
    List<String> names, {
    required String successText,
    required String title,
  }) {
    final failures = res.results.isEmpty
        ? <String>[]
        : res.failures.map((f) {
            final name = f.index >= 0 && f.index < names.length ? names[f.index] : null;
            final msg = f.message.isEmpty ? 'فشل' : f.message;
            return names.length > 1 && name != null ? '$name: $msg' : msg;
          }).toList();

    if (res.success > 0 && res.failed == 0) {
      MDialogs.success(names.length > 1 ? '$successText (${res.success})' : successText);
      return;
    }
    if (res.success == 0) {
      if (failures.isEmpty) {
        MDialogs.error(res.message ?? 'فشلت العملية');
      } else if (failures.length == 1) {
        MDialogs.error(failures.first);
      } else {
        _showFailuresDialog(title, 'نجح 0 / فشل ${res.failed}', failures);
      }
      return;
    }
    _showFailuresDialog(title, 'نجح ${res.success} / فشل ${res.failed}', failures);
  }

  void _showFailuresDialog(String title, String summary, List<String> failures) {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: MColors.textDark, fontSize: 15)),
                if (failures.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: failures.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (_, i) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 16, color: MColors.danger),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(failures[i],
                                style: const TextStyle(fontSize: 13, color: MColors.text)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            // Navigator بدلاً من Get.back حتى لا يُغلق الـ snackbar بدل النافذة
            Builder(
              builder: (ctx) => TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('حسناً', style: TextStyle(color: MColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
