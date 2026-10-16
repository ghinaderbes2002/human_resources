// transaction_widgets.dart
// عناصر مشتركة لشاشات "معاملات الموظفين"
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/transaction_manager_controller.dart';
import 'package:human_resources/model/manager/transaction_models.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

/// شريحة فلترة قابلة للاختيار
class TxFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const TxFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = MColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? color : MColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? Colors.white : color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : MColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// أيقونة نوع المعاملة داخل مربع ملوّن
class TxTypeIcon extends StatelessWidget {
  final TxType type;
  final double size;
  const TxTypeIcon(this.type, {super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(type.icon, color: type.color, size: size * 0.52),
    );
  }
}

class TxStatusChip extends StatelessWidget {
  final String status;
  const TxStatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return MChip(
      TxConst.statusLabel(status),
      color: TxConst.statusColor(status),
      icon: TxConst.statusIcon(status),
    );
  }
}

/// بطاقة معاملة في القوائم
class TxCard extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback onTap;
  final bool awaitingMe;

  /// أزرار إضافية أسفل البطاقة (مثل موافقة/رفض سريع)
  final Widget? footer;

  const TxCard({
    super.key,
    required this.item,
    required this.onTap,
    this.awaitingMe = false,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final type = item.typeInfo;
    final counts = item.approvals;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: mCardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TxTypeIcon(type),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: MColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.transactionNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    TxStatusChip(item.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 17, color: MColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: item.employee.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: MColors.text,
                              ),
                            ),
                            if (item.employee.fingerprintId != null)
                              TextSpan(
                                text: '  •  بصمة: ${item.employee.fingerprintId}',
                                style: const TextStyle(color: MColors.textMuted, fontSize: 12),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: MColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.summary,
                    style: const TextStyle(fontSize: 13, color: MColors.text),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (counts != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.how_to_reg_rounded,
                                    size: 16, color: MColors.success),
                                const SizedBox(width: 4),
                                Text(
                                  '${counts.approved}/${counts.total} موافقات',
                                  style: const TextStyle(fontSize: 12, color: MColors.text),
                                ),
                              ],
                            ),
                            if (counts.rejected > 0)
                              Text(
                                'رفض: ${counts.rejected}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: MColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ] else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.badge_outlined,
                                    size: 16, color: MColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  'بواسطة: ${item.requester.username}',
                                  style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                                ),
                              ],
                            ),
                          if (awaitingMe) const MChip('بانتظار موافقتك', color: MColors.primary),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today_outlined, size: 13, color: MColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      txDate(item.createdAt),
                      style: const TextStyle(fontSize: 12, color: MColors.textLight),
                    ),
                  ],
                ),
                if (counts != null && counts.total > 0) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: counts.approved / counts.total,
                      minHeight: 4,
                      backgroundColor: MColors.border,
                      color: counts.rejected > 0 ? MColors.danger : MColors.success,
                    ),
                  ),
                ],
                if (footer != null) ...[
                  const SizedBox(height: 12),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// صف معلومة (عنوان: قيمة)
class TxInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  const TxInfoRow(this.label, this.value, {super.key, this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: MColors.textMuted),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: MColors.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
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

/// بطاقة قسم بعنوان
class TxSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  const TxSection({super.key, required this.title, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: mCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MSectionTitle(title, trailing: trailing),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

// ============================ تدفقات الإجراءات ============================

/// إغلاق أي إشعار مفتوح قبل فتح نافذة، لأن Get.back يغلق الإشعار أولاً بدل النافذة
void _closeSnackbars() {
  if (Get.isSnackbarOpen) Get.closeAllSnackbars();
}

/// موافقة مع ملاحظات اختيارية. تُرجع true عند النجاح.
Future<bool> txApproveFlow(TransactionManagerController ctrl, int id) async {
  _closeSnackbars();
  final notes = await MDialogs.prompt(
    title: 'الموافقة على المعاملة',
    label: 'ملاحظات (اختياري)',
    confirmText: 'موافقة',
    confirmColor: MColors.success,
  );
  if (notes == null) return false;
  final res = await ctrl.approve(id, notes: notes);
  if (res.ok) {
    MDialogs.success(res.message ?? 'تمت الموافقة');
  } else {
    MDialogs.error(res.error!);
  }
  return res.ok;
}

/// رفض مع سبب إلزامي. تُرجع true عند النجاح.
Future<bool> txRejectFlow(TransactionManagerController ctrl, int id) async {
  _closeSnackbars();
  final reason = await MDialogs.prompt(
    title: 'رفض المعاملة',
    label: 'سبب الرفض',
    required: true,
    confirmText: 'رفض',
    confirmColor: MColors.danger,
  );
  if (reason == null || reason.trim().isEmpty) return false;
  final res = await ctrl.reject(id, reason);
  if (res.ok) {
    MDialogs.success(res.message ?? 'تم رفض المعاملة');
  } else {
    MDialogs.error(res.error!);
  }
  return res.ok;
}

/// حذف بعد التأكيد. تُرجع true عند النجاح.
Future<bool> txDeleteFlow(TransactionManagerController ctrl, int id) async {
  _closeSnackbars();
  final yes = await MDialogs.confirm(
    title: 'تأكيد الحذف',
    message: 'هل أنت متأكد من حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.',
    confirmText: 'حذف',
    confirmColor: MColors.danger,
  );
  if (!yes) return false;
  final res = await ctrl.delete(id);
  if (res.ok) {
    MDialogs.success(res.message ?? 'تم حذف المعاملة بنجاح');
  } else {
    MDialogs.error(res.error!);
  }
  return res.ok;
}
