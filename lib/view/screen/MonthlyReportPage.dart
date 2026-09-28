import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/report_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/model/EmployeeMonthlyReportModel.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  final AttendanceController controller = Get.put(AttendanceController());

  String selectedMonth = "يناير";
  int selectedYear = DateTime.now().year;

  final List<String> months = [
    "يناير",
    "فبراير",
    "مارس",
    "أبريل",
    "مايو",
    "يونيو",
    "يوليو",
    "أغسطس",
    "سبتمبر",
    "أكتوبر",
    "نوفمبر",
    "ديسمبر",
  ];

  late final List<int> years;
  bool isReportRequested = false;

  @override
  void initState() {
    super.initState();
    years = List.generate(10, (index) => DateTime.now().year - 5 + index);
  }

  void _fetchReport() {
    final monthMap = {
      "يناير": 1,
      "فبراير": 2,
      "مارس": 3,
      "أبريل": 4,
      "مايو": 5,
      "يونيو": 6,
      "يوليو": 7,
      "أغسطس": 8,
      "سبتمبر": 9,
      "أكتوبر": 10,
      "نوفمبر": 11,
      "ديسمبر": 12,
    };

    final month = monthMap[selectedMonth] ?? 1;
    final startDate = DateTime(selectedYear, month, 1);
    final endDate = DateTime(selectedYear, month + 1, 0);

    final startDateStr =
        "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    final endDateStr =
        "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    setState(() {
      isReportRequested = true;
    });

    controller.fetchEmployeeMonthlyReport(
      startDateParam: startDateStr,
      endDateParam: endDateStr,
    );
  }
Color getStatusColor(String status) {
  final s = status.trim();
  if (s.contains("حاضر")) return const Color(0xFF10B981); // أخضر
  if (s.contains("غائب") || s.contains("غياب")) return const Color(0xFFEF4444); // أحمر
  if (s.contains("تأخير") || s.contains("متأخر")) return const Color(0xFFF59E0B); // أصفر
  if (s.contains("إجازة")) return const Color(0xFF6366F1); // أزرق
  return const Color(0xFF9CA3AF); // رمادي افتراضي
}

IconData getStatusIcon(String status) {
  final s = status.trim();
  if (s.contains("حاضر")) return Icons.check_circle_rounded;
  if (s.contains("غائب") || s.contains("غياب")) return Icons.cancel_rounded;
  if (s.contains("تأخير") || s.contains("متأخر")) return Icons.schedule_rounded;
  if (s.contains("إجازة")) return Icons.event_rounded;
  return Icons.help_rounded;
}


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "التقرير الشهري",
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.shade200,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        body: GetBuilder<AttendanceController>(
          builder: (controller) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اختيار الفترة
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE85D4A),
                                      Color(0xFFFF7A6B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.date_range_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "اختر الفترة",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  label: "الشهر",
                                  value: selectedMonth,
                                  items: months,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMonth = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdownField(
                                  label: "السنة",
                                  value: selectedYear,
                                  items: years,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedYear = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _fetchReport,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE85D4A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "عرض التقرير",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // عرض التقرير بعد الطلب
                    // عرض التقرير بعد الطلب
                    if (isReportRequested) ...[
                      if (controller.staterequest == Staterequest.loading) ...[
                        const SizedBox(height: 40),
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE85D4A),
                            strokeWidth: 3,
                          ),
                        ),
                      ] else if (controller.staterequest ==
                              Staterequest.failure ||
                          controller.monthlyReport == null) ...[
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.error_outline_rounded,
                                  size: 40,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "فشل تحميل البيانات",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Builder(
                          builder: (_) {
                            final report = controller.monthlyReport!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),

                                // ملخص الشهر
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFE85D4A),
                                            Color(0xFFFF7A6B),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "ملخص الشهر",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

// نسبة الحضور الرئيسية
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE85D4A),
                                        Color(0xFFFF7A6B),
                                      ],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE85D4A).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.trending_up_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "نسبة الحضور",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${report.attendancePercentage.toStringAsFixed(1)}%",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // إحصائيات الأيام
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.5,
                                  children: [
                                    _buildStatCard(
                                      title: "أيام الحضور",
                                      value: report.actualWorkingDays,
                                      icon: Icons.check_circle_rounded,
                                      color: const Color(0xFF10B981),
                                    ),
                                    _buildStatCard(
                                      title: "أيام الغياب",
                                      value: report.absentDays,
                                      icon: Icons.cancel_rounded,
                                      color: const Color(0xFFEF4444),
                                    ),
                                    _buildStatCard(
                                      title: "أيام التأخير",
                                      value: report.lateDays,
                                      icon: Icons.schedule_rounded,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                    _buildStatCard(
                                      title: "أيام الإجازة",
                                      value: report.vacationDays,
                                      icon: Icons.event_rounded,
                                      color: const Color(0xFF6366F1),
                                    ),
                                    _buildStatCard(
                                      title: "العمل بأيام الإجازة",
                                      value: report.holidayWorkDays,
                                      icon: Icons.work_history_rounded,
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                    _buildStatCard(
                                      title: "أيام الانصراف المبكر",
                                      value: report.earlyLeaveDays,
                                      icon: Icons.exit_to_app_rounded,
                                      color: const Color(0xFFEC4899),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // إحصائيات الساعات
                                _buildSectionTitle("إحصائيات الساعات"),
                                const SizedBox(height: 12),

                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.3,
                                  children: [
                                    _buildHoursCard(
                                      title: "الساعات المطلوبة",
                                      hours: report.requiredWorkHours,
                                      icon: Icons.calendar_today_rounded,
                                      color: const Color(0xFF3B82F6),
                                    ),
                                    _buildHoursCard(
                                      title: "الساعات الفعلية",
                                      hours: report.totalActualWorkHours,
                                      icon: Icons.access_time_filled_rounded,
                                      color: const Color(0xFF10B981),
                                    ),
                                    _buildHoursCard(
                                      title: "إجمالي ساعات التأخير",
                                      hours: report.totalLateHours,
                                      icon: Icons.timer_off_rounded,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                    _buildHoursCard(
                                      title: "ساعات الانصراف المبكر",
                                      hours: report.totalEarlyLeaveHours,
                                      icon: Icons.logout_rounded,
                                      color: const Color(0xFFEC4899),
                                    ),
                                    _buildHoursCard(
                                      title: "إجمالي ساعات الإضافي",
                                      hours: report.totalOvertimeHours,
                                      icon: Icons.add_circle_rounded,
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                    _buildHoursCard(
                                      title: "صافي التأخير",
                                      hours: report.netLate,
                                      icon: Icons.remove_circle_rounded,
                                      color: const Color(0xFFEF4444),
                                      isNegative: true,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // صافي الإضافي (بارز)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: report.netOvertime >= 0
                                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                        : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (report.netOvertime >= 0
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444)).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          report.netOvertime >= 0
                                            ? Icons.trending_up_rounded
                                            : Icons.trending_down_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "صافي الإضافي",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatHours(report.netOvertime.abs()),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // التفاصيل اليومية
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFE85D4A),
                                            Color(0xFFFF7A6B),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "التفاصيل اليومية",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                _buildDailyDetails(report),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF6B7280),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE85D4A),
                Color(0xFFFF7A6B),
              ],
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

  Widget _buildHoursCard({
    required String title,
    required double hours,
    required IconData icon,
    required Color color,
    bool isNegative = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatHours(hours),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatHours(double hours) {
    final int h = hours.floor();
    final int m = ((hours - h) * 60).round();
    return "${h}ساعة ${m}دقيقة";
  }

  Widget _buildDailyDetails(EmployeeMonthlyReportModel report) {
    final data = report.attendanceList;

    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "لا توجد بيانات لهذه الفترة",
            style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    // 🟢 دالة مساعدة لتنسيق الوقت (ساعات ودقايق فقط)
    String formatTime(String time) {
      if (time == "-" || time.isEmpty) return "-";
      final parts = time.split(":");
      if (parts.length >= 2) {
        return "${parts[0]}:${parts[1]}";
      }
      return time;
    }

    // 🟢 دالة لتحويل hours العشرية لصيغة HH:MM
    String formatHours(double hours) {
      final int h = hours.floor();
      final int m = ((hours - h) * 60).round();
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "التاريخ",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "الحالة",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "الأوقات",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Data
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final item = data[index];
              final statusColor = getStatusColor(item.status);
              final statusIcon = getStatusIcon(item.status);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.date,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              item.status,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (item.inTime != "-" && item.outTime != "-") ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  size: 14,
                                  color: Colors.green, // أخضر للدخول
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formatTime(item.inTime),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.logout_rounded,
                                  size: 14,
                                  color: Colors.red, // أحمر للخروج
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formatTime(item.outTime),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${formatHours(item.hours)} ساعة",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else
                            const Text(
                              "-",
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
