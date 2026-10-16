// AttendanceManagementPage.dart
// شاشة "إدارة الحضور" للمدراء (رئيس/نائب فرع أو قسم) — مطابقة لصفحة الويب /employees/attendance
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/attendance_manager_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/model/manager/attendance_models.dart';
import 'package:human_resources/view/screen/manager/attendance/attendance_sheets.dart';
import 'package:human_resources/view/screen/manager/attendance/attendance_widgets.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class AttendanceManagementPage extends StatefulWidget {
  const AttendanceManagementPage({super.key});

  @override
  State<AttendanceManagementPage> createState() => _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.put(AttendanceManagerController());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    if (Get.isRegistered<AttendanceManagerController>()) {
      Get.delete<AttendanceManagerController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceManagerController>(
      builder: (c) {
        return PopScope(
          canPop: !c.selectionMode,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) c.clearSelection();
          },
          child: ManagerScaffold(
            title: c.selectionMode ? 'تم تحديد ${c.selectedIds.length}' : 'إدارة الحضور',
            actions: c.selectionMode
                ? [
                    IconButton(
                      tooltip: 'تحديد الكل',
                      onPressed: c.selectAllVisible,
                      icon: const Icon(Icons.select_all_rounded),
                    ),
                    IconButton(
                      tooltip: 'إلغاء التحديد',
                      onPressed: c.clearSelection,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ]
                : [
                    IconButton(
                      tooltip: 'تحديث',
                      onPressed: c.busy ? null : () => c.loadAll(),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
            floatingActionButton: c.selectionMode
                ? null
                : FloatingActionButton.extended(
                    backgroundColor: MColors.primary,
                    foregroundColor: Colors.white,
                    onPressed: () => openCheckInSheet(context),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('تسجيل حضور',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: MColors.primary,
                        onRefresh: c.refreshData,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                              16, 16, 16, c.selectionMode ? 16 : 96),
                          children: [
                            _DateBar(controller: c),
                            const SizedBox(height: 14),
                            _StatsGrid(controller: c),
                            const SizedBox(height: 14),
                            MSearchField(
                              hint: 'بحث بالاسم أو رقم البصمة',
                              controller: _searchCtrl,
                              onChanged: c.setSearch,
                            ),
                            const SizedBox(height: 10),
                            _FilterRow(
                              controller: c,
                              onClear: () {
                                _searchCtrl.clear();
                                c.clearFilters();
                              },
                            ),
                            const SizedBox(height: 14),
                            ..._buildRecords(context, c),
                          ],
                        ),
                      ),
                    ),
                    if (c.selectionMode) _BulkBar(controller: c),
                  ],
                ),
                if (c.busy)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.08),
                      child: const Center(
                        child: CircularProgressIndicator(color: MColors.primary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildRecords(BuildContext context, AttendanceManagerController c) {
    final header = MSectionTitle(
      'سجلات الحضور',
      trailing: c.staterequest == Staterequest.success
          ? Text('${c.filtered.length} موظف',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: MColors.textMuted))
          : null,
    );

    Widget? state;
    switch (c.staterequest) {
      case Staterequest.loading:
      case Staterequest.none:
        state = const MLoading();
        break;
      case Staterequest.success:
        if (c.records.isEmpty) {
          state = MMessage.empty(
            c.incompleteOnly
                ? 'لا يوجد موظفون لم يسجلوا خروج في هذا اليوم'
                : 'لا توجد سجلات حضور لهذا اليوم',
            icon: Icons.event_busy_outlined,
          );
        } else if (c.filtered.isEmpty) {
          state = const MMessage.empty('لا توجد نتائج مطابقة للبحث',
              icon: Icons.search_off_rounded);
        }
        break;
      default:
        state = MMessage.error(
          c.errorMessage ?? 'تعذر تحميل سجلات الحضور',
          onRetry: () => c.loadAll(),
        );
    }

    if (state != null) return [header, const SizedBox(height: 12), state];

    final list = c.filtered;
    return [
      header,
      if (!c.selectionMode)
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('اضغط مطولاً على سجل لتحديد عدة موظفين',
              style: TextStyle(fontSize: 11.5, color: MColors.textLight)),
        ),
      const SizedBox(height: 12),
      for (final r in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AttendanceRecordCard(
            key: ValueKey('att-${r.empId}'),
            record: r,
            selectionMode: c.selectionMode,
            selected: c.selectedIds.contains(r.empId),
            onTap: () =>
                c.selectionMode ? c.toggleSelect(r) : openDetailsSheet(context, r),
            onLongPress: () => c.toggleSelect(r),
            onCheckOut: () => openCheckOutSheet(context, [r]),
            onDetails: () => openDetailsSheet(context, r),
            onDelete: () => c.deleteDay(r),
          ),
        ),
    ];
  }
}

// =============================================================================
// شريط التاريخ
// =============================================================================

class _DateBar extends StatelessWidget {
  final AttendanceManagerController controller;
  const _DateBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final d = c.selectedDate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: mCardDecoration(),
      child: Row(
        children: [
          IconButton(
            tooltip: 'اليوم السابق',
            onPressed: () => c.shiftDate(-1),
            icon: const Icon(Icons.chevron_right_rounded, color: MColors.textDark),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final picked = await pickAttendanceDate(context, d);
                if (picked != null) c.setDate(picked);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: MColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Text(
                          arabicWeekday(d),
                          style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                        ),
                        Text(
                          c.dateStr,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: MColors.textDark),
                        ),
                      ],
                    ),
                    if (c.isToday) ...[
                      const SizedBox(width: 8),
                      const MChip('اليوم', color: MColors.primary),
                    ],
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'اليوم التالي',
            onPressed: c.isToday ? null : () => c.shiftDate(1),
            icon: Icon(Icons.chevron_left_rounded,
                color: c.isToday ? MColors.border : MColors.textDark),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// بطاقات الإحصائيات
// =============================================================================

class _StatsGrid extends StatelessWidget {
  final AttendanceManagerController controller;
  const _StatsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final loading = c.staterequest == Staterequest.loading;
    String v(int n) => loading ? '...' : '$n';
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: [
        MStatCard(
          label: 'حاضر',
          value: v(c.presentCount),
          color: MColors.success,
          icon: Icons.how_to_reg_rounded,
        ),
        MStatCard(
          label: 'متأخر',
          value: v(c.lateCount),
          color: MColors.warning,
          icon: Icons.schedule_rounded,
        ),
        MStatCard(
          label: 'لم يسجل خروج',
          value: v(c.noCheckOutCount),
          color: MColors.info,
          icon: Icons.logout_rounded,
          onTap: c.incompleteOnly ? null : () => c.toggleIncomplete(true),
        ),
        MStatCard(
          label: 'غائب',
          value: c.absentLoading ? '...' : '${c.absentCount}',
          color: MColors.danger,
          icon: Icons.person_off_outlined,
          onTap: () => openAbsentSheet(context),
        ),
      ],
    );
  }
}

// =============================================================================
// الفلاتر
// =============================================================================

class _FilterRow extends StatelessWidget {
  final AttendanceManagerController controller;
  final VoidCallback onClear;
  const _FilterRow({required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Row(
      children: [
        FilterChip(
          selected: c.incompleteOnly,
          onSelected: c.toggleIncomplete,
          showCheckmark: true,
          checkmarkColor: MColors.primary,
          selectedColor: MColors.primary.withValues(alpha: 0.12),
          backgroundColor: Colors.white,
          side: BorderSide(color: c.incompleteOnly ? MColors.primary : MColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          label: Text(
            'لم يسجلوا خروج فقط',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.incompleteOnly ? MColors.primary : MColors.text,
            ),
          ),
        ),
        const Spacer(),
        if (c.search.isNotEmpty || c.incompleteOnly)
          TextButton(
            onPressed: onClear,
            child: const Text('مسح الفلاتر', style: TextStyle(color: MColors.textMuted)),
          ),
      ],
    );
  }
}

// =============================================================================
// شريط الإجراءات الجماعية
// =============================================================================

class _BulkBar extends StatelessWidget {
  final AttendanceManagerController controller;
  const _BulkBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final List<AttendanceSummaryRecord> checkoutable = c.selectedCheckoutable;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: MColors.border,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: checkoutable.isEmpty || c.busy
                      ? null
                      : () => openCheckOutSheet(context, checkoutable),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: FittedBox(
                    child: Text('تسجيل انصراف جماعي (${checkoutable.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: MColors.danger,
                  side: const BorderSide(color: MColors.danger),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: c.busy ? null : c.deleteSelected,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('حذف المحدد', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
