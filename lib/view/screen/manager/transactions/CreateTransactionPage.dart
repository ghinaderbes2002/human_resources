// CreateTransactionPage.dart
// إنشاء معاملة لموظف (سلفة/مكافأة/جزاء/إجازة ساعية/إجازة يومية)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/transaction_manager_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/model/manager/transaction_models.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class CreateTransactionPage extends StatefulWidget {
  final String? initialType;
  const CreateTransactionPage({super.key, this.initialType});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final TransactionManagerController ctrl = Get.find<TransactionManagerController>();
  final _formKey = GlobalKey<FormState>();

  late String type;
  TxEmployeeOption? employee;
  bool submitted = false;

  // مالية
  final amountCtrl = TextEditingController();
  final docCtrl = TextEditingController();
  DateTime date = DateTime.now();

  // إجازة ساعية
  DateTime? leaveDate;
  int? hours;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool endTimeManual = false;

  // إجازة يومية
  DateTime? startDate;
  final daysCtrl = TextEditingController();

  // مشترك
  final reasonCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  bool get isMoney => TxConst.moneyTypes.contains(type);
  bool get isLeave => TxConst.leaveTypes.contains(type);

  @override
  void initState() {
    super.initState();
    type = TxConst.types.any((t) => t.value == widget.initialType)
        ? widget.initialType!
        : 'advance';
    ctrl.loadEmployees();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    docCtrl.dispose();
    daysCtrl.dispose();
    reasonCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  // ============================ حسابات ============================

  int? get days => int.tryParse(daysCtrl.text.trim());

  DateTime? get endDate {
    final d = days;
    if (startDate == null || d == null || d < 1) return null;
    return DateTime(startDate!.year, startDate!.month, startDate!.day + d - 1);
  }

  void _autoEndTime() {
    if (endTimeManual || startTime == null || hours == null) return;
    final total = startTime!.hour * 60 + startTime!.minute + hours! * 60;
    if (total >= 24 * 60) {
      endTime = null;
      return;
    }
    endTime = TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  String _hm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ============================ منتقيات ============================

  Future<DateTime?> _pickDate(DateTime? initial) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 2, 12, 31),
      helpText: 'اختر التاريخ',
      cancelText: 'إلغاء',
      confirmText: 'تم',
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: MColors.primary),
          ),
          child: child!,
        ),
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay? initial) {
    return showTimePicker(
      context: context,
      initialTime: initial ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'اختر الوقت',
      cancelText: 'إلغاء',
      confirmText: 'تم',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    );
  }

  Future<void> _pickEmployee() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<TxEmployeeOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmployeePickerSheet(selectedId: employee?.id),
    );
    if (picked != null) setState(() => employee = picked);
  }

  // ============================ الإرسال ============================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => submitted = true);
    final formOk = _formKey.currentState?.validate() ?? false;
    String? pickError;
    if (employee == null) {
      pickError = 'يرجى اختيار الموظف';
    } else if (type == 'hourly_leave') {
      if (leaveDate == null) {
        pickError = 'يرجى اختيار تاريخ الإجازة';
      } else if (hours == null) {
        pickError = 'يرجى اختيار عدد الساعات';
      } else if (_timeRangeError() != null) {
        pickError = _timeRangeError();
      }
    } else if (type == 'daily_leave' && startDate == null) {
      pickError = 'يرجى اختيار تاريخ البداية';
    }
    if (!formOk || pickError != null) {
      if (pickError != null) MDialogs.error(pickError);
      return;
    }

    final notes = notesCtrl.text.trim();
    final body = <String, dynamic>{
      'transaction_type': type,
      'employee_id': employee!.id,
      'notes': notes.isEmpty ? null : notes,
    };
    if (isMoney) {
      final doc = docCtrl.text.trim();
      body.addAll({
        'amount': double.parse(amountCtrl.text.trim()),
        'document_number': doc.isEmpty ? '0' : doc,
        'date': MFormat.date(date),
      });
    } else if (type == 'hourly_leave') {
      body.addAll({
        'leave_date': MFormat.date(leaveDate!),
        'hours': hours,
        if (startTime != null) 'start_time': _hm(startTime!),
        if (endTime != null) 'end_time': _hm(endTime!),
        'reason': reasonCtrl.text.trim(),
      });
    } else if (type == 'daily_leave') {
      body.addAll({
        'start_date': MFormat.date(startDate!),
        'days': days,
        'end_date': MFormat.date(endDate!),
        'reason': reasonCtrl.text.trim(),
      });
    }

    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    final res = await ctrl.create(body);
    if (!mounted) return;
    if (res.ok) {
      // Navigator بدل Get.back حتى لا يُغلق الإشعار بدلاً من الصفحة
      Navigator.of(context).pop(true);
      MDialogs.success(res.message ?? 'تم إنشاء المعاملة بنجاح');
    } else {
      MDialogs.error(res.error!);
    }
  }

  String? _timeRangeError() {
    if (startTime == null || endTime == null) return null;
    final s = startTime!.hour * 60 + startTime!.minute;
    final e = endTime!.hour * 60 + endTime!.minute;
    if (e <= s) return 'وقت النهاية يجب أن يكون بعد وقت البداية';
    return null;
  }

  // ============================ الواجهة ============================

  @override
  Widget build(BuildContext context) {
    return ManagerScaffold(
      title: 'إنشاء معاملة',
      body: Form(
        key: _formKey,
        autovalidateMode: submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card(
                    title: 'نوع المعاملة',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: TxConst.types.map(_typeOption).toList(),
                      ),
                    ],
                  ),
                  _card(
                    title: 'الموظف',
                    children: [
                      _PickerField(
                        label: 'الموظف *',
                        icon: Icons.person_search_rounded,
                        value: employee == null
                            ? null
                            : employee!.fingerprintId == null
                                ? employee!.fullName
                                : '${employee!.fullName}  •  ${employee!.fingerprintId}',
                        placeholder: 'اختر الموظف',
                        error: submitted && employee == null ? 'يرجى اختيار الموظف' : null,
                        onTap: _pickEmployee,
                      ),
                    ],
                  ),
                  _card(title: 'تفاصيل ${TxConst.type(type).label}', children: _typeFields()),
                  _card(
                    title: 'ملاحظات',
                    children: [
                      TextFormField(
                        controller: notesCtrl,
                        maxLines: 3,
                        decoration: mInputDecoration('ملاحظات (اختياري)', icon: Icons.notes_rounded),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: MColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'ستُرسل المعاملة لموافقة جميع المعنيين (رؤساء ونواب الفرع/القسم ومدير النظام).',
                          style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            GetBuilder<TransactionManagerController>(
              builder: (c) => Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: c.busy ? null : _submit,
                        icon: c.busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          c.busy ? 'جارٍ الإرسال...' : 'إرسال المعاملة',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: mCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MSectionTitle(title),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _typeOption(TxType t) {
    final selected = t.value == type;
    return InkWell(
      onTap: () => setState(() => type = t.value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? t.color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? t.color : MColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(t.icon, size: 18, color: t.color),
            const SizedBox(width: 6),
            Text(
              t.label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? t.color : MColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _typeFields() {
    const gap = SizedBox(height: 12);
    if (isMoney) {
      return [
        TextFormField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: mInputDecoration('المبلغ (ج.م) *', icon: Icons.payments_outlined),
          validator: (v) {
            final n = double.tryParse((v ?? '').trim());
            if (n == null) return 'يرجى إدخال المبلغ';
            if (n <= 0) return 'يجب أن يكون المبلغ أكبر من صفر';
            return null;
          },
        ),
        gap,
        TextFormField(
          controller: docCtrl,
          decoration: mInputDecoration('رقم المستند',
              hint: 'اختياري', icon: Icons.numbers_rounded),
        ),
        gap,
        _PickerField(
          label: 'التاريخ',
          icon: Icons.calendar_month_rounded,
          value: MFormat.date(date),
          onTap: () async {
            final d = await _pickDate(date);
            if (d != null) setState(() => date = d);
          },
        ),
      ];
    }

    if (type == 'hourly_leave') {
      return [
        _PickerField(
          label: 'تاريخ الإجازة *',
          icon: Icons.calendar_month_rounded,
          value: leaveDate == null ? null : MFormat.date(leaveDate!),
          placeholder: 'اختر التاريخ',
          error: submitted && leaveDate == null ? 'يرجى اختيار تاريخ الإجازة' : null,
          onTap: () async {
            final d = await _pickDate(leaveDate);
            if (d != null) setState(() => leaveDate = d);
          },
        ),
        gap,
        const Text('عدد الساعات *',
            style: TextStyle(fontSize: 13, color: MColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(8, (i) {
            final h = i + 1;
            final selected = hours == h;
            return InkWell(
              onTap: () => setState(() {
                hours = h;
                _autoEndTime();
              }),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? MColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? MColors.primary : MColors.border),
                ),
                child: Text(
                  '$h',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : MColors.text,
                  ),
                ),
              ),
            );
          }),
        ),
        if (submitted && hours == null)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('يرجى اختيار عدد الساعات',
                style: TextStyle(fontSize: 12, color: MColors.danger)),
          ),
        gap,
        Row(
          children: [
            Expanded(
              child: _PickerField(
                label: 'من الساعة',
                icon: Icons.login_rounded,
                value: startTime == null ? null : _hm(startTime!),
                placeholder: '--:--',
                showArrow: false,
                onTap: () async {
                  final t = await _pickTime(startTime);
                  if (t != null) {
                    setState(() {
                      startTime = t;
                      _autoEndTime();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PickerField(
                label: 'إلى الساعة',
                icon: Icons.logout_rounded,
                value: endTime == null ? null : _hm(endTime!),
                placeholder: '--:--',
                showArrow: false,
                error: submitted ? _timeRangeError() : null,
                onTap: () async {
                  final t = await _pickTime(endTime ?? startTime);
                  if (t != null) {
                    setState(() {
                      endTime = t;
                      endTimeManual = true;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        gap,
        _reasonField(),
      ];
    }

    // إجازة يومية
    final end = endDate;
    return [
      _PickerField(
        label: 'تاريخ البداية *',
        icon: Icons.calendar_month_rounded,
        value: startDate == null ? null : MFormat.date(startDate!),
        placeholder: 'اختر التاريخ',
        error: submitted && startDate == null ? 'يرجى اختيار تاريخ البداية' : null,
        onTap: () async {
          final d = await _pickDate(startDate);
          if (d != null) setState(() => startDate = d);
        },
      ),
      gap,
      TextFormField(
        controller: daysCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: mInputDecoration('عدد الأيام *', icon: Icons.event_repeat_rounded),
        onChanged: (_) => setState(() {}),
        validator: (v) {
          final n = int.tryParse((v ?? '').trim());
          if (n == null) return 'يرجى إدخال عدد الأيام';
          if (n < 1) return 'يجب أن يكون عدد الأيام 1 على الأقل';
          if (n > 365) return 'عدد الأيام كبير جداً';
          return null;
        },
      ),
      gap,
      _PickerField(
        label: 'تاريخ النهاية (محسوب)',
        icon: Icons.event_busy_rounded,
        value: end == null ? null : MFormat.date(end),
        placeholder: 'يُحسب تلقائياً',
        readOnly: true,
      ),
      gap,
      _reasonField(),
    ];
  }

  Widget _reasonField() {
    return TextFormField(
      controller: reasonCtrl,
      maxLines: 2,
      decoration: mInputDecoration('سبب الإجازة *', icon: Icons.edit_note_rounded),
      validator: (v) => (v ?? '').trim().isEmpty ? 'سبب الإجازة مطلوب' : null,
    );
  }
}

/// حقل اختيار (تاريخ/وقت/موظف) بشكل حقل إدخال
class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final String? placeholder;
  final String? error;
  final VoidCallback? onTap;
  final bool readOnly;
  // إخفاء سهم القائمة في الحقول الضيقة (حقول الوقت) حتى لا يُقص النص
  final bool showArrow;

  const _PickerField({
    required this.label,
    required this.icon,
    this.value,
    this.placeholder,
    this.error,
    this.onTap,
    this.readOnly = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final field = InputDecorator(
      isEmpty: false,
      decoration: mInputDecoration(label, icon: icon).copyWith(
        errorText: error,
        fillColor: readOnly ? MColors.background : Colors.white,
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline_rounded, size: 18, color: MColors.textLight)
            : showArrow
                ? const Icon(Icons.keyboard_arrow_down_rounded, color: MColors.textMuted)
                : null,
      ),
      child: Text(
        value ?? placeholder ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          color: value == null ? MColors.textLight : MColors.textDark,
        ),
      ),
    );
    if (readOnly || onTap == null) return field;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: field);
  }
}

/// نافذة سفلية لاختيار الموظف مع بحث
class _EmployeePickerSheet extends StatefulWidget {
  final int? selectedId;
  const _EmployeePickerSheet({this.selectedId});

  @override
  State<_EmployeePickerSheet> createState() => _EmployeePickerSheetState();
}

class _EmployeePickerSheetState extends State<_EmployeePickerSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scroll) => Container(
          decoration: const BoxDecoration(
            color: MColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  children: [
                    const MSectionTitle('اختيار الموظف'),
                    const SizedBox(height: 12),
                    MSearchField(
                      hint: 'ابحث بالاسم أو رقم البصمة',
                      onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GetBuilder<TransactionManagerController>(
                  builder: (c) {
                    if (c.employeesState == Staterequest.loading ||
                        c.employeesState == Staterequest.none) {
                      return const MLoading();
                    }
                    if (c.employeesState == Staterequest.failure) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: MMessage.error(c.employeesError,
                            onRetry: () => c.loadEmployees(force: true)),
                      );
                    }
                    final list = query.isEmpty
                        ? c.employees
                        : c.employees
                            .where((e) =>
                                e.fullName.toLowerCase().contains(query) ||
                                (e.fingerprintId ?? '').toLowerCase().contains(query))
                            .toList();
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: MMessage.empty(
                          c.employees.isEmpty ? 'لا يوجد موظفون ضمن نطاقك' : 'لا توجد نتائج',
                          icon: Icons.person_off_outlined,
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final e = list[i];
                        final selected = e.id == widget.selectedId;
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: selected ? MColors.primary : Colors.transparent),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: MColors.primary.withValues(alpha: 0.12),
                              child: Text(
                                e.fullName.isNotEmpty ? e.fullName.characters.first : '?',
                                style: const TextStyle(
                                    color: MColors.primary, fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(e.fullName,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: e.fingerprintId == null
                                ? null
                                : Text('رقم البصمة: ${e.fingerprintId}'),
                            trailing: selected
                                ? const Icon(Icons.check_circle_rounded, color: MColors.primary)
                                : null,
                            onTap: () => Navigator.of(context).pop(e),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
