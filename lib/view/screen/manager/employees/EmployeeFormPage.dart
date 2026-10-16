// EmployeeFormPage.dart
// نموذج إضافة موظف جديد أو تعديل بيانات موظف
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/employee_form_controller.dart';
import 'package:human_resources/controller/manager/employee_manager_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/model/manager/employee_models.dart';
import 'package:human_resources/view/screen/manager/employees/employee_widgets.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class EmployeeFormPage extends StatefulWidget {
  /// null = إضافة موظف جديد
  final ManagedEmployee? employee;
  const EmployeeFormPage({super.key, this.employee});

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  late final EmployeeFormController c;

  @override
  void initState() {
    super.initState();
    EmployeeManagerController.to;
    c = EmployeeFormController(editing: widget.employee);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final ok = await c.submit();
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ManagerScaffold(
      title: c.isEdit ? 'تعديل بيانات الموظف' : 'إضافة موظف',
      body: GetBuilder<EmployeeFormController>(
        init: c,
        global: false,
        builder: (c) {
          if (c.lookupsStatus == Staterequest.loading ||
              c.lookupsStatus == Staterequest.none) {
            return const MLoading();
          }
          if (c.lookupsStatus == Staterequest.failure) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: MMessage.error(
                c.lookupsError ?? 'تعذر تحميل البيانات المساعدة',
                onRetry: c.loadLookups,
              ),
            );
          }
          return Form(
            key: c.formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (!c.isEdit) _photoSection(c),
                _basicSection(c),
                _contactSection(c),
                if (c.isPermanent) _financialSection(c),
                if (c.isPermanent && !c.isEdit) _componentsSection(c),
                if (c.isPermanent) _personalSection(c),
                if (c.isPermanent && !c.isEdit) _extraSection(c),
                const SizedBox(height: 8),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: MColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: c.submitting ? null : _save,
                    icon: c.submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      c.submitting
                          ? 'جاري الحفظ...'
                          : (c.isEdit ? 'حفظ التعديلات' : 'إضافة الموظف'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------- أدوات

  static const _gap = SizedBox(height: 12);

  Widget _text(
    TextEditingController ctrl,
    String label, {
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    bool numeric = false,
    bool decimal = true,
    int maxLines = 1,
    String? hint,
    String? suffix,
    ValueChanged<String>? onChanged,
    TextDirection? textDirection,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: numeric
          ? TextInputType.numberWithOptions(decimal: decimal)
          : keyboard,
      inputFormatters: numeric ? [LatinDigitsFormatter(allowDecimal: decimal)] : null,
      textDirection: textDirection,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: mInputDecoration(label, icon: icon, hint: hint).copyWith(suffixText: suffix),
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _info(String text, {Color color = MColors.info, IconData icon = Icons.info_outline}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: color))),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- الصورة

  Widget _photoSection(EmployeeFormController c) {
    final path = c.photoPath;
    return EmployeeSectionCard(
      title: 'صورة الموظف',
      icon: Icons.photo_camera_rounded,
      children: [
        Row(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MColors.primary.withValues(alpha: 0.08),
                border: Border.all(color: MColors.primary.withValues(alpha: 0.3), width: 2),
              ),
              child: ClipOval(
                child: path == null
                    ? const Icon(Icons.person_rounded, size: 44, color: MColors.primary)
                    : Image.file(File(path), fit: BoxFit.cover, width: 84, height: 84),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MColors.primary,
                      side: const BorderSide(color: MColors.primary),
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: c.pickPhoto,
                    icon: const Icon(Icons.image_rounded, size: 18),
                    label: Text(path == null ? 'اختيار صورة' : 'تغيير الصورة'),
                  ),
                  if (path != null)
                    TextButton.icon(
                      onPressed: c.removePhoto,
                      icon: const Icon(Icons.close_rounded, size: 18, color: MColors.danger),
                      label: const Text('إزالة', style: TextStyle(color: MColors.danger)),
                    ),
                  const Text('PNG أو JPG (اختياري)',
                      style: TextStyle(fontSize: 11, color: MColors.textLight)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ----------------------------------------------------- البيانات الأساسية

  Widget _basicSection(EmployeeFormController c) {
    final wsItems = c.workSystemOptions
        .map((w) => MDropdownItem<String>(w, EmployeeLabels.workSystem(w)))
        .toList();
    return EmployeeSectionCard(
      title: 'البيانات الأساسية',
      icon: Icons.badge_rounded,
      children: [
        _text(c.fingerprint, 'رقم البصمة', icon: Icons.fingerprint_rounded),
        _gap,
        _text(c.fullName, 'الاسم الكامل *',
            icon: Icons.person_rounded, validator: c.validateFullName),
        _gap,
        const Text('نوع الموظف *',
            style: TextStyle(fontSize: 13, color: MColors.textMuted)),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'permanent',
                  label: Text('موظف دائم'),
                  icon: Icon(Icons.verified_rounded)),
              ButtonSegment(
                  value: 'temporary',
                  label: Text('موظف مؤقت'),
                  icon: Icon(Icons.timelapse_rounded)),
            ],
            selected: {c.employeeType},
            // لا يمكن تغيير نوع الموظف عند التعديل (الباك لا يحدّث المهنة)
            onSelectionChanged:
                c.isEdit ? null : (s) => c.setEmployeeType(s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: MColors.primary.withValues(alpha: 0.12),
              selectedForegroundColor: MColors.primary,
            ),
          ),
        ),
        _gap,
        if (c.isPermanent)
          MDropdownFormField<int>(
            label: 'المسمى الوظيفي *',
            icon: Icons.work_rounded,
            value: c.positionId,
            hint: c.jobTitles.isEmpty ? 'لا توجد مسميات وظيفية' : 'اختر المسمى الوظيفي',
            items: c.jobTitles.map((t) => MDropdownItem(t.id, t.name)).toList(),
            onChanged: c.setPosition,
            validator: c.validatePosition,
          ),
        if (c.isTemporary && !c.isEdit)
          MDropdownFormField<int>(
            label: 'المهنة *',
            icon: Icons.construction_rounded,
            value: c.professionId,
            hint: c.professions.isEmpty ? 'لا توجد مهن' : 'اختر المهنة',
            items: c.professions.map((p) => MDropdownItem(p.id, p.name)).toList(),
            onChanged: c.setProfession,
            validator: c.validateProfession,
          ),
        if (c.isTemporary && c.isEdit)
          InputDecorator(
            decoration: mInputDecoration('المهنة', icon: Icons.construction_rounded).copyWith(
              helperText: 'لا يمكن تعديل المهنة من هذه الشاشة',
              enabled: false,
            ),
            child: Text(c.editing?.profession ?? '-'),
          ),
        _gap,
        MDropdownFormField<String>(
          label: 'نظام العمل *',
          icon: Icons.schedule_rounded,
          value: c.workSystem,
          loading: c.systemsLoading,
          hint: c.isPermanent && c.positionId == null
              ? 'اختر المسمى الوظيفي أولاً'
              : 'اختر نظام العمل',
          items: wsItems,
          onChanged: c.setWorkSystem,
          validator: c.validateWorkSystem,
        ),
        if (c.systemsError != null) ...[
          const SizedBox(height: 6),
          _info(c.systemsError!, color: MColors.warning, icon: Icons.warning_amber_rounded),
        ],
        if (c.workSystem == 'shift') ...[
          _gap,
          MDropdownFormField<int>(
            label: 'الوردية *',
            icon: Icons.access_time_rounded,
            value: c.shiftId,
            loading: c.shiftsLoading,
            hint: c.shifts.isEmpty && !c.shiftsLoading ? 'لا توجد ورديات' : 'اختر الوردية',
            items: c.shifts.map((s) => MDropdownItem(s.id, s.name)).toList(),
            onChanged: c.setShift,
            validator: c.validateShift,
          ),
          if (c.shiftsError != null) ...[
            const SizedBox(height: 6),
            _info(c.shiftsError!, color: MColors.danger, icon: Icons.error_outline),
          ],
        ],
        if (!c.isEdit) ...[
          _gap,
          _certificatePicker(c),
        ],
      ],
    );
  }

  Widget _certificatePicker(EmployeeFormController c) {
    final name = c.certificateName;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: c.pickCertificate,
      child: InputDecorator(
        isEmpty: name == null,
        decoration: mInputDecoration('الشهادة (اختياري)', icon: Icons.school_rounded).copyWith(
          suffixIcon: name == null
              ? const Icon(Icons.attach_file_rounded)
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: c.removeCertificate,
                ),
        ),
        child: Text(
          name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: MColors.success, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ------------------------------------------------------ الهوية والاتصال

  Widget _contactSection(EmployeeFormController c) {
    return EmployeeSectionCard(
      title: 'الهوية والاتصال',
      icon: Icons.contact_phone_rounded,
      children: [
        _text(
          c.nationalId,
          c.isEdit ? 'الرقم القومي' : 'الرقم القومي *',
          icon: Icons.credit_card_rounded,
          keyboard: TextInputType.number,
          validator: c.isEdit ? null : (v) => c.validateRequired(v, 'الرقم القومي'),
        ),
        if (!c.isEdit) ...[
          _gap,
          _text(c.idNumber, 'رقم الهوية الإضافي', icon: Icons.perm_identity_rounded),
        ],
        _gap,
        _text(
          c.phone1,
          c.isEdit ? 'رقم الجوال' : 'رقم الجوال الأساسي *',
          icon: Icons.phone_android_rounded,
          keyboard: TextInputType.phone,
          textDirection: TextDirection.ltr,
          validator: c.isEdit ? null : (v) => c.validateRequired(v, 'رقم الجوال'),
        ),
        if (!c.isEdit) ...[
          _gap,
          _text(c.phone2, 'رقم الجوال الإضافي',
              icon: Icons.phone_rounded,
              keyboard: TextInputType.phone,
              textDirection: TextDirection.ltr),
          _gap,
          _text(c.phone3, 'رقم الطوارئ',
              icon: Icons.contact_emergency_rounded,
              keyboard: TextInputType.phone,
              textDirection: TextDirection.ltr),
        ],
        _gap,
        _text(c.residence, 'العنوان', icon: Icons.home_rounded),
      ],
    );
  }

  // --------------------------------------------------------- البيانات المالية

  Widget _financialSection(EmployeeFormController c) {
    return EmployeeSectionCard(
      title: 'البيانات المالية',
      icon: Icons.account_balance_wallet_rounded,
      children: [
        _text(c.salary, 'الراتب الأساسي',
            icon: Icons.payments_rounded,
            numeric: true,
            suffix: 'ج.م',
            onChanged: c.onSalaryChanged,
            validator: (v) => c.validateNumber(v, min: 0)),
        _gap,
        _text(c.allowances, 'البدلات',
            icon: Icons.add_card_rounded,
            numeric: true,
            suffix: 'ج.م',
            validator: (v) => c.validateNumber(v, min: 0)),
        _gap,
        _text(c.advance, 'نسبة السلفة من الراتب المستحق',
            icon: Icons.percent_rounded,
            numeric: true,
            suffix: '%',
            hint: 'من 1 إلى 100',
            validator: (v) => c.validateNumber(v, min: 1, max: 100)),
        if (!c.isEdit) ...[
          _gap,
          _text(c.insurance, 'قيمة التأمينات',
              icon: Icons.shield_rounded,
              numeric: true,
              suffix: 'ج.م',
              onChanged: c.onInsuranceChanged,
              validator: (v) => c.validateNumber(v, min: 0)),
          if (c.hasInsurance) ...[
            _gap,
            MDateFormField(
              label: 'تاريخ بداية التأمينات *',
              value: c.insuranceStart,
              onChanged: (d) => c.setDate('insurance_start', d),
              validator: c.validateInsuranceStart,
            ),
            _gap,
            MDateFormField(
              label: 'تاريخ نهاية التأمينات *',
              value: c.insuranceEnd,
              onChanged: (d) => c.setDate('insurance_end', d),
              validator: c.validateInsuranceEnd,
            ),
          ],
        ],
        _gap,
        _text(c.overtime, 'معامل الإضافي',
            icon: Icons.more_time_rounded,
            numeric: true,
            hint: 'من 1 إلى 3 (افتراضي 1.5)',
            validator: (v) => c.validateNumber(v, min: 1, max: 3)),
        _gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _text(c.daily, 'سعر اليوم',
                  numeric: true,
                  suffix: 'ج.م',
                  onChanged: c.onDailyChanged,
                  validator: (v) => c.validateNumber(v, min: 0)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _text(c.hourly, 'سعر الساعة',
                  numeric: true,
                  suffix: 'ج.م',
                  onChanged: c.onHourlyChanged,
                  validator: (v) => c.validateNumber(v, min: 0)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _info('يُحسب سعر اليوم تلقائياً (الراتب ÷ 30) وسعر الساعة (سعر اليوم ÷ 8) إذا تُركا فارغين.'),
      ],
    );
  }

  // ---------------------------------------------------- مكونات الراتب المبدئية

  void _draftDialog({SalaryComponentDraft? existing, String type = 'addition'}) {
    showSalaryComponentDialog(
      context,
      componentType: existing?.componentType ?? type,
      name: existing?.name,
      amount: existing?.amount,
      notes: existing?.notes,
      isEdit: existing != null,
      onSubmit: (name, amount, t, notes) async {
        final d = SalaryComponentDraft(
            name: name, amount: amount, componentType: t, notes: notes);
        c.saveDraft(d, index: existing == null ? null : c.drafts.indexOf(existing));
        return true;
      },
    );
  }

  Widget _componentsSection(EmployeeFormController c) {
    final additions = c.drafts.where((d) => d.isAddition).toList();
    final deductions = c.drafts.where((d) => !d.isAddition).toList();

    Widget group(String title, String type, List<SalaryComponentDraft> items, Color color) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(fontWeight: FontWeight.w700, color: color)),
              ),
              TextButton.icon(
                onPressed: () => _draftDialog(type: type),
                icon: Icon(Icons.add_rounded, size: 18, color: color),
                label: Text(type == 'addition' ? 'إضافة بدل' : 'إضافة خصم',
                    style: TextStyle(color: color)),
              ),
            ],
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                type == 'addition' ? 'لا توجد إضافات' : 'لا توجد خصومات',
                style: const TextStyle(fontSize: 12, color: MColors.textLight),
              ),
            ),
          for (final d in items)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (d.notes != null)
                          Text(d.notes!,
                              style: const TextStyle(fontSize: 11, color: MColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(MFormat.money(d.amount),
                      style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18, color: MColors.info),
                    onPressed: () => _draftDialog(existing: d),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: MColors.danger),
                    onPressed: () => c.removeDraft(d),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return EmployeeSectionCard(
      title: 'المكونات المالية الإضافية',
      icon: Icons.playlist_add_rounded,
      children: [
        group('الإضافات والبدلات', 'addition', additions, MColors.success),
        const Divider(color: MColors.border),
        group('الخصومات', 'deduction', deductions, MColors.danger),
      ],
    );
  }

  // --------------------------------------------------------- البيانات الشخصية

  Widget _personalSection(EmployeeFormController c) {
    return EmployeeSectionCard(
      title: 'البيانات الشخصية والتواريخ',
      icon: Icons.event_rounded,
      children: [
        MDateFormField(
          label: 'تاريخ الميلاد',
          value: c.birthDate,
          onChanged: (d) => c.setDate('birth', d),
        ),
        _gap,
        _text(c.birthPlace, 'مكان الميلاد', icon: Icons.place_rounded),
        if (!c.isEdit) ...[
          _gap,
          MDateFormField(
            label: 'تاريخ الالتحاق',
            value: c.joiningDate,
            onChanged: (d) => c.setDate('joining', d),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------ معلومات إضافية

  Widget _extraSection(EmployeeFormController c) {
    return EmployeeSectionCard(
      title: 'معلومات إضافية',
      icon: Icons.info_rounded,
      children: [
        _text(c.agreement, 'نوع العقد', icon: Icons.handshake_rounded),
        _gap,
        _text(c.notes, 'ملاحظات', icon: Icons.notes_rounded, maxLines: 3),
      ],
    );
  }
}
