// EmployeeDetailPage.dart
// تفاصيل الموظف: البيانات، الإضافات والخصومات، التواريخ الإضافية، المرفقات
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/employee_detail_controller.dart';
import 'package:human_resources/controller/manager/employee_manager_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/model/manager/employee_models.dart';
import 'package:human_resources/view/screen/manager/employees/EmployeeFormPage.dart';
import 'package:human_resources/view/screen/manager/employees/employee_widgets.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class EmployeeDetailPage extends StatefulWidget {
  final ManagedEmployee employee;
  const EmployeeDetailPage({super.key, required this.employee});

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  late final EmployeeDetailController c;

  @override
  void initState() {
    super.initState();
    // التأكد من وجود متحكم القائمة (مصدر بيانات الموظف والصور)
    EmployeeManagerController.to;
    c = EmployeeDetailController(widget.employee);
  }

  Future<void> _edit() async {
    await Get.to(() => EmployeeFormPage(employee: c.employee));
    c.update();
  }

  Future<void> _delete() async {
    final deleted = await c.deleteEmployee();
    if (deleted && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeDetailController>(
      init: c,
      global: false,
      builder: (c) => GetBuilder<EmployeeManagerController>(
        builder: (_) {
          final e = c.employee;
          return DefaultTabController(
            length: 4,
            child: ManagerScaffold(
              title: 'تفاصيل الموظف',
              actions: [
                IconButton(
                  tooltip: 'تعديل',
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: _edit,
                ),
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (v) {
                    if (v == 'refresh') {
                      c.refreshEmployee();
                      c.loadAll();
                    } else if (v == 'delete') {
                      _delete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'refresh',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.refresh_rounded),
                        title: Text('تحديث'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_rounded, color: MColors.danger),
                        title: Text('حذف الموظف', style: TextStyle(color: MColors.danger)),
                      ),
                    ),
                  ],
                ),
              ],
              body: NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  SliverToBoxAdapter(child: _Header(c: c, e: e)),
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
                    sliver: const SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _TabList(storageKey: 'basic', children: _basicInfo(e)),
                    _TabList(storageKey: 'components', children: _components(context)),
                    _TabList(storageKey: 'dates', children: _dates(context)),
                    _TabList(storageKey: 'attachments', children: _attachments(context)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------- البيانات الأساسية

  List<Widget> _basicInfo(ManagedEmployee e) {
    final shiftName = c.list.shiftName(e.shiftId);
    return [
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: MColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _edit,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('تعديل البيانات'),
          ),
        ),
      ),
      EmployeeSectionCard(
        title: 'البيانات الشخصية والاتصال',
        icon: Icons.person_rounded,
        children: [
          EmployeeInfoRow(label: 'الاسم الكامل', value: e.fullName, icon: Icons.badge_rounded),
          EmployeeInfoRow(
              label: 'رقم البصمة', value: e.fingerprintId, icon: Icons.fingerprint_rounded),
          EmployeeInfoRow(
              label: 'الرقم القومي', value: e.nationalId, icon: Icons.credit_card_rounded),
          EmployeeInfoRow(
              label: 'رقم الهوية الإضافي',
              value: e.idCardNumber,
              icon: Icons.perm_identity_rounded),
          EmployeeInfoRow(
              label: 'تاريخ الميلاد',
              value: e.dateOfBirth == null ? null : MFormat.dateOnly(e.dateOfBirth),
              icon: Icons.cake_rounded),
          EmployeeInfoRow(
              label: 'مكان الميلاد', value: e.placeOfBirth, icon: Icons.place_rounded),
          EmployeeInfoRow(label: 'العنوان', value: e.residence, icon: Icons.home_rounded),
          EmployeeInfoRow(
              label: 'الجوال الأساسي', value: e.mobile1, icon: Icons.phone_android_rounded),
          EmployeeInfoRow(
              label: 'الجوال الإضافي', value: e.mobile2, icon: Icons.phone_rounded),
          EmployeeInfoRow(
              label: 'رقم الطوارئ', value: e.mobile3, icon: Icons.contact_phone_rounded),
        ],
      ),
      EmployeeSectionCard(
        title: 'الوظيفة ونظام العمل',
        icon: Icons.work_rounded,
        children: [
          EmployeeInfoRow(label: 'نوع الموظف', value: e.typeLabel, icon: Icons.category_rounded),
          EmployeeInfoRow(
              label: e.isPermanent ? 'المسمى الوظيفي' : 'المهنة',
              value: e.jobLabel,
              icon: Icons.work_outline_rounded),
          EmployeeInfoRow(
              label: 'نظام العمل', value: e.workSystemLabel, icon: Icons.schedule_rounded),
          if (e.workSystem == 'shift')
            EmployeeInfoRow(
                label: 'الوردية',
                value: shiftName ?? (e.shiftId == null ? null : '#${e.shiftId}'),
                icon: Icons.access_time_rounded),
          EmployeeInfoRow(label: 'الفرع', value: e.branchName, icon: Icons.apartment_rounded),
          EmployeeInfoRow(
              label: 'القسم', value: e.departmentName, icon: Icons.account_tree_rounded),
          EmployeeInfoRow(
              label: 'تاريخ الالتحاق',
              value: e.dateOfJoining == null ? null : MFormat.dateOnly(e.dateOfJoining),
              icon: Icons.event_available_rounded),
          EmployeeInfoRow(
              label: 'نوع العقد', value: e.workerAgreement, icon: Icons.handshake_rounded),
          EmployeeInfoRow(
            label: 'الحالة',
            value: e.isActive ? 'مفعل' : 'غير مفعل',
            icon: Icons.toggle_on_rounded,
            valueColor: e.isActive ? MColors.success : MColors.danger,
          ),
          if (!e.isActive && e.deactivatedAt != null)
            EmployeeInfoRow(
                label: 'تاريخ إلغاء التفعيل',
                value: MFormat.dateOnly(e.deactivatedAt),
                icon: Icons.event_busy_rounded),
        ],
      ),
      EmployeeSectionCard(
        title: 'البيانات المالية',
        icon: Icons.account_balance_wallet_rounded,
        children: [
          EmployeeInfoRow(
              label: 'الراتب الأساسي',
              value: MFormat.money(e.salary),
              icon: Icons.payments_rounded),
          EmployeeInfoRow(
              label: 'البدلات', value: MFormat.money(e.allowances), icon: Icons.add_card_rounded),
          EmployeeInfoRow(
              label: 'نسبة السلفة',
              value: e.advancePercentage == null ? null : '${_num(e.advancePercentage!)}%',
              icon: Icons.percent_rounded),
          EmployeeInfoRow(
              label: 'قيمة التأمينات',
              value: MFormat.money(e.insuranceDeduction),
              icon: Icons.shield_rounded),
          if ((e.insuranceDeduction ?? 0) > 0 ||
              e.insuranceStartDate != null ||
              e.insuranceEndDate != null) ...[
            EmployeeInfoRow(
                label: 'بداية التأمين',
                value: e.insuranceStartDate == null
                    ? null
                    : MFormat.dateOnly(e.insuranceStartDate),
                icon: Icons.event_rounded),
            EmployeeInfoRow(
                label: 'نهاية التأمين',
                value:
                    e.insuranceEndDate == null ? null : MFormat.dateOnly(e.insuranceEndDate),
                icon: Icons.event_rounded),
          ],
          EmployeeInfoRow(
              label: 'معامل الإضافي',
              value: e.overtimeMultiplier == null ? null : '× ${_num(e.overtimeMultiplier!)}',
              icon: Icons.more_time_rounded),
          EmployeeInfoRow(
              label: 'سعر اليوم',
              value: e.dailyRate == null ? null : MFormat.money(e.dailyRate),
              icon: Icons.today_rounded),
          EmployeeInfoRow(
              label: 'سعر الساعة',
              value: e.hourlyRate == null ? null : MFormat.money(e.hourlyRate),
              icon: Icons.hourglass_bottom_rounded),
        ],
      ),
      EmployeeSectionCard(
        title: 'معلومات إضافية',
        icon: Icons.info_rounded,
        children: [
          EmployeeInfoRow(label: 'ملاحظات', value: e.notes, icon: Icons.notes_rounded),
          EmployeeInfoRow(
              label: 'الشهادة',
              value: e.certificates == null ? 'غير مرفقة' : 'مرفقة',
              icon: Icons.school_rounded),
          EmployeeInfoRow(
              label: 'تاريخ الإضافة',
              value: e.createdAt == null ? null : MFormat.dateOnly(e.createdAt),
              icon: Icons.history_rounded),
          EmployeeInfoRow(
              label: 'آخر تحديث',
              value: e.updatedAt == null ? null : MFormat.dateOnly(e.updatedAt),
              icon: Icons.update_rounded),
        ],
      ),
    ];
  }

  // ---------------------------------------------------- الإضافات والخصومات

  void _componentDialog({SalaryComponent? existing, String type = 'addition'}) {
    showSalaryComponentDialog(
      context,
      componentType: existing?.componentType ?? type,
      name: existing?.name,
      amount: existing?.amount,
      notes: existing?.notes,
      isEdit: existing != null,
      onSubmit: (name, amount, t, notes) => c.saveComponent(
        existing: existing,
        name: name,
        amount: amount,
        componentType: t,
        notes: notes,
      ),
    );
  }

  List<Widget> _components(BuildContext context) {
    if (c.componentsStatus == Staterequest.loading ||
        c.componentsStatus == Staterequest.none) {
      return const [MLoading()];
    }
    if (c.componentsStatus == Staterequest.failure) {
      return [
        MMessage.error(c.componentsError ?? 'تعذر التحميل', onRetry: c.loadComponents),
      ];
    }
    return [
      Row(
        children: [
          Expanded(
            child: MStatCard(
              label: 'إجمالي الإضافات',
              value: MFormat.money(c.totalAdditions),
              color: MColors.success,
              icon: Icons.trending_up_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MStatCard(
              label: 'إجمالي الخصومات',
              value: MFormat.money(c.totalDeductions),
              color: MColors.danger,
              icon: Icons.trending_down_rounded,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _componentGroup(
        title: 'الإضافات والبدلات',
        type: 'addition',
        items: c.additions,
        color: MColors.success,
        emptyText: 'لا توجد إضافات',
      ),
      const SizedBox(height: 8),
      _componentGroup(
        title: 'الخصومات',
        type: 'deduction',
        items: c.deductions,
        color: MColors.danger,
        emptyText: 'لا توجد خصومات',
      ),
    ];
  }

  Widget _componentGroup({
    required String title,
    required String type,
    required List<SalaryComponent> items,
    required Color color,
    required String emptyText,
  }) {
    return EmployeeSectionCard(
      title: title,
      icon: type == 'addition' ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
      trailing: TextButton.icon(
        onPressed: () => _componentDialog(type: type),
        icon: Icon(Icons.add_rounded, color: color, size: 18),
        label: Text('إضافة', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      ),
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(emptyText, style: const TextStyle(color: MColors.textLight)),
            ),
          ),
        for (final item in items) _componentTile(item, color),
      ],
    );
  }

  Widget _componentTile(SalaryComponent item, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: item.isActive ? 0.06 : 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: item.isActive ? MColors.textDark : MColors.textLight,
                          )),
                    ),
                    if (!item.isActive) ...[
                      const SizedBox(width: 6),
                      const MChip('موقوف', color: MColors.textMuted),
                    ],
                  ],
                ),
                if (item.notes != null) ...[
                  const SizedBox(height: 3),
                  Text(item.notes!,
                      style: const TextStyle(fontSize: 12, color: MColors.textMuted)),
                ],
              ],
            ),
          ),
          Text(
            MFormat.money(item.amount),
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: MColors.textMuted, size: 20),
            onSelected: (v) {
              if (v == 'edit') _componentDialog(existing: item);
              if (v == 'toggle') c.toggleComponentActive(item);
              if (v == 'delete') c.deleteComponent(item);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('تعديل')),
              PopupMenuItem(
                  value: 'toggle', child: Text(item.isActive ? 'إيقاف مؤقت' : 'تفعيل')),
              const PopupMenuItem(
                  value: 'delete',
                  child: Text('حذف', style: TextStyle(color: MColors.danger))),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------- التواريخ الإضافية

  void _dateDialog({EmployeeCustomDate? existing}) {
    showCustomDateDialog(
      context,
      existing: existing,
      onSubmit: (label, date, notes) =>
          c.saveDate(existing: existing, label: label, dateValue: date, notes: notes),
    );
  }

  List<Widget> _dates(BuildContext context) {
    final header = MSectionTitle(
      'التواريخ الإضافية',
      trailing: TextButton.icon(
        onPressed: () => _dateDialog(),
        icon: const Icon(Icons.add_rounded, color: MColors.primary, size: 18),
        label: const Text('إضافة تاريخ',
            style: TextStyle(color: MColors.primary, fontWeight: FontWeight.w700)),
      ),
    );
    if (c.datesStatus == Staterequest.loading || c.datesStatus == Staterequest.none) {
      return [header, const MLoading()];
    }
    if (c.datesStatus == Staterequest.failure) {
      return [
        header,
        const SizedBox(height: 12),
        MMessage.error(c.datesError ?? 'تعذر التحميل', onRetry: c.loadDates),
      ];
    }
    if (c.dates.isEmpty) {
      return [
        header,
        const SizedBox(height: 12),
        const MMessage.empty('لا توجد تواريخ إضافية', icon: Icons.event_note_rounded),
      ];
    }
    return [
      header,
      const SizedBox(height: 12),
      for (final d in c.dates)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: mCardDecoration(radius: 14),
          child: ListTile(
            contentPadding: const EdgeInsetsDirectional.only(start: 14, end: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: MColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event_rounded, color: MColors.info),
            ),
            title: Text(d.label, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(MFormat.dateOnly(d.dateValue),
                    style: const TextStyle(
                        color: MColors.primary, fontWeight: FontWeight.w600)),
                if (d.notes != null)
                  Text(d.notes!, style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: MColors.textMuted),
              onSelected: (v) {
                if (v == 'edit') _dateDialog(existing: d);
                if (v == 'delete') c.deleteDate(d);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('تعديل')),
                PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف', style: TextStyle(color: MColors.danger))),
              ],
            ),
          ),
        ),
    ];
  }

  // --------------------------------------------------------------- المرفقات

  Future<void> _upload() async {
    final f = await c.pickAttachmentFile();
    if (f == null || !mounted) return;
    await showAttachmentUploadDialog(
      context,
      fileName: f.name,
      onSubmit: (label, notes) =>
          c.uploadAttachment(label: label, filePath: f.path!, notes: notes),
    );
  }

  List<Widget> _attachments(BuildContext context) {
    final header = MSectionTitle(
      'المرفقات',
      trailing: c.uploading
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: MColors.primary),
              ),
            )
          : TextButton.icon(
              onPressed: _upload,
              icon: const Icon(Icons.upload_file_rounded, color: MColors.primary, size: 18),
              label: const Text('رفع مرفق',
                  style: TextStyle(color: MColors.primary, fontWeight: FontWeight.w700)),
            ),
    );
    if (c.attachmentsStatus == Staterequest.loading ||
        c.attachmentsStatus == Staterequest.none) {
      return [header, const MLoading()];
    }
    if (c.attachmentsStatus == Staterequest.failure) {
      return [
        header,
        const SizedBox(height: 12),
        MMessage.error(c.attachmentsError ?? 'تعذر التحميل', onRetry: c.loadAttachments),
      ];
    }
    if (c.attachments.isEmpty) {
      return [
        header,
        const SizedBox(height: 12),
        const MMessage.empty('لا توجد مرفقات', icon: Icons.folder_open_rounded),
      ];
    }
    return [
      header,
      const SizedBox(height: 12),
      for (final a in c.attachments) _attachmentTile(a),
    ];
  }

  Widget _attachmentTile(EmployeeAttachmentItem a) {
    final busy = c.busyAttachments.contains(a.id);
    final color = attachmentColor(a.extension);
    final meta = [
      a.fileName,
      if (a.sizeLabel.isNotEmpty) a.sizeLabel,
      if (a.createdAt != null) MFormat.dateOnly(a.createdAt),
    ].join(' • ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: mCardDecoration(radius: 14),
      child: ListTile(
        onTap: busy ? null : () => c.openAttachment(a),
        contentPadding: const EdgeInsetsDirectional.only(start: 14, end: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(attachmentIcon(a.extension), color: color),
        ),
        title: Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meta,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12)),
            if (a.notes != null)
              Text(a.notes!, style: const TextStyle(fontSize: 12, color: MColors.textMuted)),
          ],
        ),
        trailing: busy
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: MColors.primary),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'فتح',
                    icon: const Icon(Icons.open_in_new_rounded, color: MColors.info),
                    onPressed: () => c.openAttachment(a),
                  ),
                  IconButton(
                    tooltip: 'حذف',
                    icon: const Icon(Icons.delete_outline_rounded, color: MColors.danger),
                    onPressed: () => c.deleteAttachment(a),
                  ),
                ],
              ),
      ),
    );
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

// ---------------------------------------------------------------- الترويسة

class _Header extends StatelessWidget {
  final EmployeeDetailController c;
  final ManagedEmployee e;
  const _Header({required this.c, required this.e});

  void _photoOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: MColors.primary),
                title: Text(e.photoAttachmentId == null ? 'إضافة صورة' : 'تغيير الصورة'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  c.changePhoto();
                },
              ),
              if (e.photoAttachmentId != null)
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: MColors.danger),
                  title: const Text('حذف الصورة', style: TextStyle(color: MColors.danger)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    c.deletePhoto();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: mCardDecoration(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: c.busy ? null : () => _photoOptions(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    EmployeeAvatar(
                      photoId: e.photoAttachmentId,
                      initials: e.initials,
                      isActive: e.isActive,
                      size: 78,
                    ),
                    PositionedDirectional(
                      bottom: -2,
                      end: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: MColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.fullName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: MColors.textDark),
                    ),
                    const SizedBox(height: 3),
                    Text(e.jobLabel,
                        style: const TextStyle(fontSize: 13, color: MColors.textMuted)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        MChip(e.typeLabel,
                            color: e.isPermanent ? MColors.info : MColors.warning,
                            icon: Icons.badge_rounded),
                        if (e.workSystem != null)
                          MChip(e.workSystemLabel,
                              color: MColors.primary, icon: Icons.schedule_rounded),
                        if (e.isDepartmentHead)
                          const MChip('رئيس قسم',
                              color: MColors.success, icon: Icons.star_rounded),
                        if (e.scopeLabel != '-')
                          MChip(e.scopeLabel,
                              color: MColors.textMuted, icon: Icons.apartment_rounded),
                        if (e.fingerprintId != null)
                          MChip(e.fingerprintId!,
                              color: MColors.textMuted, icon: Icons.fingerprint_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: MColors.border),
          Row(
            children: [
              Icon(
                e.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: e.isActive ? MColors.success : MColors.danger,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.isActive ? 'الموظف مفعل' : 'الموظف غير مفعل',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: e.isActive ? MColors.success : MColors.danger,
                  ),
                ),
              ),
              if (c.statusBusy)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: MColors.primary),
                  ),
                )
              else
                Switch(
                  value: e.isActive,
                  activeTrackColor: MColors.success,
                  onChanged: (_) => c.toggleActive(),
                ),
            ],
          ),
          if (c.busy) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(color: MColors.primary, minHeight: 3),
            if (c.busyLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(c.busyLabel!,
                    style: const TextStyle(fontSize: 12, color: MColors.textMuted)),
              ),
          ],
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- التبويبات

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate();

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: MColors.background,
      child: const TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: MColors.primary,
        unselectedLabelColor: MColors.textMuted,
        indicatorColor: MColors.primary,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        tabs: [
          Tab(text: 'البيانات الأساسية'),
          Tab(text: 'الإضافات والخصومات'),
          Tab(text: 'التواريخ الإضافية'),
          Tab(text: 'المرفقات'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

class _TabList extends StatelessWidget {
  final String storageKey;
  final List<Widget> children;
  const _TabList({required this.storageKey, required this.children});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => CustomScrollView(
        key: PageStorageKey<String>(storageKey),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            sliver: SliverList(delegate: SliverChildListDelegate(children)),
          ),
        ],
      ),
    );
  }
}
