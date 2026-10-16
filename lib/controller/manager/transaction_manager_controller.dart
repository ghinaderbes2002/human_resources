// transaction_manager_controller.dart
// إدارة حالة شاشة "معاملات الموظفين" للمدراء
import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/manager/transaction_manager_service.dart';
import 'package:human_resources/core/services/user_session.dart';
import 'package:human_resources/model/manager/transaction_models.dart';

class TransactionManagerController extends GetxController {
  final TransactionManagerService _service = TransactionManagerService.instance;

  static const int perPage = 100;

  UserSession? session;

  // ---------------- كل المعاملات ----------------
  Staterequest listState = Staterequest.none;
  String listError = '';
  final List<TransactionItem> items = [];
  int _page = 1;
  bool hasNext = false;
  bool loadingMore = false;
  int totalCount = 0;

  /// null = الكل
  String? typeFilter;
  String? statusFilter;
  String search = '';

  // ---------------- بانتظار موافقتي ----------------
  Staterequest pendingState = Staterequest.none;
  String pendingError = '';
  final List<PendingApprovalItem> pending = [];
  final Set<int> _pendingIds = {};

  // ---------------- الإحصائيات ----------------
  TransactionStatistics? statistics;

  // ---------------- الموظفون (للإنشاء) ----------------
  Staterequest employeesState = Staterequest.none;
  String employeesError = '';
  List<TxEmployeeOption> employees = [];

  /// أثناء تنفيذ إجراء (موافقة/رفض/حذف/إنشاء)
  bool busy = false;

  int _listRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    session = await UserSession.load();
    update();
    await refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadTransactions(),
      loadPending(),
      loadStatistics(),
    ]);
  }

  // ============================ القائمة ============================

  Future<void> loadTransactions() async {
    final reqId = ++_listRequestId;
    listState = Staterequest.loading;
    listError = '';
    update();

    final res = await _service.fetchTransactions(
      page: 1,
      perPage: perPage,
      status: statusFilter,
      type: typeFilter,
    );
    if (reqId != _listRequestId) return; // طلب أحدث قيد التنفيذ

    if (res.ok) {
      items
        ..clear()
        ..addAll(res.data!.items);
      _page = res.data!.pagination.page;
      hasNext = res.data!.pagination.hasNext;
      totalCount = res.data!.pagination.total;
      listState = items.isEmpty ? Staterequest.empty : Staterequest.success;
    } else {
      items.clear();
      hasNext = false;
      listError = res.error!;
      listState = Staterequest.failure;
    }
    update();
  }

  Future<void> loadMore() async {
    if (!hasNext || loadingMore || listState == Staterequest.loading) return;
    final reqId = _listRequestId;
    loadingMore = true;
    update();

    final res = await _service.fetchTransactions(
      page: _page + 1,
      perPage: perPage,
      status: statusFilter,
      type: typeFilter,
    );
    if (reqId != _listRequestId) {
      loadingMore = false;
      return;
    }
    if (res.ok) {
      final known = items.map((e) => e.id).toSet();
      items.addAll(res.data!.items.where((e) => !known.contains(e.id)));
      _page = res.data!.pagination.page;
      hasNext = res.data!.pagination.hasNext;
      totalCount = res.data!.pagination.total;
    } else {
      hasNext = false;
    }
    loadingMore = false;
    update();
  }

  void setTypeFilter(String? type) {
    if (typeFilter == type) return;
    typeFilter = type;
    loadTransactions();
  }

  void setStatusFilter(String? status) {
    if (statusFilter == status) return;
    statusFilter = status;
    loadTransactions();
  }

  void setSearch(String q) {
    search = q.trim();
    update();
  }

  /// بحث محلي بالاسم أو رقم المعاملة أو رقم البصمة
  List<TransactionItem> get visibleItems {
    if (search.isEmpty) return items;
    final q = search.toLowerCase();
    return items.where((t) {
      return t.employee.fullName.toLowerCase().contains(q) ||
          t.transactionNumber.toLowerCase().contains(q) ||
          (t.employee.fingerprintId ?? '').toLowerCase().contains(q);
    }).toList();
  }

  // ============================ بانتظار موافقتي ============================

  Future<void> loadPending() async {
    pendingState = Staterequest.loading;
    pendingError = '';
    update();
    final res = await _service.fetchPendingApprovals();
    pending.clear();
    _pendingIds.clear();
    if (res.ok) {
      pending.addAll(res.data!);
      _pendingIds.addAll(pending.map((p) => p.transaction.id));
      pendingState = pending.isEmpty ? Staterequest.empty : Staterequest.success;
    } else {
      pendingError = res.error!;
      pendingState = Staterequest.failure;
    }
    update();
  }

  int get pendingCount =>
      pendingState == Staterequest.failure || pendingState == Staterequest.none
          ? (statistics?.myPendingApprovals ?? 0)
          : pending.length;

  bool isAwaitingMe(int transactionId) => _pendingIds.contains(transactionId);

  // ============================ الإحصائيات ============================

  Future<void> loadStatistics() async {
    final res = await _service.fetchStatistics();
    if (res.ok) statistics = res.data;
    update();
  }

  TxStatBlock? get currentStats => statistics?.forType(typeFilter);

  // ============================ الصلاحيات ============================

  /// رأيي على المعاملة: pending / approved / rejected، أو null إن لم أكن من الموافقين
  String? myVote(TransactionDetail d) {
    if (d.myApprovalStatus != null) return d.myApprovalStatus;
    final uid = session?.userId;
    if (uid != null) {
      // سجل موافقتي في التفاصيل هو الأدق (قد تكون قائمة الانتظار قديمة)
      final mine = d.approvals.where((a) => a.approver.id == uid);
      if (mine.isNotEmpty) return mine.first.status;
    }
    return isAwaitingMe(d.id) ? 'pending' : null;
  }

  /// يمكن إبداء الرأي أو تغييره طالما المعاملة معلّقة:
  /// الموافقة متاحة لمن لم يوافق بعد (لم يُبدِ رأيه أو رفض سابقاً)
  bool canApprove(TransactionDetail d) {
    if (d.status != 'pending') return false;
    final v = myVote(d);
    return v == 'pending' || v == 'rejected';
  }

  /// الرفض متاح لمن لم يرفض بعد (لم يُبدِ رأيه أو وافق سابقاً)
  bool canReject(TransactionDetail d) {
    if (d.status != 'pending') return false;
    final v = myVote(d);
    return v == 'pending' || v == 'approved';
  }

  bool canAct(TransactionDetail d) => canApprove(d) || canReject(d);

  bool canDelete({required String status, int? requesterId}) {
    if (status == 'approved') return false;
    final s = session;
    if (s == null) return false;
    return s.isSuperAdmin || (requesterId != null && requesterId == s.userId);
  }

  // ============================ الإجراءات ============================

  Future<TxResult<TransactionDetail>> fetchDetail(int id) => _service.fetchDetail(id);

  Future<TxResult<bool>> approve(int id, {String? notes}) =>
      _runAction(() => _service.approve(id, notes: notes), handledId: id);

  Future<TxResult<bool>> reject(int id, String notes) =>
      _runAction(() => _service.reject(id, notes), handledId: id);

  Future<TxResult<bool>> delete(int id) =>
      _runAction(() => _service.delete(id), handledId: id);

  Future<TxResult<bool>> create(Map<String, dynamic> body) =>
      _runAction(() => _service.create(body));

  Future<TxResult<bool>> _runAction(
    Future<TxResult<bool>> Function() action, {
    int? handledId,
  }) async {
    if (busy) return TxResult.failure('يرجى الانتظار حتى اكتمال العملية الحالية');
    busy = true;
    update();
    final res = await action();
    busy = false;
    if (res.ok && handledId != null) {
      // إزالة فورية من قائمة الانتظار حتى يكتمل التحديث
      _pendingIds.remove(handledId);
      pending.removeWhere((p) => p.transaction.id == handledId);
      if (pendingState == Staterequest.success && pending.isEmpty) {
        pendingState = Staterequest.empty;
      }
    }
    update();
    if (res.ok) refreshAll();
    return res;
  }

  // ============================ الموظفون ============================

  Future<void> loadEmployees({bool force = false}) async {
    if (!force && employeesState == Staterequest.success && employees.isNotEmpty) return;
    employeesState = Staterequest.loading;
    employeesError = '';
    update();
    final res = await _service.fetchEmployees();
    if (res.ok) {
      employees = res.data!;
      employeesState = employees.isEmpty ? Staterequest.empty : Staterequest.success;
    } else {
      employeesError = res.error!;
      employeesState = Staterequest.failure;
    }
    update();
  }
}
