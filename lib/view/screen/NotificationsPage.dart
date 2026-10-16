import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/notifications_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/push_notification_service.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(NotificationsController());

    return ManagerScaffold(
      title: 'الإشعارات',
      actions: [
        GetBuilder<NotificationsController>(
          builder: (c) => c.unreadCount > 0
              ? IconButton(
                  tooltip: 'تعليم الكل كمقروء',
                  icon: const Icon(Icons.done_all_rounded),
                  onPressed: c.markAllRead,
                )
              : const SizedBox.shrink(),
        ),
      ],
      body: GetBuilder<NotificationsController>(
        builder: (c) => RefreshIndicator(
          color: MColors.primary,
          onRefresh: ctrl.fetch,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: _buildBody(c),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(NotificationsController c) {
    if (c.staterequest == Staterequest.loading && c.items.isEmpty) {
      return const [MLoading()];
    }
    if (c.staterequest == Staterequest.failure) {
      return [MMessage.error(c.errorMessage ?? 'فشل تحميل الإشعارات', onRetry: c.fetch)];
    }
    if (c.items.isEmpty) {
      return const [
        MMessage.empty('لا توجد إشعارات', icon: Icons.notifications_none_rounded),
      ];
    }
    return c.items
        .map((n) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: MColors.danger,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                onDismissed: (_) => c.remove(n),
                child: _NotificationTile(n: n, onTap: () => _open(c, n)),
              ),
            ))
        .toList();
  }

  Future<void> _open(NotificationsController c, AppNotification n) async {
    c.markRead(n);
    if (n.entityType != null) {
      await PushNotificationService.openTarget(n.target);
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification n;
  final VoidCallback onTap;
  const _NotificationTile({required this.n, required this.onTap});

  static const _icons = {
    'advance': Icons.account_balance_wallet_rounded,
    'reward': Icons.card_giftcard_rounded,
    'penalty': Icons.gavel_rounded,
    'leave': Icons.event_note_rounded,
    'attendance': Icons.fingerprint_rounded,
    'kpi': Icons.star_rounded,
  };

  static const _colors = {
    'advance': MColors.success,
    'reward': MColors.info,
    'penalty': MColors.danger,
    'leave': MColors.warning,
  };

  String _timeAgo(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return MFormat.date(d);
  }

  @override
  Widget build(BuildContext context) {
    final color = _colors[n.type] ?? MColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: mCardDecoration().copyWith(
          color: n.isRead ? Colors.white : const Color(0xFFFFF7F5),
          border: n.isRead
              ? null
              : Border.all(color: MColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icons[n.type] ?? Icons.notifications_rounded,
                  color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: MColors.textDark,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: MColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: const TextStyle(
                        fontSize: 13, color: MColors.text, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(n.createdAt),
                    style: const TextStyle(fontSize: 11, color: MColors.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
