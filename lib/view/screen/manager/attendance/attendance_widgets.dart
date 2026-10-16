// attendance_widgets.dart
// عناصر مشتركة لشاشة "إدارة الحضور": بطاقة السجل، شارات الحالة، منتقي الوقت، غلاف الـ bottom sheet
import 'package:flutter/material.dart';
import 'package:human_resources/model/manager/attendance_models.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

const _weekdays = [
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

String arabicWeekday(DateTime d) => _weekdays[d.weekday - 1];

Color checkInStatusColor(String? s) {
  switch (s) {
    case 'Late':
      return MColors.warning;
    case 'On Time':
      return MColors.success;
    case 'Recorded':
      return MColors.info;
    default:
      return MColors.textMuted;
  }
}

Color checkOutStatusColor(String? s) {
  switch (s) {
    case 'Early':
      return MColors.warning;
    case 'On Time':
      return MColors.success;
    case 'No Check-out':
      return MColors.danger;
    case 'Recorded':
      return MColors.info;
    default:
      return MColors.textMuted;
  }
}

Widget checkInStatusChip(String? s) => MChip(
      AttendanceSummaryRecord.checkInStatusLabel(s),
      color: checkInStatusColor(s),
      icon: s == 'Late' ? Icons.schedule_rounded : Icons.login_rounded,
    );

Widget checkOutStatusChip(String? s) => MChip(
      AttendanceSummaryRecord.checkOutStatusLabel(s),
      color: checkOutStatusColor(s),
      icon: Icons.logout_rounded,
    );

ThemeData _pickerTheme(BuildContext context) => Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: MColors.primary),
    );

/// منتقي وقت بنظام 24 ساعة
Future<TimeOfDay?> pickAttendanceTime(BuildContext context, TimeOfDay initial) {
  return showTimePicker(
    context: context,
    initialTime: initial,
    helpText: 'اختر الوقت',
    cancelText: 'إلغاء',
    confirmText: 'تم',
    builder: (ctx, child) => Theme(
      data: _pickerTheme(ctx),
      child: MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    ),
  );
}

Future<DateTime?> pickAttendanceDate(BuildContext context, DateTime initial) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2020),
    lastDate: DateTime(now.year, now.month, now.day),
    helpText: 'اختر التاريخ',
    cancelText: 'إلغاء',
    confirmText: 'تم',
    builder: (ctx, child) => Theme(data: _pickerTheme(ctx), child: child!),
  );
}

String formatTimeOfDay(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// فتح bottom sheet بواجهة RTL وخلفية بيضاء بحواف دائرية
Future<T?> showAttendanceSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(top: false, child: builder(ctx)),
        ),
      ),
    ),
  );
}

/// ترويسة الـ sheet (مقبض + عنوان + وصف)
class AttendanceSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const AttendanceSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.color = MColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: MColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: MColors.textDark)),
                    if (subtitle != null)
                      Text(subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, color: MColors.textMuted)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: MColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// حقل اختيار وقت
class AttendanceTimeField extends StatelessWidget {
  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  const AttendanceTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final t = await pickAttendanceTime(context, value);
        if (t != null) onChanged(t);
      },
      child: InputDecorator(
        decoration: mInputDecoration(label, icon: Icons.access_time_rounded),
        child: Text(
          formatTimeOfDay(value),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: MColors.textDark),
        ),
      ),
    );
  }
}

/// زر رئيسي بعرض كامل مع حالة تحميل
class AttendancePrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;
  final Color color;

  const AttendancePrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.color = MColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}

/// بطاقة سجل حضور موظف في القائمة
class AttendanceRecordCard extends StatelessWidget {
  final AttendanceSummaryRecord record;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onCheckOut;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  const AttendanceRecordCard({
    super.key,
    required this.record,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckOut,
    required this.onDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final r = record;
    final name = r.employee.fullName;
    final showCheckoutStatus =
        r.checkOutStatus != null && r.checkOutStatus != 'No Check-out';

    return Container(
      decoration: mCardDecoration().copyWith(
        border: Border.all(
          color: selected ? MColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (selectionMode) ...[
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? MColors.primary : MColors.textLight,
                      ),
                      const SizedBox(width: 8),
                    ],
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: MColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        name.isNotEmpty ? name.characters.first : '?',
                        style: const TextStyle(
                            color: MColors.primary, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: MColors.textDark)),
                          const SizedBox(height: 2),
                          Text(
                            'بصمة: ${r.employee.fingerprintId ?? '-'}',
                            style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    checkInStatusChip(r.checkInStatus),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TimeBox(
                      label: 'الدخول',
                      value: MFormat.time(r.firstCheckIn ?? r.actualCheckIn),
                      icon: Icons.login_rounded,
                      color: MColors.success,
                    ),
                    const SizedBox(width: 8),
                    _TimeBox(
                      label: 'الخروج',
                      value: MFormat.time(r.lastCheckOut ?? r.actualCheckOut),
                      icon: Icons.logout_rounded,
                      color: MColors.danger,
                    ),
                    const SizedBox(width: 8),
                    _TimeBox(
                      label: 'ساعات العمل',
                      value: r.workTimeShort,
                      icon: Icons.timer_outlined,
                      color: MColors.info,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: r.workProgress,
                    minHeight: 5,
                    backgroundColor: MColors.border,
                    color: r.workProgress >= 1 ? MColors.success : MColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(r.workProgress * 100).round()}% من 8 ساعات',
                  style: const TextStyle(fontSize: 11, color: MColors.textLight),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (showCheckoutStatus)
                      MChip(
                        'الخروج: ${AttendanceSummaryRecord.checkOutStatusLabel(r.checkOutStatus)}',
                        color: checkOutStatusColor(r.checkOutStatus),
                        icon: Icons.logout_rounded,
                      ),
                    if (r.missingCheckOut)
                      const MChip('لم يسجل خروج',
                          color: MColors.danger, icon: Icons.warning_amber_rounded),
                    if (r.periods.length > 1)
                      MChip('${r.periods.length} فترات',
                          color: MColors.textMuted, icon: Icons.layers_outlined),
                  ],
                ),
                if (!selectionMode) ...[
                  const Divider(height: 18),
                  Row(
                    children: [
                      if (r.canCheckOut)
                        _ActionButton(
                          label: 'تسجيل انصراف',
                          icon: Icons.logout_rounded,
                          color: MColors.primary,
                          onTap: onCheckOut,
                        ),
                      _ActionButton(
                        label: 'تفاصيل',
                        icon: Icons.info_outline_rounded,
                        color: MColors.info,
                        onTap: onDetails,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'حذف سجل اليوم',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, color: MColors.danger),
                      ),
                    ],
                  ),
                ] else
                  const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TimeBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: MColors.textMuted)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: MColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}
