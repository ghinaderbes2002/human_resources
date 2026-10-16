// transaction_models.dart
// نماذج بيانات "معاملات الموظفين" لشاشات الإدارة
import 'package:flutter/material.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

// ============================ ثوابت وأدوات ============================

class TxType {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const TxType(this.value, this.label, this.icon, this.color);
}

class TxConst {
  static const types = <TxType>[
    TxType('advance', 'سلفة', Icons.account_balance_wallet_rounded, MColors.info),
    TxType('reward', 'مكافأة', Icons.card_giftcard_rounded, MColors.success),
    TxType('penalty', 'جزاء', Icons.gavel_rounded, MColors.danger),
    TxType('hourly_leave', 'إجازة ساعية', Icons.schedule_rounded, MColors.warning),
    TxType('daily_leave', 'إجازة يومية', Icons.event_available_rounded, Color(0xFF8B5CF6)),
  ];

  static const moneyTypes = ['advance', 'reward', 'penalty'];
  static const leaveTypes = ['hourly_leave', 'daily_leave'];

  static TxType type(String? v) => types.firstWhere(
        (t) => t.value == v,
        orElse: () => TxType(v ?? '-', v ?? '-', Icons.description_outlined, MColors.textMuted),
      );

  static String statusLabel(String? s) {
    switch (s) {
      case 'pending':
        return 'معلقة';
      case 'approved':
        return 'موافق عليها';
      case 'rejected':
        return 'مرفوضة';
      default:
        return s ?? '-';
    }
  }

  static Color statusColor(String? s) {
    switch (s) {
      case 'pending':
        return MColors.warning;
      case 'approved':
        return MColors.success;
      case 'rejected':
        return MColors.danger;
      default:
        return MColors.info;
    }
  }

  static IconData statusIcon(String? s) {
    switch (s) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  /// حالة موافقة فرد (approval row)
  static String approvalStatusLabel(String? s) {
    switch (s) {
      case 'pending':
        return 'بالانتظار';
      case 'approved':
        return 'وافق';
      case 'rejected':
        return 'رفض';
      default:
        return s ?? '-';
    }
  }

  static String roleLabel(String? userType) {
    switch (userType) {
      case 'super_admin':
      case 'dev':
        return 'مدير النظام';
      case 'branch_head':
        return 'رئيس فرع';
      case 'branch_deputy':
        return 'نائب رئيس فرع';
      case 'department_head':
        return 'رئيس قسم';
      case 'department_deputy':
        return 'نائب رئيس قسم';
      case 'employee':
        return 'موظف';
      default:
        return userType ?? '-';
    }
  }
}

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty || s == 'None' || s == 'null') return null;
  return s;
}

const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

/// تحويل مرن لتاريخ: 'YYYY-MM-DD' أو ISO أو 'Tue, 01 Jul 2025 00:00:00 GMT'
DateTime? txParseDate(dynamic v) {
  final s = _str(v);
  if (s == null) return null;
  final direct = DateTime.tryParse(s);
  if (direct != null) return direct;
  final ymd = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})').firstMatch(s);
  if (ymd != null) {
    return DateTime(int.parse(ymd[1]!), int.parse(ymd[2]!), int.parse(ymd[3]!));
  }
  final dmy = RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})').firstMatch(s);
  if (dmy != null) {
    return DateTime(int.parse(dmy[3]!), int.parse(dmy[2]!), int.parse(dmy[1]!));
  }
  final rfc = RegExp(r'(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})').firstMatch(s);
  if (rfc != null) {
    final m = _months[rfc[2]!.toLowerCase()];
    if (m != null) return DateTime(int.parse(rfc[3]!), m, int.parse(rfc[1]!));
  }
  return null;
}

/// نص تاريخ فقط YYYY-MM-DD
String txDate(dynamic v) {
  final d = txParseDate(v);
  if (d == null) return _str(v) ?? '-';
  return MFormat.date(d);
}

/// نص تاريخ ووقت YYYY-MM-DD HH:mm
String txDateTime(dynamic v) {
  final s = _str(v);
  if (s == null) return '-';
  final d = DateTime.tryParse(s);
  if (d == null) return txDate(s);
  final hasTime = s.contains('T') || s.contains(' ');
  if (!hasTime) return MFormat.date(d);
  return '${MFormat.date(d)}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// وقت HH:mm من 'HH:mm' أو 'HH:mm:ss' أو ISO
String? txTime(dynamic v) {
  final s = _str(v);
  if (s == null) return null;
  if (s.contains('T')) {
    final d = DateTime.tryParse(s);
    if (d != null) {
      final l = d.isUtc ? d.toLocal() : d;
      return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
    }
  }
  return MFormat.time(s);
}

String _numText(double? v) {
  if (v == null) return '-';
  return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

// ============================ التفاصيل ============================

class TxDetails {
  // سلفة / مكافأة / جزاء
  final double? amount;
  final String? documentNumber;
  final String? date;
  final String? notes;
  // إجازة ساعية
  final String? leaveDate;
  final int? hours;
  final String? startTime;
  final String? endTime;
  // إجازة يومية
  final String? startDate;
  final int? days;
  final String? endDate;
  // مشترك للإجازات
  final String? reason;

  TxDetails({
    this.amount,
    this.documentNumber,
    this.date,
    this.notes,
    this.leaveDate,
    this.hours,
    this.startTime,
    this.endTime,
    this.startDate,
    this.days,
    this.endDate,
    this.reason,
  });

  factory TxDetails.fromJson(dynamic j) {
    if (j is! Map) return TxDetails();
    return TxDetails(
      amount: mToDouble(j['amount']),
      documentNumber: _str(j['document_number']),
      date: _str(j['date']),
      notes: _str(j['notes']),
      leaveDate: _str(j['leave_date']),
      hours: mToInt(j['hours']) ?? mToDouble(j['hours'])?.toInt(),
      startTime: _str(j['start_time']),
      endTime: _str(j['end_time']),
      startDate: _str(j['start_date']),
      days: mToInt(j['days']) ?? mToDouble(j['days'])?.toInt(),
      endDate: _str(j['end_date']),
      reason: _str(j['reason']),
    );
  }

  /// ملخص سطر واحد حسب نوع المعاملة
  String summary(String type) {
    switch (type) {
      case 'advance':
      case 'reward':
      case 'penalty':
        return 'المبلغ: ${_numText(amount)} ج.م';
      case 'hourly_leave':
        return 'التاريخ: ${leaveDate != null ? txDate(leaveDate) : 'غير محدد'} - الساعات: ${hours ?? 0}';
      case 'daily_leave':
        return 'من: ${startDate != null ? txDate(startDate) : 'غير محدد'} - الأيام: ${days ?? 0}';
      default:
        return 'لا توجد تفاصيل';
    }
  }

  /// كل الحقول كقائمة (عنوان، قيمة) للعرض في التفاصيل
  List<MapEntry<String, String>> fields(String type) {
    final out = <MapEntry<String, String>>[];
    void add(String k, String? v) {
      if (v != null && v.trim().isNotEmpty) out.add(MapEntry(k, v));
    }

    switch (type) {
      case 'advance':
      case 'reward':
      case 'penalty':
        add('المبلغ', amount != null ? MFormat.money(amount) : null);
        add('رقم المستند', documentNumber);
        add('التاريخ', date != null ? txDate(date) : null);
        add('ملاحظات التفاصيل', notes);
        break;
      case 'hourly_leave':
        add('تاريخ الإجازة', leaveDate != null ? txDate(leaveDate) : null);
        add('عدد الساعات', hours?.toString());
        add('من الساعة', txTime(startTime));
        add('إلى الساعة', txTime(endTime));
        add('السبب', reason);
        break;
      case 'daily_leave':
        add('تاريخ البداية', startDate != null ? txDate(startDate) : null);
        add('عدد الأيام', days?.toString());
        add('تاريخ النهاية', endDate != null ? txDate(endDate) : null);
        add('السبب', reason);
        break;
    }
    return out;
  }
}

// ============================ أشخاص ============================

class TxEmployee {
  final int? id;
  final String fullName;
  final String? fingerprintId;
  final String? department;
  final String? branch;

  TxEmployee({this.id, required this.fullName, this.fingerprintId, this.department, this.branch});

  factory TxEmployee.fromJson(dynamic j) {
    if (j is! Map) return TxEmployee(fullName: '-');
    String? nameOf(dynamic v) => v is Map ? _str(v['name']) : _str(v);
    return TxEmployee(
      id: mToInt(j['id']),
      fullName: _str(j['full_name']) ?? '-',
      fingerprintId: _str(j['fingerprint_id']),
      department: nameOf(j['department']),
      branch: nameOf(j['branch']),
    );
  }
}

class TxUser {
  final int? id;
  final String username;
  final String? userType;
  final String? employeeName;

  TxUser({this.id, required this.username, this.userType, this.employeeName});

  factory TxUser.fromJson(dynamic j) {
    if (j is! Map) return TxUser(username: '-');
    return TxUser(
      id: mToInt(j['id']),
      username: _str(j['username']) ?? '-',
      userType: _str(j['user_type']),
      employeeName: _str(j['employee_name']),
    );
  }

  String get displayName => employeeName ?? username;
  String get roleLabel => TxConst.roleLabel(userType);
}

// ============================ عناصر القائمة ============================

class TxApprovalCounts {
  final int total;
  final int approved;
  final int rejected;
  final int pending;

  TxApprovalCounts({this.total = 0, this.approved = 0, this.rejected = 0, this.pending = 0});

  factory TxApprovalCounts.fromJson(dynamic j) {
    if (j is! Map) return TxApprovalCounts();
    return TxApprovalCounts(
      total: mToInt(j['total']) ?? 0,
      approved: mToInt(j['approved']) ?? 0,
      rejected: mToInt(j['rejected']) ?? 0,
      pending: mToInt(j['pending']) ?? 0,
    );
  }
}

/// معاملة كما تأتي من القائمة (/transactions) أو من pending-approvals
class TransactionItem {
  final int id;
  final String transactionNumber;
  final String type;
  final String status;
  final TxEmployee employee;
  final TxUser requester;
  final TxDetails details;
  final String? notes;
  final String? reasonForRejection;

  /// غير متوفر في pending-approvals
  final TxApprovalCounts? approvals;
  final String? createdAt;
  final String? updatedAt;
  final String? approvedAt;
  final String? rejectedAt;

  TransactionItem({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.status,
    required this.employee,
    required this.requester,
    required this.details,
    this.notes,
    this.reasonForRejection,
    this.approvals,
    this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.rejectedAt,
  });

  factory TransactionItem.fromJson(Map j) {
    return TransactionItem(
      id: mToInt(j['id']) ?? 0,
      transactionNumber: _str(j['transaction_number']) ?? '#${j['id']}',
      type: _str(j['transaction_type']) ?? '-',
      status: _str(j['status']) ?? 'pending',
      employee: TxEmployee.fromJson(j['employee']),
      requester: TxUser.fromJson(j['requester']),
      details: TxDetails.fromJson(j['details']),
      notes: _str(j['notes']),
      reasonForRejection: _str(j['reason_for_rejection']),
      approvals: j['approvals'] is Map ? TxApprovalCounts.fromJson(j['approvals']) : null,
      createdAt: _str(j['created_at']),
      updatedAt: _str(j['updated_at']),
      approvedAt: _str(j['approved_at']),
      rejectedAt: _str(j['rejected_at']),
    );
  }

  TxType get typeInfo => TxConst.type(type);
  String get summary => details.summary(type);
}

class PendingApprovalItem {
  final int? approvalId;
  final TransactionItem transaction;
  final String? createdAt;

  PendingApprovalItem({this.approvalId, required this.transaction, this.createdAt});

  factory PendingApprovalItem.fromJson(Map j) {
    return PendingApprovalItem(
      approvalId: mToInt(j['approval_id']),
      transaction: TransactionItem.fromJson(j['transaction'] is Map ? j['transaction'] as Map : const {}),
      createdAt: _str(j['created_at']),
    );
  }
}

class TxPagination {
  final int page;
  final int pages;
  final int perPage;
  final int total;
  final bool hasNext;

  TxPagination({this.page = 1, this.pages = 1, this.perPage = 100, this.total = 0, this.hasNext = false});

  factory TxPagination.fromJson(dynamic j) {
    if (j is! Map) return TxPagination();
    return TxPagination(
      page: mToInt(j['page']) ?? 1,
      pages: mToInt(j['pages']) ?? 1,
      perPage: mToInt(j['per_page']) ?? 100,
      total: mToInt(j['total']) ?? 0,
      hasNext: j['has_next'] == true,
    );
  }
}

// ============================ التفاصيل الكاملة ============================

class TxApprovalEntry {
  final int? id;
  final TxUser approver;
  final String status;
  final String? notes;
  final String? approvedAt;
  final String? rejectedAt;
  final String? createdAt;

  TxApprovalEntry({
    this.id,
    required this.approver,
    required this.status,
    this.notes,
    this.approvedAt,
    this.rejectedAt,
    this.createdAt,
  });

  factory TxApprovalEntry.fromJson(Map j) {
    return TxApprovalEntry(
      id: mToInt(j['id']),
      approver: TxUser.fromJson(j['approver']),
      status: _str(j['status']) ?? 'pending',
      notes: _str(j['notes']),
      approvedAt: _str(j['approved_at']),
      rejectedAt: _str(j['rejected_at']),
      createdAt: _str(j['created_at']),
    );
  }

  /// تاريخ الإجراء (موافقة/رفض) أو تاريخ الإنشاء
  String? get actionDate => approvedAt ?? rejectedAt;
}

/// معاملة كاملة من GET /transactions/{id}
class TransactionDetail {
  final int id;
  final String transactionNumber;
  final String type;
  final String status;
  final TxEmployee employee;
  final TxUser requester;
  final TxDetails details;
  final String? notes;
  final String? reasonForRejection;
  final List<TxApprovalEntry> approvals;
  final bool canApprove;
  final String? createdAt;
  final String? updatedAt;
  final String? approvedAt;
  final String? rejectedAt;

  TransactionDetail({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.status,
    required this.employee,
    required this.requester,
    required this.details,
    this.notes,
    this.reasonForRejection,
    this.approvals = const [],
    this.canApprove = false,
    this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.rejectedAt,
  });

  factory TransactionDetail.fromJson(Map j) {
    final raw = j['approvals'];
    return TransactionDetail(
      id: mToInt(j['id']) ?? 0,
      transactionNumber: _str(j['transaction_number']) ?? '#${j['id']}',
      type: _str(j['transaction_type']) ?? '-',
      status: _str(j['status']) ?? 'pending',
      employee: TxEmployee.fromJson(j['employee']),
      requester: TxUser.fromJson(j['requester']),
      details: TxDetails.fromJson(j['details']),
      notes: _str(j['notes']),
      reasonForRejection: _str(j['reason_for_rejection']),
      approvals: raw is List
          ? raw.whereType<Map>().map(TxApprovalEntry.fromJson).toList()
          : const [],
      canApprove: j['can_approve'] == true,
      createdAt: _str(j['created_at']),
      updatedAt: _str(j['updated_at']),
      approvedAt: _str(j['approved_at']),
      rejectedAt: _str(j['rejected_at']),
    );
  }

  TxType get typeInfo => TxConst.type(type);
  int get approvedCount => approvals.where((a) => a.status == 'approved').length;
  int get rejectedCount => approvals.where((a) => a.status == 'rejected').length;
  int get pendingCount => approvals.where((a) => a.status == 'pending').length;
}

// ============================ الإحصائيات ============================

class TxStatBlock {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  TxStatBlock({this.total = 0, this.pending = 0, this.approved = 0, this.rejected = 0});

  factory TxStatBlock.fromJson(dynamic j) {
    if (j is! Map) return TxStatBlock();
    return TxStatBlock(
      total: mToInt(j['total']) ?? 0,
      pending: mToInt(j['pending']) ?? 0,
      approved: mToInt(j['approved']) ?? 0,
      rejected: mToInt(j['rejected']) ?? 0,
    );
  }
}

class TransactionStatistics {
  final TxStatBlock overview;
  final Map<String, TxStatBlock> byType;
  final int myPendingApprovals;

  TransactionStatistics({required this.overview, required this.byType, this.myPendingApprovals = 0});

  factory TransactionStatistics.fromJson(Map j) {
    final bt = <String, TxStatBlock>{};
    final raw = j['by_type'];
    if (raw is Map) {
      raw.forEach((k, v) => bt[k.toString()] = TxStatBlock.fromJson(v));
    }
    return TransactionStatistics(
      overview: TxStatBlock.fromJson(j['overview']),
      byType: bt,
      myPendingApprovals: mToInt(j['my_pending_approvals']) ?? 0,
    );
  }

  TxStatBlock forType(String? type) =>
      type == null ? overview : (byType[type] ?? TxStatBlock());
}

// ============================ منتقي الموظف ============================

class TxEmployeeOption {
  final int id;
  final String fullName;
  final String? fingerprintId;

  TxEmployeeOption({required this.id, required this.fullName, this.fingerprintId});

  factory TxEmployeeOption.fromJson(Map j) {
    return TxEmployeeOption(
      id: mToInt(j['id']) ?? 0,
      fullName: _str(j['full_name']) ?? '-',
      fingerprintId: _str(j['fingerprint_id']),
    );
  }
}
