import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:human_resources/core/constant/App_routes.dart';
import 'package:human_resources/core/services/user_session.dart';
import 'package:human_resources/core/services/push_notification_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? employeeName;
  String? employeeId;
  UserSession? session;
  // فتح إشعار أدى لتشغيل التطبيق: مرة واحدة فقط طوال عمر التطبيق
  static bool _initialMessageHandled = false;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
    PushNotificationService.instance.refreshUnreadCount();
    if (!_initialMessageHandled) {
      _initialMessageHandled = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => PushNotificationService.instance.handleInitialMessage(),
      );
    }
  }

  Future<void> _openNotifications() async {
    await Get.toNamed(AppRoute.notifications);
    PushNotificationService.instance.refreshUnreadCount();
  }

  Future<void> _loadEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final s = await UserSession.load();
    setState(() {
      employeeName = prefs.getString('employee_name') ?? "غير معروف";
      session = s;
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                tooltip: "الإشعارات",
                onPressed: _openNotifications,
                icon: ValueListenableBuilder<int>(
                  valueListenable: PushNotificationService.instance.unreadCount,
                  builder: (context, count, _) => Badge(
                    isLabelVisible: count > 0,
                    label: Text(count > 99 ? "99+" : "$count"),
                    backgroundColor: const Color(0xFFE85D4A),
                    child: const Icon(Icons.notifications_rounded, size: 28),
                  ),
                ),
              ),
            ),
          ],
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
                  // كارد معلومات الموظف بدون أيقونة الإشعارات
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
                                if (session?.isManager == true) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      session!.scopeName != null
                                          ? "${session!.roleLabel} - ${session!.scopeName}"
                                          : session!.roleLabel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // تمت إزالة أيقونة الإشعارات
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // عنوان الخدمات السريعة
                  _buildSectionHeader("الخدمات السريعة"),
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
                      // _buildModernServiceCard(
                      //   title: "البصمة اليومية",
                      //   icon: Icons.fingerprint_rounded,
                      //   gradientColors: const [
                      //     Color(0xFFF59E0B),
                      //     Color(0xFFFBBF24),
                      //   ],
                      //   onTap: () {
                      //     Get.toNamed(AppRoute.dailyFingerprint);
                      //   },
                      // ),
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
                        title: "تقييمي",
                        icon: Icons.star_rounded,
                        gradientColors: const [
                          Color(0xFFF59E0B),
                          Color(0xFFFBBF24),
                        ],
                        onTap: () {
                          Get.toNamed(AppRoute.myPerformance);
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

                  // قسم الإدارة: يظهر لرؤساء ونواب الفروع والأقسام فقط
                  if (session?.isManager == true) ...[
                    const SizedBox(height: 32),
                    _buildSectionHeader("لوحة الإدارة"),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.05,
                      children: [
                        _buildModernServiceCard(
                          title: "إدارة الحضور",
                          icon: Icons.how_to_reg_rounded,
                          gradientColors: const [
                            Color(0xFF0EA5E9),
                            Color(0xFF38BDF8),
                          ],
                          onTap: () {
                            Get.toNamed(AppRoute.attendanceManagement);
                          },
                        ),
                        _buildModernServiceCard(
                          title: "إدارة الموظفين",
                          icon: Icons.groups_rounded,
                          gradientColors: const [
                            Color(0xFF8B5CF6),
                            Color(0xFFA78BFA),
                          ],
                          onTap: () {
                            Get.toNamed(AppRoute.employeesManagement);
                          },
                        ),
                        _buildModernServiceCard(
                          title: "معاملات الموظفين",
                          icon: Icons.fact_check_rounded,
                          gradientColors: const [
                            Color(0xFF14B8A6),
                            Color(0xFF2DD4BF),
                          ],
                          onTap: () {
                            Get.toNamed(AppRoute.transactionsManagement);
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.3,
          ),
        ),
      ],
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
}
