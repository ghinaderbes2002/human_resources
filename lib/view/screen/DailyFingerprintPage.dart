import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/fingerprint_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';

class DailyFingerprintPage extends StatefulWidget {
  const DailyFingerprintPage({super.key});

  @override
  State<DailyFingerprintPage> createState() => _DailyFingerprintPageState();
}

class _DailyFingerprintPageState extends State<DailyFingerprintPage> {
  final FingerprintController controller = Get.put(FingerprintController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await controller.loadEmployeeId();
    await controller.fetchTodayAttendance();
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${days[now.weekday % 7]}، ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "البصمة اليومية",
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
      body: GetBuilder<FingerprintController>(
        builder: (ctrl) {
          if (ctrl.staterequest == Staterequest.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE85D4A),
                strokeWidth: 3,
              ),
            );
          }

          final hasCheckedIn = ctrl.todayAttendance?.hasAttendance != null;
          final hasCheckedOut =
              ctrl.todayAttendance?.hasAttendance?.checkOutTime != null;

          return RefreshIndicator(
            color: const Color(0xFFE85D4A),
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // التاريخ والوقت
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE85D4A).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fingerprint_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getCurrentDate(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getCurrentTime(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // زر تسجيل الدخول إذا لم يتم الحضور
                  if (!hasCheckedIn && ctrl.empId != null)
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () async {
                          await ctrl.checkIn(ctrl.empId!);
                          await ctrl.fetchTodayAttendance();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),

                          ),
                        ),
                      child: const Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white, // اللون الأبيض
                          ),
                        ),

                      ),
                    ),

                  // زر تسجيل الخروج إذا سجل الدخول ولم يسجل الخروج بعد
                  if (hasCheckedIn && !hasCheckedOut && ctrl.empId != null)
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () async {
                          await ctrl.checkOut(ctrl.empId!);
                          await ctrl.fetchTodayAttendance();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "تسجيل الخروج",
                          style: TextStyle(fontSize: 20,
                              color: Colors.white, // اللون الأبيض
),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // عنوان سجل اليوم
                  Row(
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
                      const Text(
                        "سجل حضور اليوم",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // سجل اليوم (الدخول والخروج)
                  if (hasCheckedIn)
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.login_rounded,
                                color: Color(0xFF10B981),
                                size: 20,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "الدخول",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ctrl
                                        .todayAttendance!
                                        .hasAttendance!
                                        .checkInTime ??
                                    '--',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade200,
                          ),
                          Column(
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "الخروج",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ctrl
                                        .todayAttendance!
                                        .hasAttendance!
                                        .checkOutTime ??
                                    '--',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
