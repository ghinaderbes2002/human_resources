// employee_widgets.dart
// عناصر مشتركة لشاشات إدارة الموظفين: الصورة الرمزية، حقول التاريخ والقوائم، والنوافذ.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_resources/controller/manager/employee_manager_controller.dart';
import 'package:human_resources/model/manager/employee_models.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

// ----------------------------------------------------------------- الصورة

class EmployeeAvatar extends StatelessWidget {
  final int? photoId;
  final String initials;
  final double size;
  final bool isActive;

  const EmployeeAvatar({
    super.key,
    required this.photoId,
    required this.initials,
    this.size = 52,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final id = photoId;
    if (id == null) return _placeholder();
    final ctrl = EmployeeManagerController.to;
    final cached = ctrl.photoCache[id];
    if (cached != null) return _image(cached);
    return FutureBuilder<Uint8List?>(
      future: ctrl.photo(id),
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes != null) return _image(bytes);
        if (snap.connectionState == ConnectionState.waiting) {
          return _placeholder(loading: true);
        }
        return _placeholder();
      },
    );
  }

  Widget _image(Uint8List bytes) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: (isActive ? MColors.primary : MColors.textLight).withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder({bool loading = false}) {
    final color = isActive ? MColors.primary : MColors.textLight;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.08)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: loading
          ? SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.34,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
    );
  }
}

// ------------------------------------------------------------ مدخلات الأرقام

/// يحوّل الأرقام العربية/الفارسية إلى لاتينية ويسمح بالأرقام والنقطة فقط
class LatinDigitsFormatter extends TextInputFormatter {
  final bool allowDecimal;
  const LatinDigitsFormatter({this.allowDecimal = true});

  static const _arabic = '٠١٢٣٤٥٦٧٨٩';
  static const _persian = '۰۱۲۳۴۵۶۷۸۹';

  static String normalize(String s) {
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final a = _arabic.indexOf(ch);
      final p = _persian.indexOf(ch);
      if (a >= 0) {
        b.write(a);
      } else if (p >= 0) {
        b.write(p);
      } else if (ch == '٫' || ch == ',') {
        b.write('.');
      } else {
        b.write(ch);
      }
    }
    return b.toString();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = normalize(newValue.text);
    text = text.replaceAll(RegExp(allowDecimal ? r'[^0-9.]' : r'[^0-9]'), '');
    if (allowDecimal) {
      final firstDot = text.indexOf('.');
      if (firstDot >= 0) {
        text = text.substring(0, firstDot + 1) +
            text.substring(firstDot + 1).replaceAll('.', '');
      }
    }
    if (text == newValue.text) return newValue;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ------------------------------------------------------------- حقل تاريخ

Future<DateTime?> pickEmployeeDate(BuildContext context, String? current) {
  final now = DateTime.now();
  var initial = DateTime.tryParse(current ?? '') ?? now;
  final first = DateTime(1940);
  final last = DateTime(now.year + 30);
  if (initial.isBefore(first)) initial = first;
  if (initial.isAfter(last)) initial = last;
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first,
    lastDate: last,
    builder: (ctx, child) => Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: MColors.primary),
        ),
        child: child!,
      ),
    ),
  );
}

/// حقل تاريخ متكامل مع التحقق في النموذج (القيمة تُقرأ من [value])
class MDateFormField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<DateTime?> onChanged;
  final String? Function()? validator;
  final bool clearable;

  const MDateFormField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.validator,
    this.clearable = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) => validator?.call(),
      builder: (field) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final d = await pickEmployeeDate(context, value);
          if (d != null) {
            onChanged(d);
            field.didChange(MFormat.date(d));
          }
        },
        child: InputDecorator(
          isEmpty: value == null,
          decoration: mInputDecoration(label, icon: Icons.calendar_today_rounded).copyWith(
            errorText: field.errorText,
            suffixIcon: clearable && value != null
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      onChanged(null);
                      field.didChange(null);
                    },
                  )
                : null,
          ),
          child: Text(value ?? '', style: const TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------- قائمة منسدلة

class MDropdownItem<T> {
  final T value;
  final String label;
  const MDropdownItem(this.value, this.label);
}

/// قائمة منسدلة مع التحقق في النموذج (القيمة تُقرأ من [value])
class MDropdownFormField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<MDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final IconData? icon;
  final String? hint;
  final bool loading;

  const MDropdownFormField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon,
    this.hint,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && items.any((i) => i.value == value);
    return FormField<T>(
      validator: (_) => validator?.call(value),
      builder: (field) => InputDecorator(
        isEmpty: !hasValue,
        decoration: mInputDecoration(label, icon: icon).copyWith(
          errorText: field.errorText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          suffixIcon: loading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: MColors.primary),
                  ),
                )
              : null,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: hasValue ? value : null,
            isExpanded: true,
            isDense: true,
            hint: hint == null
                ? null
                : Text(hint!, style: const TextStyle(color: MColors.textLight, fontSize: 14)),
            borderRadius: BorderRadius.circular(12),
            items: items
                .map((i) => DropdownMenuItem<T>(
                      value: i.value,
                      child: Text(i.label, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: onChanged == null || loading
                ? null
                : (v) {
                    onChanged!(v);
                    field.didChange(v);
                  },
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ صف معلومات

class EmployeeInfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final Color? valueColor;

  const EmployeeInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final v = (value == null || value!.trim().isEmpty) ? '-' : value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: MColors.textLight),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: MColors.textMuted)),
          ),
          Expanded(
            child: SelectableText(
              v,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? MColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة قسم (عنوان + محتوى)
class EmployeeSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  const EmployeeSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: mCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: MColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: MColors.textDark)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- النوافذ

Widget _dialogShell({
  required String title,
  required Widget content,
  required bool saving,
  required VoidCallback onCancel,
  required VoidCallback onSave,
  String saveText = 'حفظ',
}) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(child: content),
      actions: [
        TextButton(
          onPressed: saving ? null : onCancel,
          child: const Text('إلغاء', style: TextStyle(color: MColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: saving ? null : onSave,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(saveText),
        ),
      ],
    ),
  );
}

typedef SalaryComponentSubmit = Future<bool> Function(
    String name, double amount, String componentType, String? notes);

/// نافذة إضافة/تعديل إضافة أو خصم. تُغلق فقط عند نجاح [onSubmit].
Future<void> showSalaryComponentDialog(
  BuildContext context, {
  required String componentType,
  String? name,
  double? amount,
  String? notes,
  bool isEdit = false,
  required SalaryComponentSubmit onSubmit,
}) {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController(text: name ?? '');
  final amountCtrl = TextEditingController(
      text: amount == null ? '' : (amount == amount.roundToDouble() ? amount.toStringAsFixed(0) : '$amount'));
  final notesCtrl = TextEditingController(text: notes ?? '');
  var type = componentType;
  var saving = false;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => _dialogShell(
        title: isEdit
            ? (type == 'addition' ? 'تعديل إضافة' : 'تعديل خصم')
            : (type == 'addition' ? 'إضافة بدل / إضافة' : 'إضافة خصم'),
        saving: saving,
        onCancel: () => Navigator.of(ctx).pop(),
        onSave: () async {
          if (!(formKey.currentState?.validate() ?? false)) return;
          setState(() => saving = true);
          final ok = await onSubmit(
            nameCtrl.text.trim(),
            double.parse(amountCtrl.text.trim()),
            type,
            notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          );
          if (!ctx.mounted) return;
          if (ok) {
            Navigator.of(ctx).pop();
          } else {
            setState(() => saving = false);
          }
        },
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'addition',
                        label: Text('إضافة'),
                        icon: Icon(Icons.add_circle_outline_rounded)),
                    ButtonSegment(
                        value: 'deduction',
                        label: Text('خصم'),
                        icon: Icon(Icons.remove_circle_outline_rounded)),
                  ],
                  selected: {type},
                  onSelectionChanged: saving ? null : (s) => setState(() => type = s.first),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: nameCtrl,
                decoration: mInputDecoration('الاسم *',
                    hint: type == 'addition' ? 'مثال: بدل سكن' : 'مثال: تأمين صحي'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: const [LatinDigitsFormatter()],
                decoration: mInputDecoration('القيمة (ج.م) *'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  if (n == null) return 'القيمة مطلوبة';
                  if (n < 0) return 'القيمة يجب أن تكون 0 أو أكثر';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: mInputDecoration('ملاحظات'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

typedef CustomDateSubmit = Future<bool> Function(String label, String date, String? notes);

Future<void> showCustomDateDialog(
  BuildContext context, {
  EmployeeCustomDate? existing,
  required CustomDateSubmit onSubmit,
}) {
  final formKey = GlobalKey<FormState>();
  final labelCtrl = TextEditingController(text: existing?.label ?? '');
  final notesCtrl = TextEditingController(text: existing?.notes ?? '');
  String? date = existing?.dateValue == null ? null : MFormat.dateOnly(existing!.dateValue);
  var saving = false;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => _dialogShell(
        title: existing == null ? 'إضافة تاريخ' : 'تعديل التاريخ',
        saving: saving,
        onCancel: () => Navigator.of(ctx).pop(),
        onSave: () async {
          if (!(formKey.currentState?.validate() ?? false)) return;
          setState(() => saving = true);
          final ok = await onSubmit(
            labelCtrl.text.trim(),
            date!,
            notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          );
          if (!ctx.mounted) return;
          if (ok) {
            Navigator.of(ctx).pop();
          } else {
            setState(() => saving = false);
          }
        },
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: labelCtrl,
                decoration: mInputDecoration('التسمية *', hint: 'مثال: تاريخ انتهاء العقد'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'التسمية مطلوبة' : null,
              ),
              const SizedBox(height: 12),
              MDateFormField(
                label: 'التاريخ *',
                value: date,
                clearable: false,
                onChanged: (d) => setState(() => date = d == null ? null : MFormat.date(d)),
                validator: () => date == null ? 'التاريخ مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: mInputDecoration('ملاحظات'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

typedef AttachmentSubmit = Future<bool> Function(String label, String? notes);

Future<void> showAttachmentUploadDialog(
  BuildContext context, {
  required String fileName,
  required AttachmentSubmit onSubmit,
}) {
  final formKey = GlobalKey<FormState>();
  final labelCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  var saving = false;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => _dialogShell(
        title: 'رفع مرفق',
        saveText: 'رفع',
        saving: saving,
        onCancel: () => Navigator.of(ctx).pop(),
        onSave: () async {
          if (!(formKey.currentState?.validate() ?? false)) return;
          setState(() => saving = true);
          final ok = await onSubmit(
            labelCtrl.text.trim(),
            notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          );
          if (!ctx.mounted) return;
          if (ok) {
            Navigator.of(ctx).pop();
          } else {
            setState(() => saving = false);
          }
        },
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_rounded, color: MColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(fileName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: labelCtrl,
                decoration: mInputDecoration('التسمية *', hint: 'مثال: صورة البطاقة'),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'التسمية مطلوبة';
                  if (s == EmployeeLabels.photoLabel) return 'هذه التسمية محجوزة';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: mInputDecoration('ملاحظات'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

IconData attachmentIcon(String ext) {
  switch (ext) {
    case 'pdf':
      return Icons.picture_as_pdf_rounded;
    case 'png':
    case 'jpg':
    case 'jpeg':
      return Icons.image_rounded;
    case 'doc':
    case 'docx':
    case 'txt':
      return Icons.description_rounded;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart_rounded;
    case 'zip':
    case 'rar':
      return Icons.folder_zip_rounded;
    default:
      return Icons.insert_drive_file_rounded;
  }
}

Color attachmentColor(String ext) {
  switch (ext) {
    case 'pdf':
      return MColors.danger;
    case 'png':
    case 'jpg':
    case 'jpeg':
      return MColors.info;
    case 'xls':
    case 'xlsx':
      return MColors.success;
    case 'zip':
    case 'rar':
      return MColors.warning;
    default:
      return MColors.textMuted;
  }
}
