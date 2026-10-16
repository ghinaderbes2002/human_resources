// TransactionDetailPage.dart
// تفاصيل معاملة + مسار الموافقات + إجراءات (موافقة/رفض/حذف)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/transaction_manager_controller.dart';
import 'package:human_resources/model/manager/transaction_models.dart';
import 'package:human_resources/view/screen/manager/transactions/transaction_widgets.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class TransactionDetailPage extends StatefulWidget {
  final int transactionId;

  /// بيانات مبدئية من القائمة لعرض العنوان أثناء التحميل
  final TransactionItem? preview;

  const TransactionDetailPage({super.key, required this.transactionId, this.preview});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final TransactionManagerController ctrl = Get.find<TransactionManagerController>();

  TransactionDetail? detail;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = null;
    });
    final res = await ctrl.fetchDetail(widget.transactionId);
    if (!mounted) return;
    setState(() {
      loading = false;
      if (res.ok) {
        detail = res.data;
      } else {
        error = res.error;
      }
    });
  }

  bool get _changingMind {
    final d = detail;
    if (d == null) return false;
    final v = ctrl.myVote(d);
    return v == 'approved' || v == 'rejected';
  }

  Future<void> _approve() async {
    if (await txApproveFlow(ctrl, widget.transactionId, changingMind: _changingMind)) await _load();
  }

  Future<void> _reject() async {
    if (await txRejectFlow(ctrl, widget.transactionId, changingMind: _changingMind)) await _load();
  }

  Future<void> _delete() async {
    if (await txDeleteFlow(ctrl, widget.transactionId)) {
      // Navigator بدل Get.back حتى لا يُغلق إشعار النجاح بدلاً من الصفحة
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = detail;
    final title = d?.typeInfo.label ?? widget.preview?.typeInfo.label ?? 'تفاصيل المعاملة';
    return ManagerScaffold(
      title: title,
      actions: [
        IconButton(
          tooltip: 'تحديث',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: loading ? null : _load,
        ),
      ],
      body: Builder(
        builder: (context) {
          if (loading && d == null) return const MLoading();
          if (d == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: MMessage.error(error ?? 'فشل تحميل تفاصيل المعاملة', onRetry: _load),
            );
          }
          return Column(
            children: [
              if (loading) const LinearProgressIndicator(color: MColors.primary, minHeight: 2),
              Expanded(
                child: RefreshIndicator(
                  color: MColors.primary,
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: _content(d),
                  ),
                ),
              ),
              GetBuilder<TransactionManagerController>(
                builder: (c) => _actionBar(c, d),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _content(TransactionDetail d) {
    final type = d.typeInfo;
    final detailFields = d.details.fields(d.type);
    return [
      // ---------- الرأس ----------
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: mCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TxTypeIcon(type, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.label,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: MColors.textDark)),
                      const SizedBox(height: 2),
                      Text(d.transactionNumber,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(fontSize: 13, color: MColors.textMuted)),
                    ],
                  ),
                ),
                TxStatusChip(d.status),
              ],
            ),
            const Divider(height: 24, color: MColors.border),
            TxInfoRow('تاريخ الإنشاء', txDateTime(d.createdAt), icon: Icons.schedule_rounded),
            if (d.approvedAt != null)
              TxInfoRow('تاريخ الاعتماد', txDateTime(d.approvedAt),
                  icon: Icons.verified_rounded, valueColor: MColors.success),
            if (d.rejectedAt != null)
              TxInfoRow('تاريخ الرفض', txDateTime(d.rejectedAt),
                  icon: Icons.block_rounded, valueColor: MColors.danger),
          ],
        ),
      ),

      // ---------- سبب الرفض ----------
      if (d.reasonForRejection != null)
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: MColors.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MColors.danger.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.report_rounded, color: MColors.danger),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('سبب الرفض',
                        style: TextStyle(fontWeight: FontWeight.w700, color: MColors.danger)),
                    const SizedBox(height: 4),
                    Text(d.reasonForRejection!,
                        style: const TextStyle(color: MColors.danger, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),

      // ---------- الموظف ----------
      TxSection(
        title: 'الموظف',
        children: [
          TxInfoRow('الاسم', d.employee.fullName, icon: Icons.person_outline_rounded),
          if (d.employee.fingerprintId != null)
            TxInfoRow('رقم البصمة', d.employee.fingerprintId!, icon: Icons.fingerprint_rounded),
          if (d.employee.branch != null)
            TxInfoRow('الفرع', d.employee.branch!, icon: Icons.store_mall_directory_outlined),
          if (d.employee.department != null)
            TxInfoRow('القسم', d.employee.department!, icon: Icons.apartment_rounded),
        ],
      ),

      // ---------- مقدم الطلب ----------
      TxSection(
        title: 'مقدم الطلب',
        children: [
          TxInfoRow('الاسم', d.requester.displayName, icon: Icons.badge_outlined),
          TxInfoRow('اسم المستخدم', d.requester.username, icon: Icons.alternate_email_rounded),
          TxInfoRow('الصفة', d.requester.roleLabel, icon: Icons.workspace_premium_outlined),
        ],
      ),

      // ---------- التفاصيل ----------
      TxSection(
        title: 'تفاصيل ${type.label}',
        children: detailFields.isEmpty
            ? [const Text('لا توجد تفاصيل', style: TextStyle(color: MColors.textMuted))]
            : detailFields.map((e) => TxInfoRow(e.key, e.value)).toList(),
      ),

      // ---------- الملاحظات ----------
      if (d.notes != null)
        TxSection(
          title: 'ملاحظات',
          children: [
            Text(d.notes!, style: const TextStyle(fontSize: 14, color: MColors.text, height: 1.5)),
          ],
        ),

      // ---------- مسار الموافقات ----------
      TxSection(
        title: 'مسار الموافقات',
        trailing: MChip(
          '${d.approvedCount}/${d.approvals.length} موافقات',
          color: d.rejectedCount > 0 ? MColors.danger : MColors.success,
        ),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'تُعتمد المعاملة بموافقة جميع المعنيين، ولا تُرفض إلا إذا رفضها الجميع. يمكن لكل منهم تغيير رأيه طالما المعاملة معلّقة.',
              style: TextStyle(fontSize: 12, color: MColors.textMuted),
            ),
          ),
          if (d.approvals.isEmpty)
            const Text('لا توجد سجلات موافقة', style: TextStyle(color: MColors.textMuted))
          else
            for (var i = 0; i < d.approvals.length; i++)
              _ApprovalTile(
                entry: d.approvals[i],
                isLast: i == d.approvals.length - 1,
                isMe: d.approvals[i].approver.id != null &&
                    d.approvals[i].approver.id == ctrl.session?.userId,
              ),
        ],
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _actionBar(TransactionManagerController c, TransactionDetail d) {
    final canApprove = c.canApprove(d);
    final canReject = c.canReject(d);
    final canAct = canApprove || canReject;
    final canDelete = c.canDelete(status: d.status, requesterId: d.requester.id);
    if (!canAct && !canDelete) return const SizedBox.shrink();
    final busy = c.busy;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final myVote = c.myVote(d);
    final changingMind = myVote == 'approved' || myVote == 'rejected';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canAct && changingMind)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        myVote == 'approved' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 16,
                        color: myVote == 'approved' ? MColors.success : MColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          myVote == 'approved'
                              ? 'لقد وافقت على هذه المعاملة، ويمكنك تغيير رأيك طالما هي معلّقة.'
                              : 'لقد رفضت هذه المعاملة، ويمكنك تغيير رأيك طالما هي معلّقة.',
                          style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  if (canApprove)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MColors.success,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: shape,
                          ),
                          onPressed: busy ? null : _approve,
                          icon: busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(changingMind ? 'تغيير إلى موافقة' : 'موافقة',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  if (canApprove && canReject) const SizedBox(width: 10),
                  if (canReject)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MColors.danger,
                            side: const BorderSide(color: MColors.danger),
                            shape: shape,
                          ),
                          onPressed: busy ? null : _reject,
                          icon: const Icon(Icons.close_rounded),
                          label: Text(changingMind ? 'تغيير إلى رفض' : 'رفض',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ..._deleteButton(canAct: canAct, canDelete: canDelete, busy: busy, shape: shape),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _deleteButton({
    required bool canAct,
    required bool canDelete,
    required bool busy,
    required OutlinedBorder shape,
  }) {
    if (!canDelete) return const [];
    return [
      if (canAct) const SizedBox(width: 10),
      canAct
          ? SizedBox(
              height: 48,
              width: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: MColors.textMuted,
                  side: const BorderSide(color: MColors.border),
                  padding: EdgeInsets.zero,
                  shape: shape,
                ),
                onPressed: busy ? null : _delete,
                child: const Icon(Icons.delete_outline_rounded),
              ),
            )
          : Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MColors.danger,
                    side: const BorderSide(color: MColors.danger),
                    shape: shape,
                  ),
                  onPressed: busy ? null : _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('حذف المعاملة',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
    ];
  }
}

/// عنصر في خط زمني للموافقات
class _ApprovalTile extends StatelessWidget {
  final TxApprovalEntry entry;
  final bool isLast;
  final bool isMe;
  const _ApprovalTile({required this.entry, required this.isLast, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final color = TxConst.statusColor(entry.status);
    final date = entry.actionDate;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(TxConst.statusIcon(entry.status), size: 15, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: MColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isMe ? '${entry.approver.displayName} (أنت)' : entry.approver.displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: MColors.textDark,
                          ),
                        ),
                      ),
                      MChip(TxConst.approvalStatusLabel(entry.status), color: color),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.approver.username}  •  ${entry.approver.roleLabel}',
                    style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      txDateTime(date),
                      style: const TextStyle(fontSize: 12, color: MColors.textLight),
                    ),
                  ],
                  if (entry.notes != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.notes!,
                        style: const TextStyle(fontSize: 13, color: MColors.text),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
