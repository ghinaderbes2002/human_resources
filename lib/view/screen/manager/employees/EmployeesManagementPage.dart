// EmployeesManagementPage.dart
// شاشة "إدارة الموظفين" للمدراء (رئيس/نائب فرع أو قسم)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/employee_manager_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/model/manager/employee_models.dart';
import 'package:human_resources/view/screen/manager/employees/EmployeeDetailPage.dart';
import 'package:human_resources/view/screen/manager/employees/EmployeeFormPage.dart';
import 'package:human_resources/view/screen/manager/employees/employee_widgets.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class EmployeesManagementPage extends StatelessWidget {
  const EmployeesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeManagerController>(
      init: EmployeeManagerController(),
      builder: (c) => ManagerScaffold(
        title: 'إدارة الموظفين',
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: c.status == Staterequest.loading ? null : () => c.load(),
          ),
        ],
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: MColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('إضافة موظف', style: TextStyle(fontWeight: FontWeight.w700)),
          onPressed: () => Get.to(() => const EmployeeFormPage()),
        ),
        body: RefreshIndicator(
          color: MColors.primary,
          onRefresh: () => c.load(silent: true),
          child: _Body(c: c),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final EmployeeManagerController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    final items = c.filtered;
    final ready = c.status == Staterequest.success || c.status == Staterequest.empty;

    Widget? stateWidget;
    if (c.status == Staterequest.loading || c.status == Staterequest.none) {
      stateWidget = const MLoading();
    } else if (c.status == Staterequest.failure) {
      stateWidget = MMessage.error(c.errorMessage ?? 'تعذر تحميل الموظفين', onRetry: c.load);
    } else if (c.employees.isEmpty) {
      stateWidget = const MMessage.empty('لا يوجد موظفون بعد', icon: Icons.groups_2_outlined);
    } else if (items.isEmpty) {
      stateWidget = const MMessage.empty('لا توجد نتائج مطابقة للبحث أو التصفية',
          icon: Icons.search_off_rounded);
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (c.session?.scopeName != null) ...[
                _ScopeBanner(role: c.session!.roleLabel, scope: c.session!.scopeName!),
                const SizedBox(height: 12),
              ],
              if (ready) ...[
                _Stats(c: c),
                const SizedBox(height: 14),
              ],
              MSearchField(
                controller: c.searchCtrl,
                hint: 'بحث بالاسم، رقم البصمة، الرقم القومي أو الجوال',
                onChanged: c.onSearch,
              ),
              const SizedBox(height: 12),
              _Filters(c: c),
              const SizedBox(height: 10),
              if (ready && c.employees.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'عرض ${items.length} من ${c.totalCount} موظف',
                    style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                  ),
                ),
              if (stateWidget != null) stateWidget,
            ]),
          ),
        ),
        if (stateWidget == null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _EmployeeCard(c: c, e: items[i]),
            ),
          )
        else
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _ScopeBanner extends StatelessWidget {
  final String role;
  final String scope;
  const _ScopeBanner({required this.role, required this.scope});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MColors.primary, MColors.primaryLight],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.apartment_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$role — $scope',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final EmployeeManagerController c;
  const _Stats({required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MStatCard(
            label: 'الإجمالي',
            value: '${c.totalCount}',
            color: MColors.info,
            icon: Icons.groups_rounded,
            onTap: () => c.setActiveFilter(EmployeeActiveFilter.all),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MStatCard(
            label: 'نشط',
            value: '${c.activeCount}',
            color: MColors.success,
            icon: Icons.verified_user_rounded,
            onTap: () => c.setActiveFilter(EmployeeActiveFilter.active),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MStatCard(
            label: 'غير نشط',
            value: '${c.inactiveCount}',
            color: MColors.danger,
            icon: Icons.person_off_rounded,
            onTap: () => c.setActiveFilter(EmployeeActiveFilter.inactive),
          ),
        ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  final EmployeeManagerController c;
  const _Filters({required this.c});

  Widget _chip(String label, bool selected, VoidCallback onTap, {Color color = MColors.primary}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: color.withValues(alpha: 0.15),
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? color : MColors.border),
        labelStyle: TextStyle(
          color: selected ? color : MColors.text,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('الكل', c.activeFilter == EmployeeActiveFilter.all,
              () => c.setActiveFilter(EmployeeActiveFilter.all)),
          _chip('نشط', c.activeFilter == EmployeeActiveFilter.active,
              () => c.setActiveFilter(EmployeeActiveFilter.active),
              color: MColors.success),
          _chip('غير نشط', c.activeFilter == EmployeeActiveFilter.inactive,
              () => c.setActiveFilter(EmployeeActiveFilter.inactive),
              color: MColors.danger),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsetsDirectional.only(end: 8),
            color: MColors.border,
          ),
          _chip('دائم (${c.permanentCount})', c.typeFilter == EmployeeTypeFilter.permanent,
              () => c.setTypeFilter(EmployeeTypeFilter.permanent),
              color: MColors.info),
          _chip('مؤقت (${c.temporaryCount})', c.typeFilter == EmployeeTypeFilter.temporary,
              () => c.setTypeFilter(EmployeeTypeFilter.temporary),
              color: MColors.warning),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeManagerController c;
  final ManagedEmployee e;
  const _EmployeeCard({required this.c, required this.e});

  @override
  Widget build(BuildContext context) {
    final busy = c.busyIds.contains(e.id);
    return Container(
      decoration: mCardDecoration(radius: 14).copyWith(
        color: e.isActive ? Colors.white : const Color(0xFFFAFAFA),
        border: e.isActive ? null : Border.all(color: MColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Get.to(() => EmployeeDetailPage(employee: e)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmployeeAvatar(
                  photoId: e.photoAttachmentId,
                  initials: e.initials,
                  isActive: e.isActive,
                  size: 54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              e.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: e.isActive ? MColors.textDark : MColors.textMuted,
                              ),
                            ),
                          ),
                          if (!e.isActive) ...[
                            const SizedBox(width: 6),
                            const MChip('غير مفعل', color: MColors.danger),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        e.jobLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: MColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          MChip(e.typeLabel,
                              color: e.isPermanent ? MColors.info : MColors.warning),
                          if (e.workSystem != null)
                            MChip(e.workSystemLabel,
                                color: MColors.primary, icon: Icons.schedule_rounded),
                          if (e.fingerprintId != null)
                            MChip(e.fingerprintId!,
                                color: MColors.textMuted, icon: Icons.fingerprint_rounded),
                          if (e.isDepartmentHead)
                            const MChip('رئيس قسم',
                                color: MColors.success, icon: Icons.star_rounded),
                        ],
                      ),
                      if (e.mobile1 != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, size: 14, color: MColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              e.mobile1!,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(fontSize: 12, color: MColors.text),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (busy)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: MColors.primary),
                    ),
                  )
                else
                  _ActionsMenu(c: c, e: e),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  final EmployeeManagerController c;
  final ManagedEmployee e;
  const _ActionsMenu({required this.c, required this.e});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: MColors.textMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) {
        switch (v) {
          case 'edit':
            Get.to(() => EmployeeFormPage(employee: e));
            break;
          case 'toggle':
            c.toggleActive(e);
            break;
          case 'delete':
            c.deleteEmployee(e);
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_rounded, color: MColors.info),
            title: Text('تعديل'),
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              e.isActive ? Icons.person_off_rounded : Icons.person_rounded,
              color: e.isActive ? MColors.warning : MColors.success,
            ),
            title: Text(e.isActive ? 'إلغاء التفعيل' : 'تفعيل'),
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_rounded, color: MColors.danger),
            title: Text('حذف', style: TextStyle(color: MColors.danger)),
          ),
        ),
      ],
    );
  }
}
