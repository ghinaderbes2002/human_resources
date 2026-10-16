// TransactionsManagementPage.dart
// شاشة "معاملات الموظفين" للمدراء: بانتظار موافقتي + كل المعاملات
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/transaction_manager_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/model/manager/transaction_models.dart';
import 'package:human_resources/view/screen/manager/transactions/CreateTransactionPage.dart';
import 'package:human_resources/view/screen/manager/transactions/TransactionDetailPage.dart';
import 'package:human_resources/view/screen/manager/transactions/transaction_widgets.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class TransactionsManagementPage extends StatefulWidget {
  const TransactionsManagementPage({super.key});

  @override
  State<TransactionsManagementPage> createState() => _TransactionsManagementPageState();
}

class _TransactionsManagementPageState extends State<TransactionsManagementPage> {
  late final TransactionManagerController ctrl;
  // هل أنشأت هذه الصفحة الكنترولر؟ (حتى لا تحذفه صفحة أخرى ما زالت تستخدمه)
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<TransactionManagerController>()) {
      ctrl = Get.find<TransactionManagerController>();
    } else {
      ctrl = Get.put(TransactionManagerController());
      _ownsController = true;
    }

    // فتح معاملة محددة مباشرة (مثلاً عند الضغط على إشعار)
    final args = Get.arguments;
    final openId = args is Map ? args['openTransactionId'] : null;
    if (openId is int) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.to(() => TransactionDetailPage(transactionId: openId));
      });
    }
  }

  @override
  void dispose() {
    if (_ownsController) Get.delete<TransactionManagerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ManagerScaffold(
        title: 'معاملات الموظفين',
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.refreshAll,
          ),
        ],
        bottom: TabBar(
          labelColor: MColors.primary,
          unselectedLabelColor: MColors.textMuted,
          indicatorColor: MColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(
              child: GetBuilder<TransactionManagerController>(
                builder: (c) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('بانتظار موافقتي'),
                    if (c.pendingCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: MColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${c.pendingCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Tab(text: 'كل المعاملات'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: MColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('إنشاء معاملة', style: TextStyle(fontWeight: FontWeight.w700)),
          onPressed: () => Get.to(() => CreateTransactionPage(initialType: ctrl.typeFilter)),
        ),
        body: const TabBarView(
          children: [
            _PendingTab(),
            _AllTab(),
          ],
        ),
      ),
    );
  }
}

void _openDetail(TransactionItem item) {
  Get.to(() => TransactionDetailPage(transactionId: item.id, preview: item));
}

// ============================ بانتظار موافقتي ============================

class _PendingTab extends StatelessWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionManagerController>(
      builder: (c) {
        Widget content;
        if (c.pendingState == Staterequest.loading && c.pending.isEmpty) {
          content = const MLoading();
        } else if (c.pendingState == Staterequest.failure) {
          content = MMessage.error(c.pendingError, onRetry: c.loadPending);
        } else if (c.pending.isEmpty) {
          content = const MMessage.empty(
            'لا توجد معاملات بانتظار موافقتك',
            icon: Icons.task_alt_rounded,
          );
        } else {
          content = Column(
            children: c.pending.map((p) {
              final t = p.transaction;
              return TxCard(
                item: t,
                awaitingMe: true,
                onTap: () => _openDetail(t),
                footer: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MColors.danger,
                          side: const BorderSide(color: MColors.danger),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: c.busy ? null : () => txRejectFlow(c, t.id),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('رفض'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MColors.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: c.busy ? null : () => txApproveFlow(c, t.id),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('موافقة'),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }

        return RefreshIndicator(
          color: MColors.primary,
          onRefresh: c.refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (c.pending.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: MColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'لديك ${c.pending.length} معاملة تحتاج إلى قرارك. تُعتمد المعاملة بموافقة جميع المعنيين، ولا تُرفض إلا إذا رفضها الجميع. يمكنك تغيير رأيك لاحقاً من تفاصيل المعاملة طالما هي معلّقة.',
                          style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              if (c.busy) const LinearProgressIndicator(color: MColors.primary, minHeight: 2),
              content,
            ],
          ),
        );
      },
    );
  }
}

// ============================ كل المعاملات ============================

class _AllTab extends StatefulWidget {
  const _AllTab();

  @override
  State<_AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<_AllTab> with AutomaticKeepAliveClientMixin {
  final TextEditingController _search = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _search.text = Get.find<TransactionManagerController>().search;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<TransactionManagerController>(
      builder: (c) {
        final visible = c.visibleItems;
        final showList = c.listState == Staterequest.success && visible.isNotEmpty;

        Widget? state;
        if (c.listState == Staterequest.loading || c.listState == Staterequest.none) {
          state = const MLoading();
        } else if (c.listState == Staterequest.failure) {
          state = MMessage.error(c.listError, onRetry: c.loadTransactions);
        } else if (c.items.isEmpty) {
          state = const MMessage.empty('لا توجد معاملات');
        } else if (visible.isEmpty) {
          state = const MMessage.empty('لا توجد نتائج مطابقة للبحث', icon: Icons.search_off_rounded);
        }

        final itemCount = 1 + (showList ? visible.length : 1) + 1;

        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 300) c.loadMore();
            return false;
          },
          child: RefreshIndicator(
            color: MColors.primary,
            onRefresh: c.refreshAll,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: itemCount,
              itemBuilder: (context, i) {
                if (i == 0) return _header(c);
                if (i == itemCount - 1) return _footer(c, showList);
                if (!showList) return state ?? const SizedBox.shrink();
                final t = visible[i - 1];
                return TxCard(
                  item: t,
                  awaitingMe: t.status == 'pending' && c.isAwaitingMe(t.id),
                  onTap: () => _openDetail(t),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _header(TransactionManagerController c) {
    final stats = c.currentStats;
    final typeLabel = c.typeFilter == null ? 'كل الأنواع' : TxConst.type(c.typeFilter).label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MSearchField(
          hint: 'ابحث باسم الموظف أو رقم المعاملة',
          controller: _search,
          onChanged: c.setSearch,
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              TxFilterChip(
                label: 'الكل',
                icon: Icons.apps_rounded,
                selected: c.typeFilter == null,
                onTap: () => c.setTypeFilter(null),
              ),
              ...TxConst.types.map((t) => TxFilterChip(
                    label: t.label,
                    icon: t.icon,
                    color: t.color,
                    selected: c.typeFilter == t.value,
                    onTap: () => c.setTypeFilter(t.value),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              TxFilterChip(
                label: 'الكل',
                selected: c.statusFilter == null,
                color: MColors.textDark,
                onTap: () => c.setStatusFilter(null),
              ),
              for (final s in const ['pending', 'approved', 'rejected'])
                TxFilterChip(
                  label: TxConst.statusLabel(s),
                  icon: TxConst.statusIcon(s),
                  color: TxConst.statusColor(s),
                  selected: c.statusFilter == s,
                  onTap: () => c.setStatusFilter(s),
                ),
            ],
          ),
        ),
        if (stats != null) ...[
          const SizedBox(height: 16),
          MSectionTitle('إحصائيات: $typeLabel'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MStatCard(
                  label: 'الإجمالي',
                  value: '${stats.total}',
                  color: MColors.info,
                  icon: Icons.receipt_long_rounded,
                  onTap: () => c.setStatusFilter(null),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MStatCard(
                  label: 'معلقة',
                  value: '${stats.pending}',
                  color: MColors.warning,
                  icon: Icons.hourglass_top_rounded,
                  onTap: () => c.setStatusFilter('pending'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MStatCard(
                  label: 'موافق عليها',
                  value: '${stats.approved}',
                  color: MColors.success,
                  icon: Icons.check_circle_rounded,
                  onTap: () => c.setStatusFilter('approved'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MStatCard(
                  label: 'مرفوضة',
                  value: '${stats.rejected}',
                  color: MColors.danger,
                  icon: Icons.cancel_rounded,
                  onTap: () => c.setStatusFilter('rejected'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        MSectionTitle(
          'المعاملات',
          trailing: c.listState == Staterequest.success
              ? Text(
                  c.search.isEmpty
                      ? '${c.items.length} من ${c.totalCount}'
                      : '${c.visibleItems.length} نتيجة',
                  style: const TextStyle(fontSize: 12, color: MColors.textMuted),
                )
              : null,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _footer(TransactionManagerController c, bool showList) {
    if (!showList) return const SizedBox.shrink();
    if (c.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: MColors.primary, strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (c.hasNext) {
      return Center(
        child: TextButton(
          onPressed: c.loadMore,
          child: const Text('تحميل المزيد', style: TextStyle(color: MColors.primary)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
