// attendance_sheets.dart
// نوافذ (bottom sheets) شاشة "إدارة الحضور": تسجيل انصراف، تسجيل حضور، التفاصيل، الغائبون
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/attendance_manager_controller.dart';
import 'package:human_resources/model/manager/attendance_models.dart';
import 'package:human_resources/view/screen/manager/attendance/attendance_widgets.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

// =============================================================================
// تسجيل انصراف (فردي أو جماعي)
// =============================================================================

Future<void> openCheckOutSheet(BuildContext context, List<AttendanceSummaryRecord> targets) {
  return showAttendanceSheet(context, (_) => CheckOutSheet(targets: targets));
}

class CheckOutSheet extends StatefulWidget {
  final List<AttendanceSummaryRecord> targets;
  const CheckOutSheet({super.key, required this.targets});

  @override
  State<CheckOutSheet> createState() => _CheckOutSheetState();
}

class _CheckOutSheetState extends State<CheckOutSheet> {
  final _reason = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final c = Get.find<AttendanceManagerController>();
    final ok = await c.checkOut(widget.targets, _time, _reason.text.trim());
    if (!mounted) return;
    setState(() => _submitting = false);
    // إزالة الـ sheet نفسه (قد تكون نافذة النتيجة مفتوحة فوقه)
    final route = ModalRoute.of(context);
    if (ok && route != null && route.isActive) Navigator.of(context).removeRoute(route);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.targets;
    final bulk = t.length > 1;
    final c = Get.find<AttendanceManagerController>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AttendanceSheetHeader(
            title: bulk ? 'تسجيل انصراف جماعي' : 'تسجيل انصراف',
            subtitle: bulk
                ? '${t.length} موظف · ${c.dateStr}'
                : '${t.first.employee.fullName} · ${c.dateStr}',
            icon: Icons.logout_rounded,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (bulk) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: t
                        .take(12)
                        .map((r) => MChip(r.employee.fullName, color: MColors.info))
                        .toList()
                      ..addAll(t.length > 12
                          ? [MChip('+${t.length - 12}', color: MColors.textMuted)]
                          : []),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  Text(
                    'آخر دخول: ${MFormat.time(t.first.periods.isNotEmpty ? t.first.periods.last.checkInTime : t.first.firstCheckIn)}',
                    style: const TextStyle(fontSize: 13, color: MColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                ],
                AttendanceTimeField(
                  label: 'وقت الانصراف',
                  value: _time,
                  onChanged: (v) => setState(() => _time = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reason,
                  maxLines: 2,
                  decoration: mInputDecoration('سبب الانصراف (اختياري)',
                      icon: Icons.notes_rounded),
                ),
                const SizedBox(height: 18),
                AttendancePrimaryButton(
                  label: bulk ? 'تسجيل الانصراف (${t.length})' : 'تسجيل الانصراف',
                  icon: Icons.check_rounded,
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// تسجيل حضور (اختيار من الغائبين)
// =============================================================================

Future<void> openCheckInSheet(BuildContext context, {Set<int>? preselected}) {
  return showAttendanceSheet(context, (_) => CheckInSheet(preselected: preselected));
}

class CheckInSheet extends StatefulWidget {
  final Set<int>? preselected;
  const CheckInSheet({super.key, this.preselected});

  @override
  State<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<CheckInSheet> {
  final _reason = TextEditingController();
  late final Set<int> _selected = {...?widget.preselected};
  TimeOfDay _time = TimeOfDay.now();
  String _search = '';
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  List<AbsentEmployee> _visible(List<AbsentEmployee> all) {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((e) => e.fullName.toLowerCase().contains(q)).toList();
  }

  Future<void> _submit(AttendanceManagerController c) async {
    final chosen = c.absent.where((e) => _selected.contains(e.id)).toList();
    if (chosen.isEmpty) {
      MDialogs.error('يرجى اختيار موظف واحد على الأقل');
      return;
    }
    setState(() => _submitting = true);
    final ok = await c.checkIn(chosen, _time, _reason.text.trim());
    if (!mounted) return;
    setState(() => _submitting = false);
    // إزالة الـ sheet نفسه (قد تكون نافذة النتيجة مفتوحة فوقه)
    final route = ModalRoute.of(context);
    if (ok && route != null && route.isActive) Navigator.of(context).removeRoute(route);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final height = (mq.size.height * 0.88 - mq.viewInsets.bottom)
        .clamp(320.0, mq.size.height * 0.88)
        .toDouble();

    return GetBuilder<AttendanceManagerController>(
      builder: (c) {
        final visible = _visible(c.absent);
        final allVisibleSelected =
            visible.isNotEmpty && visible.every((e) => _selected.contains(e.id));
        return SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AttendanceSheetHeader(
                title: 'تسجيل حضور',
                subtitle: 'اختر الموظفين الغائبين · ${c.dateStr}',
                icon: Icons.login_rounded,
                color: MColors.success,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MSearchField(
                  hint: 'بحث بالاسم',
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: visible.isEmpty
                          ? null
                          : () => setState(() {
                                if (allVisibleSelected) {
                                  _selected.removeAll(visible.map((e) => e.id));
                                } else {
                                  _selected.addAll(visible.map((e) => e.id));
                                }
                              }),
                      icon: Icon(
                        allVisibleSelected
                            ? Icons.deselect_rounded
                            : Icons.select_all_rounded,
                        size: 18,
                        color: MColors.primary,
                      ),
                      label: Text(
                        allVisibleSelected ? 'إلغاء التحديد' : 'تحديد الكل',
                        style: const TextStyle(color: MColors.primary),
                      ),
                    ),
                    const Spacer(),
                    Text('المحدد: ${_selected.length}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: MColors.textDark)),
                  ],
                ),
              ),
              Expanded(child: _buildList(c, visible)),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AttendanceTimeField(
                            label: 'وقت الحضور',
                            value: _time,
                            onChanged: (v) => setState(() => _time = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _reason,
                            decoration: mInputDecoration('السبب (اختياري)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AttendancePrimaryButton(
                      label: _selected.length > 1
                          ? 'تسجيل الحضور (${_selected.length})'
                          : 'تسجيل الحضور',
                      icon: Icons.check_rounded,
                      color: MColors.success,
                      loading: _submitting,
                      onPressed: _selected.isEmpty ? null : () => _submit(c),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(AttendanceManagerController c, List<AbsentEmployee> visible) {
    if (c.absentLoading && c.absent.isEmpty) return const MLoading();
    if (c.absentError != null && c.absent.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [MMessage.error(c.absentError!, onRetry: c.refreshData)],
      );
    }
    if (c.absent.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          MMessage.empty('لا يوجد موظفون غائبون في هذا اليوم',
              icon: Icons.how_to_reg_outlined),
        ],
      );
    }
    if (visible.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          MMessage.empty('لا توجد نتائج مطابقة', icon: Icons.search_off_rounded),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: visible.length,
      itemBuilder: (_, i) {
        final e = visible[i];
        final checked = _selected.contains(e.id);
        return CheckboxListTile(
          value: checked,
          dense: true,
          activeColor: MColors.primary,
          controlAffinity: ListTileControlAffinity.leading,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(e.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600, color: MColors.textDark)),
          onChanged: (v) => setState(() {
            if (v == true) {
              _selected.add(e.id);
            } else {
              _selected.remove(e.id);
            }
          }),
        );
      },
    );
  }
}

// =============================================================================
// قائمة الغائبين
// =============================================================================

Future<void> openAbsentSheet(BuildContext context) {
  return showAttendanceSheet(context, (_) => const AbsentListSheet());
}

class AbsentListSheet extends StatelessWidget {
  const AbsentListSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return GetBuilder<AttendanceManagerController>(
      builder: (c) {
        Widget content;
        if (c.absentLoading && c.absent.isEmpty) {
          content = const MLoading();
        } else if (c.absentError != null && c.absent.isEmpty) {
          content = Padding(
            padding: const EdgeInsets.all(20),
            child: MMessage.error(c.absentError!, onRetry: c.refreshData),
          );
        } else if (c.absent.isEmpty) {
          content = const Padding(
            padding: EdgeInsets.all(20),
            child: MMessage.empty('لا يوجد موظفون غائبون في هذا اليوم',
                icon: Icons.how_to_reg_outlined),
          );
        } else {
          content = ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: c.absent.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = c.absent[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: MColors.danger.withValues(alpha: 0.1),
                  child: Text(
                    e.fullName.isNotEmpty ? e.fullName.characters.first : '?',
                    style: const TextStyle(
                        color: MColors.danger, fontWeight: FontWeight.w700),
                  ),
                ),
                title: Text(e.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: MColors.textDark)),
                trailing: TextButton(
                  onPressed: () {
                    final nav = Navigator.of(context);
                    final parent = nav.context;
                    nav.pop();
                    openCheckInSheet(parent, preselected: {e.id});
                  },
                  child: const Text('تسجيل حضور',
                      style: TextStyle(color: MColors.success, fontWeight: FontWeight.w600)),
                ),
              );
            },
          );
        }

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AttendanceSheetHeader(
                title: 'الغائبون',
                subtitle: '${c.absent.length} موظف · ${c.dateStr}',
                icon: Icons.person_off_outlined,
                color: MColors.danger,
              ),
              Flexible(child: content),
              if (c.absent.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: AttendancePrimaryButton(
                    label: 'تسجيل حضور',
                    icon: Icons.login_rounded,
                    color: MColors.success,
                    onPressed: () {
                      final nav = Navigator.of(context);
                      final parent = nav.context;
                      nav.pop();
                      openCheckInSheet(parent);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// تفاصيل سجل الموظف لليوم
// =============================================================================

Future<void> openDetailsSheet(BuildContext context, AttendanceSummaryRecord record) {
  return showAttendanceSheet(
    context,
    (_) => AttendanceDetailsSheet(empId: record.empId, initial: record),
  );
}

class AttendanceDetailsSheet extends StatelessWidget {
  final int empId;
  final AttendanceSummaryRecord initial;

  const AttendanceDetailsSheet({super.key, required this.empId, required this.initial});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return GetBuilder<AttendanceManagerController>(
      builder: (c) {
        // نأخذ النسخة المحدثة من القائمة بعد أي إعادة تحميل
        final r = c.records.firstWhereOrNull((x) => x.empId == empId);
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mq.size.height * 0.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AttendanceSheetHeader(
                title: initial.employee.fullName,
                subtitle:
                    'بصمة: ${initial.employee.fingerprintId ?? '-'} · ${initial.employee.workSystemLabel} · ${c.dateStr}',
                icon: Icons.badge_outlined,
                color: MColors.info,
              ),
              if (c.busy)
                const LinearProgressIndicator(minHeight: 2, color: MColors.primary),
              Flexible(
                child: r == null
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: MMessage.empty('لا توجد سجلات لهذا الموظف في هذا اليوم'),
                      )
                    : _DetailsBody(record: r),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final AttendanceSummaryRecord record;
  const _DetailsBody({required this.record});

  @override
  Widget build(BuildContext context) {
    final r = record;
    final c = Get.find<AttendanceManagerController>();
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        // ملخص
        Row(
          children: [
            _InfoTile(
              label: 'إجمالي العمل',
              value: r.workTimeShort,
              icon: Icons.timer_outlined,
              color: MColors.info,
            ),
            const SizedBox(width: 10),
            _InfoTile(
              label: 'إجمالي الاستراحة',
              value: r.breakTimeShort,
              icon: Icons.coffee_outlined,
              color: MColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _InfoTile(
              label: 'أول دخول',
              value: MFormat.time(r.firstCheckIn ?? r.actualCheckIn),
              icon: Icons.login_rounded,
              color: MColors.success,
            ),
            const SizedBox(width: 10),
            _InfoTile(
              label: 'آخر خروج',
              value: MFormat.time(r.lastCheckOut ?? r.actualCheckOut),
              icon: Icons.logout_rounded,
              color: MColors.danger,
            ),
          ],
        ),
        if (r.requiredCheckIn != null || r.requiredCheckOut != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoTile(
                label: 'الدخول المطلوب',
                value: MFormat.time(r.requiredCheckIn),
                icon: Icons.schedule_rounded,
                color: MColors.textMuted,
              ),
              const SizedBox(width: 10),
              _InfoTile(
                label: 'الخروج المطلوب',
                value: MFormat.time(r.requiredCheckOut),
                icon: Icons.schedule_rounded,
                color: MColors.textMuted,
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('حالة الدخول',
                        style: TextStyle(fontSize: 13, color: MColors.textMuted)),
                  ),
                  checkInStatusChip(r.checkInStatus),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text('حالة الخروج',
                        style: TextStyle(fontSize: 13, color: MColors.textMuted)),
                  ),
                  checkOutStatusChip(r.checkOutStatus),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        MSectionTitle(
          'فترات الحضور',
          trailing: Text('${r.periods.length}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: MColors.textMuted)),
        ),
        const SizedBox(height: 10),
        if (r.periods.isEmpty)
          const MMessage.empty('لا توجد فترات')
        else
          ...List.generate(r.periods.length, (i) {
            final p = r.periods[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PeriodCard(
                index: i + 1,
                period: p,
                deleting: c.busy,
                onDelete: p.attendanceId == null ? null : () => c.deletePeriod(r, p),
              ),
            );
          }),
        const SizedBox(height: 8),
        if (r.canCheckOut) ...[
          AttendancePrimaryButton(
            label: 'تسجيل انصراف',
            icon: Icons.logout_rounded,
            onPressed: () {
              final nav = Navigator.of(context);
              final parent = nav.context;
              nav.pop();
              openCheckOutSheet(parent, [r]);
            },
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: MColors.danger,
              side: const BorderSide(color: MColors.danger),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: c.busy
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    final ok = await c.deleteDay(r);
                    if (ok && nav.mounted) nav.pop();
                  },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('حذف سجل اليوم', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: MColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(value,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800, color: MColors.textDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final int index;
  final AttendancePeriod period;
  final bool deleting;
  final VoidCallback? onDelete;

  const _PeriodCard({
    required this.index,
    required this.period,
    required this.deleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = period;
    final open = p.checkOutTime == null;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('الفترة $index',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: MColors.textDark, fontSize: 14)),
              const SizedBox(width: 8),
              if (open)
                const MChip('مفتوحة', color: MColors.warning, icon: Icons.timelapse_rounded),
              const Spacer(),
              TextButton.icon(
                onPressed: deleting ? null : onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: MColors.danger,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('حذف الفترة', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _periodLine(Icons.login_rounded, MColors.success, 'دخول',
                    MFormat.time(p.checkInTime)),
              ),
              Expanded(
                child: _periodLine(Icons.logout_rounded, MColors.danger, 'خروج',
                    MFormat.time(p.checkOutTime)),
              ),
            ],
          ),
          if (p.checkInReason != null) ...[
            const SizedBox(height: 6),
            _reasonLine('سبب الدخول', p.checkInReason!),
          ],
          if (p.checkOutReason != null) ...[
            const SizedBox(height: 4),
            _reasonLine('سبب الخروج', p.checkOutReason!),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _periodLine(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: MColors.textMuted)),
        Text(value,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: MColors.textDark)),
      ],
    );
  }

  Widget _reasonLine(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
              text: '$label: ',
              style: const TextStyle(color: MColors.textMuted, fontWeight: FontWeight.w600)),
          TextSpan(text: value, style: const TextStyle(color: MColors.text)),
        ],
      ),
      style: const TextStyle(fontSize: 12.5),
    );
  }
}
