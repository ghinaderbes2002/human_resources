import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:human_resources/core/constant/App_routes.dart';
import 'package:human_resources/core/them/app_colors.dart';
import 'package:human_resources/view/widget/EmployeeInfoCard.dart';
import 'package:human_resources/view/widget/EnhancedDashboardCard.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? employeeName;
  String? employeeId;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeName = prefs.getString('employee_name') ?? "غير معروف";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            "لوحة التحكم",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.3,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 70,
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
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // كارد معلومات الموظف المحدث
                  Container(
                    width: double.infinity,
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
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "مرحباً بك",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  employeeName ?? "جاري التحميل...",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // عنوان الخدمات السريعة
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
                        "الخدمات السريعة",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // شبكة الكروت المحدثة
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.05,
                    children: [
                      _buildModernServiceCard(
                        title: "التقرير الشهري",
                        icon: Icons.bar_chart_rounded,
                        gradientColors: const [
                          Color(0xFF10B981),
                          Color(0xFF34D399),
                        ],
                        onTap: () {
                          Get.toNamed(AppRoute.monthlyReport);
                        },
                      ),
                      _buildModernServiceCard(
                        title: "البصمة اليومية",
                        icon: Icons.fingerprint_rounded,
                        gradientColors: const [
                          Color(0xFFF59E0B),
                          Color(0xFFFBBF24),
                        ],
                        onTap: () {
                          Get.toNamed(AppRoute.dailyFingerprint);
                        },
                      ),
                      _buildModernServiceCard(
                        title: "طلباتي",
                        icon: Icons.assignment_rounded,
                        gradientColors: const [
                          Color(0xFFE85D4A),
                          Color(0xFFFF7A6B),
                        ],
                        onTap: () {
                          Get.toNamed(AppRoute.transactionScreen);
                        },
                      ),
                      _buildModernServiceCard(
                        title: "حسابي",
                        icon: Icons.person_rounded,
                        gradientColors: const [
                          Color(0xFF6366F1),
                          Color(0xFF818CF8),
                        ],
                        onTap: () {
                          Get.toNamed(AppRoute.profile);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // قسم إحصائيات سريعة
                  // Row(
                  //   children: [
                  //     Container(
                  //       width: 4,
                  //       height: 24,
                  //       decoration: BoxDecoration(
                  //         gradient: const LinearGradient(
                  //           colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
                  //           begin: Alignment.topCenter,
                  //           end: Alignment.bottomCenter,
                  //         ),
                  //         borderRadius: BorderRadius.circular(2),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     // const Text(
                  //     //   "الإحصائيات",
                  //     //   style: TextStyle(
                  //     //     fontSize: 20,
                  //     //     fontWeight: FontWeight.w700,
                  //     //     color: Color(0xFF1A1A1A),
                  //     //     letterSpacing: 0.3,
                  //     //   ),
                  //     // ),
                  //   ],
                  // ),
                  const SizedBox(height: 16),

                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildStatCard(
                  //         title: "الحضور",
                  //         value: "24",
                  //         subtitle: "يوم هذا الشهر",
                  //         icon: Icons.check_circle_rounded,
                  //         color: const Color(0xFF10B981),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: _buildStatCard(
                  //         title: "الإجازات",
                  //         value: "3",
                  //         subtitle: "أيام متبقية",
                  //         icon: Icons.event_available_rounded,
                  //         color: const Color(0xFF6366F1),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernServiceCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
