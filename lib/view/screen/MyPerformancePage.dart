import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/performance_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/model/MyPerformanceModel.dart';

const _arabicMonths = [
  "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
  "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر",
];

const _gradeLabels = {
  'excellent': 'ممتاز',
  'good': 'جيد',
  'average': 'متوسط',
  'poor': 'ضعيف',
  'not_evaluated': 'لم يقيّم',
};

Color _gradeColor(String? grade) {
  switch (grade) {
    case 'excellent':
      return const Color(0xFF10B981);
    case 'good':
      return const Color(0xFF3B82F6);
    case 'average':
      return const Color(0xFFF59E0B);
    case 'poor':
      return const Color(0xFFEF4444);
    default:
      return const Color(0xFF9CA3AF);
  }
}

/// لون النسبة حسب عتبات التقييم المعرّفة في النظام
Color _percentColor(double pct, MyPerformanceModel p) {
  final t = p.thresholds;
  if (pct >= t['excellent']!) return _gradeColor('excellent');
  if (pct >= t['good']!) return _gradeColor('good');
  if (pct >= t['average']!) return _gradeColor('average');
  return _gradeColor('poor');
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

class MyPerformancePage extends StatelessWidget {
  const MyPerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PerformanceController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            "تقييمي",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        ),
        body: GetBuilder<PerformanceController>(
          builder: (ctrl) {
            return RefreshIndicator(
              color: const Color(0xFFE85D4A),
              onRefresh: ctrl.fetchPerformance,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(20),
                children: [
                  _buildMonthSelector(ctrl),
                  const SizedBox(height: 20),
                  ..._buildBody(ctrl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────── اختيار الشهر ───────────────────────────
  Widget _buildMonthSelector(PerformanceController ctrl) {
    final loading = ctrl.staterequest == Staterequest.loading;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          IconButton(
            onPressed: loading ? null : ctrl.previousMonth,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: "الشهر السابق",
          ),
          Expanded(
            child: Text(
              "${_arabicMonths[ctrl.selectedMonth - 1]} ${ctrl.selectedYear}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          IconButton(
            onPressed: loading || ctrl.isCurrentMonth ? null : ctrl.nextMonth,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: "الشهر التالي",
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(PerformanceController ctrl) {
    if (ctrl.staterequest == Staterequest.loading ||
        ctrl.staterequest == Staterequest.none) {
      return const [
        Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE85D4A),
              strokeWidth: 3,
            ),
          ),
        ),
      ];
    }

    if (ctrl.staterequest == Staterequest.failure || ctrl.performance == null) {
      return [
        _buildMessage(
          icon: Icons.cloud_off_rounded,
          message: ctrl.errorMessage ?? "فشل تحميل البيانات",
          color: const Color(0xFFEF4444),
          onRetry: ctrl.fetchPerformance,
        ),
      ];
    }

    final p = ctrl.performance!;

    if (!p.enabled) {
      return [
        _buildMessage(
          icon: Icons.lock_outline_rounded,
          message: p.message ?? "عرض نتائج التقييم غير متاح حالياً",
          color: const Color(0xFF6B7280),
        ),
      ];
    }

    if (p.summary == null && p.days.isEmpty) {
      return [
        _buildMessage(
          icon: Icons.assignment_outlined,
          message: "لا يوجد تقييم لهذا الشهر",
          color: const Color(0xFF9CA3AF),
        ),
        if (p.trend.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionTitle("أداؤك في الأشهر السابقة"),
          const SizedBox(height: 12),
          _buildTrend(p),
        ],
      ];
    }

    return [
      if (p.summary != null) _buildSummaryCard(p),
      if (p.summary?.managerComment?.trim().isNotEmpty == true) ...[
        const SizedBox(height: 16),
        _buildManagerComment(p.summary!.managerComment!),
      ],
      if (p.criteria.isNotEmpty) ...[
        const SizedBox(height: 24),
        _buildSectionTitle("أداؤك حسب المعايير"),
        const SizedBox(height: 12),
        _buildCriteria(p),
      ],
      if (p.trend.length > 1) ...[
        const SizedBox(height: 24),
        _buildSectionTitle("أداؤك في الأشهر الأخيرة"),
        const SizedBox(height: 12),
        _buildTrend(p),
      ],
      if (p.days.isNotEmpty) ...[
        const SizedBox(height: 24),
        _buildSectionTitle("التقييمات اليومية"),
        const SizedBox(height: 12),
        ...p.days.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildDayCard(d, p),
            )),
      ],
    ];
  }

  // ─────────────────────────── بطاقة النتيجة ───────────────────────────
  Widget _buildSummaryCard(MyPerformanceModel p) {
    final s = p.summary!;
    final color = _gradeColor(s.performanceGrade);
    final pct = s.monthlyPercentage.clamp(0, 100) / 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: pct.toDouble(),
                      strokeWidth: 9,
                      backgroundColor: const Color(0xFFE5E7EB),
                      color: color,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        "${_fmt(s.monthlyPercentage)}%",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "تقييمك لهذا الشهر",
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _gradeLabels[s.performanceGrade] ?? "لم يقيّم",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusChip(s.isFinalized),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStat(
                "أيام مقيّمة",
                "${s.evaluatedDays} / ${s.totalAttendedDays}",
              ),
              _buildStat(
                "مجموع الدرجات",
                "${_fmt(s.totalScore)} / ${_fmt(s.maxPossibleScore)}",
              ),
            ],
          ),
          if (p.templateName != null) ...[
            const SizedBox(height: 12),
            Text(
              "نموذج التقييم: ${p.templateName}",
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool finalized) {
    final color =
        finalized ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            finalized ? Icons.verified_rounded : Icons.hourglass_top_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            finalized ? "معتمد" : "قيد التقييم",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── ملاحظة المدير ───────────────────────────
  Widget _buildManagerComment(String comment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded,
              color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ملاحظة المدير",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── المعايير ───────────────────────────
  Widget _buildCriteria(MyPerformanceModel p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: p.criteria.map((c) {
          final color = _percentColor(c.avgPercentage, p);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                    Text(
                      "${_fmt(c.avgPercentage)}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (c.avgPercentage.clamp(0, 100) / 100).toDouble(),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E7EB),
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────── الاتجاه الشهري ───────────────────────────
  Widget _buildTrend(MyPerformanceModel p) {
    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: p.trend.map((t) {
          final color = _gradeColor(t.grade);
          final isSelected = t.year == p.year && t.month == p.month;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${_fmt(t.percentage)}%",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 22,
                  height: 90 * (t.percentage.clamp(2, 100) / 100),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _arabicMonths[t.month - 1],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────── التقييم اليومي ───────────────────────────
  Widget _buildDayCard(DailyEvaluation d, MyPerformanceModel p) {
    final color = _percentColor(d.dailyPercentage, p);
    return Container(
      decoration: _cardDecoration(),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${_fmt(d.dailyPercentage)}%",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          title: Text(
            d.date,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          subtitle: Text(
            "${_fmt(d.totalScore)} من ${_fmt(d.maxPossibleScore)}",
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          children: [
            ...d.scores.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.criterionName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          Text(
                            "${_fmt(s.score)} / ${_fmt(s.maxScore)}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      if (s.notes?.trim().isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            s.notes!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
            if (d.notes?.trim().isNotEmpty == true) ...[
              const Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      d.notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── عناصر مشتركة ───────────────────────────
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
    required Color color,
    VoidCallback? onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, size: 56, color: color),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE85D4A)),
              label: const Text(
                "إعادة المحاولة",
                style: TextStyle(color: Color(0xFFE85D4A)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
