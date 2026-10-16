// transaction_manager_service.dart
// طبقة الوصول إلى نقاط "معاملات الموظفين" (للمدراء)
import 'package:human_resources/core/classes/manager_api.dart';
import 'package:human_resources/model/manager/transaction_models.dart';

/// نتيجة موحّدة: بيانات أو رسالة خطأ
class TxResult<T> {
  final T? data;
  final String? error;
  final String? message;
  final int statusCode;

  TxResult._({this.data, this.error, this.message, this.statusCode = 0});

  factory TxResult.success(T data, {String? message, int statusCode = 200}) =>
      TxResult._(data: data, message: message, statusCode: statusCode);

  factory TxResult.failure(String error, {int statusCode = 0}) =>
      TxResult._(error: error, statusCode: statusCode);

  bool get ok => error == null;
}

class TxPageResult {
  final List<TransactionItem> items;
  final TxPagination pagination;
  TxPageResult(this.items, this.pagination);
}

class TransactionManagerService {
  TransactionManagerService._();
  static final TransactionManagerService instance = TransactionManagerService._();

  final ManagerApi _api = ManagerApi.instance;

  Future<TxResult<TxPageResult>> fetchTransactions({
    int page = 1,
    int perPage = 100,
    String? status,
    String? type,
  }) async {
    final res = await _api.get('/transactions', query: {
      'page': page,
      'per_page': perPage,
      if (status != null && status.isNotEmpty) 'status': status,
      if (type != null && type.isNotEmpty) 'type': type,
    });
    if (!res.ok || res.data is! Map) {
      return TxResult.failure(res.messageOr('فشل تحميل المعاملات'), statusCode: res.statusCode);
    }
    final raw = (res.data as Map)['transactions'];
    final items = raw is List
        ? raw.whereType<Map>().map(TransactionItem.fromJson).toList()
        : <TransactionItem>[];
    return TxResult.success(
      TxPageResult(items, TxPagination.fromJson((res.data as Map)['pagination'])),
    );
  }

  Future<TxResult<List<PendingApprovalItem>>> fetchPendingApprovals() async {
    final res = await _api.get('/transactions/pending-approvals');
    if (!res.ok || res.data is! Map) {
      return TxResult.failure(res.messageOr('فشل تحميل المعاملات بانتظار موافقتك'),
          statusCode: res.statusCode);
    }
    final raw = (res.data as Map)['pending_approvals'];
    final items = raw is List
        ? raw.whereType<Map>().map(PendingApprovalItem.fromJson).toList()
        : <PendingApprovalItem>[];
    return TxResult.success(items);
  }

  Future<TxResult<TransactionStatistics>> fetchStatistics() async {
    final res = await _api.get('/transactions/statistics');
    if (!res.ok || res.data is! Map) {
      return TxResult.failure(res.messageOr('فشل تحميل الإحصائيات'), statusCode: res.statusCode);
    }
    return TxResult.success(TransactionStatistics.fromJson(res.data as Map));
  }

  Future<TxResult<TransactionDetail>> fetchDetail(int id) async {
    final res = await _api.get('/transactions/$id');
    if (!res.ok || res.data is! Map) {
      return TxResult.failure(res.messageOr('فشل تحميل تفاصيل المعاملة'), statusCode: res.statusCode);
    }
    return TxResult.success(TransactionDetail.fromJson(res.data as Map));
  }

  Future<TxResult<bool>> approve(int id, {String? notes}) async {
    final res = await _api.post('/transactions/$id/approve', body: {
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    if (!res.ok) {
      return TxResult.failure(res.messageOr('فشلت الموافقة على المعاملة'), statusCode: res.statusCode);
    }
    final full = res.data is Map && (res.data as Map)['is_fully_approved'] == true;
    return TxResult.success(full, message: res.messageOr('تمت الموافقة'));
  }

  Future<TxResult<bool>> reject(int id, String notes) async {
    final res = await _api.post('/transactions/$id/reject', body: {'notes': notes.trim()});
    if (!res.ok) {
      return TxResult.failure(res.messageOr('فشل رفض المعاملة'), statusCode: res.statusCode);
    }
    return TxResult.success(true, message: res.messageOr('تم رفض المعاملة'));
  }

  Future<TxResult<bool>> delete(int id) async {
    final res = await _api.delete('/transactions/$id');
    if (!res.ok) {
      return TxResult.failure(res.messageOr('فشل حذف المعاملة'), statusCode: res.statusCode);
    }
    return TxResult.success(true, message: res.messageOr('تم حذف المعاملة بنجاح'));
  }

  Future<TxResult<bool>> create(Map<String, dynamic> body) async {
    final res = await _api.post('/transactions', body: body);
    if (!res.ok) {
      return TxResult.failure(res.messageOr('فشل إنشاء المعاملة'), statusCode: res.statusCode);
    }
    return TxResult.success(true, message: res.messageOr('تم إنشاء المعاملة بنجاح'));
  }

  /// الموظفون المتاحون للمستخدم (ضمن نطاقه)
  Future<TxResult<List<TxEmployeeOption>>> fetchEmployees() async {
    final res = await _api.get('/employees/list');
    if (!res.ok) {
      return TxResult.failure(res.messageOr('فشل تحميل الموظفين'), statusCode: res.statusCode);
    }
    dynamic raw = res.data;
    if (raw is Map) raw = raw['employees'] ?? raw['data'];
    final list = raw is List
        ? raw.whereType<Map>().map(TxEmployeeOption.fromJson).where((e) => e.id > 0).toList()
        : <TxEmployeeOption>[];
    list.sort((a, b) => a.fullName.compareTo(b.fullName));
    return TxResult.success(list);
  }
}
