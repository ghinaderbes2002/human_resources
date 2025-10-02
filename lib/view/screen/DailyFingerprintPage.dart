// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:human_resources/controller/Fingerprint_controller.dart';
// // import 'package:human_resources/core/classes/staterequest.dart';

// // class DailyFingerprintPage extends StatefulWidget {
// //   const DailyFingerprintPage({Key? key}) : super(key: key);

// //   @override
// //   State<DailyFingerprintPage> createState() => _DailyFingerprintPageState();
// // }

// // class _DailyFingerprintPageState extends State<DailyFingerprintPage> {
// //   final FingerprintController controller = Get.put(FingerprintController());
// //   final TextEditingController reasonController = TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     // أول ما الصفحة تتحمل، نجيب حالة اليوم وسجل الحضور
// //     controller.loadEmployeeId().then((_) {
// //       controller.fetchTodayAttendance();
// //       controller.fetchAttendanceHistory();
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     reasonController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("البصمة اليومية"), centerTitle: true),
// //       body: GetBuilder<FingerprintController>(
// //         builder: (controller) {
// //           if (controller.staterequest == Staterequest.loading &&
// //               controller.todayAttendance == null) {
// //             return const Center(child: CircularProgressIndicator());
// //           }

// //           // الموظف مسجل دخول اليوم إذا كان checkInTime موجود
// //           bool isCheckedInToday =
// //               controller.todayAttendance?.checkInTime != null;

// //           return Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               children: [
// //                 // حالة اليوم
// //                 Text(
// //                   isCheckedInToday
// //                       ? "أنت مسجل دخول اليوم: ${controller.todayAttendance?.employeeName ?? 'غير معروف'}"
// //                       : "لم تسجل دخول اليوم",
// //                   style: const TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),

// //                 // حقل السبب
// //                 TextField(
// //                   controller: reasonController,
// //                   decoration: InputDecoration(
// //                     labelText: isCheckedInToday
// //                         ? "سبب تسجيل الخروج"
// //                         : "سبب تسجيل الدخول",
// //                     border: const OutlineInputBorder(),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),

// //                 // زر تسجيل دخول/خروج
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     if (controller.empId == null) {
// //                       Get.snackbar("خطأ", "لم يتم العثور على رقم الموظف");
// //                       return;
// //                     }

// //                     final reason = reasonController.text.trim().isNotEmpty
// //                         ? reasonController.text.trim()
// //                         : (isCheckedInToday ? "انتهاء الدوام" : "دوام");

// //                     if (isCheckedInToday) {
// //                       controller
// //                           .checkOut(controller.empId!, reason: reason)
// //                           .then((_) => controller.fetchTodayAttendance());
// //                     } else {
// //                       controller
// //                           .checkIn(controller.empId!, reason: reason)
// //                           .then((_) => controller.fetchTodayAttendance());
// //                     }

// //                     reasonController.clear();
// //                   },
// //                   child: Text(
// //                     isCheckedInToday ? "تسجيل خروج" : "تسجيل دخول",
// //                     style: const TextStyle(fontSize: 16),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 30),

// //                 // عرض سجل الحضور السابق
// //                 const Text(
// //                   "سجل الحضور السابق:",
// //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 10),
// //                 Expanded(
// //                   child: controller.attendanceHistory.isEmpty
// //                       ? const Center(child: Text("لا يوجد سجل بعد"))
// //                       : ListView.builder(
// //                           itemCount: controller.attendanceHistory.length,
// //                           itemBuilder: (context, index) {
// //                             final item = controller.attendanceHistory[index];
// //                             return Card(
// //                               margin: const EdgeInsets.symmetric(vertical: 5),
// //                               child: ListTile(
// //                                 title: Text(
// //                                   "تاريخ: ${item.date} - حالة: ${item.status}",
// //                                 ),
// //                                 subtitle: Text(
// //                                   "دخول: ${item.checkInTime ?? '--'} (${item.checkInReason ?? '--'})\n"
// //                                   "خروج: ${item.checkOutTime ?? '--'} (${item.checkOutReason ?? '--'})",
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                         ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/fingerprint_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';


// class DailyFingerprintPage extends StatefulWidget {
//   const DailyFingerprintPage({super.key});

//   @override
//   State<DailyFingerprintPage> createState() => _DailyFingerprintPageState();
// }

// class _DailyFingerprintPageState extends State<DailyFingerprintPage> {
//   final FingerprintController controller = Get.put(FingerprintController());

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     await controller.loadEmployeeId();
//     await controller.fetchTodayAttendance();
//   }

//   String _getCurrentDate() {
//     final now = DateTime.now();
//     final days = [
//       'الأحد',
//       'الإثنين',
//       'الثلاثاء',
//       'الأربعاء',
//       'الخميس',
//       'الجمعة',
//       'السبت',
//     ];
//     final months = [
//       'يناير',
//       'فبراير',
//       'مارس',
//       'أبريل',
//       'مايو',
//       'يونيو',
//       'يوليو',
//       'أغسطس',
//       'سبتمبر',
//       'أكتوبر',
//       'نوفمبر',
//       'ديسمبر',
//     ];

//     return '${days[now.weekday % 7]}، ${now.day} ${months[now.month - 1]} ${now.year}';
//   }

//   String _getCurrentTime() {
//     final now = DateTime.now();
//     return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // textDirection: TextDirection.rtl,
//       // child: Scaffold(
//         backgroundColor: const Color(0xFFF8F9FA),
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Colors.white,
//           title: const Text(
//             "البصمة اليومية",
//             style: TextStyle(
//               color: Color(0xFF1A1A1A),
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 0.3,
//             ),
//           ),
//           centerTitle: true,
//           iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(1),
//             child: Container(
//               height: 1,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.transparent,
//                     Colors.grey.shade200,
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         body: GetBuilder<FingerprintController>(
//           builder: (ctrl) {
//             if (ctrl.staterequest == Staterequest.loading) {
//               return const Center(
//                 child: CircularProgressIndicator(
//                   color: Color(0xFFE85D4A),
//                   strokeWidth: 3,
//                 ),
//               );
//             }

//             final hasCheckedIn = ctrl.todayAttendance?.checkInTime != null;
//             final hasCheckedOut = ctrl.todayAttendance?.checkOutTime != null;

//             return RefreshIndicator(
//               color: const Color(0xFFE85D4A),
//               onRefresh: _loadData,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Date & Time Card
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
//                           begin: Alignment.topRight,
//                           end: Alignment.bottomLeft,
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(0xFFE85D4A).withOpacity(0.3),
//                             blurRadius: 20,
//                             offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.fingerprint_rounded,
//                               color: Colors.white,
//                               size: 48,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             _getCurrentDate(),
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.9),
//                               fontSize: 15,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _getCurrentTime(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 36,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Status Section
//                     Row(
//                       children: [
//                         Container(
//                           width: 4,
//                           height: 24,
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                             ),
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Text(
//                           "حالة الحضور اليوم",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF1A1A1A),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Check In/Out Status Cards
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildStatusCard(
//                             title: "الدخول",
//                             time: ctrl.todayAttendance?.checkInTime ?? "---",
//                             icon: Icons.login_rounded,
//                             isActive: hasCheckedIn,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: _buildStatusCard(
//                             title: "الخروج",
//                             time: ctrl.todayAttendance?.checkOutTime ?? "---",
//                             icon: Icons.logout_rounded,
//                             isActive: hasCheckedOut,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 32),

                
//                     // Action Button
//                   if (!hasCheckedOut) ...[
//                     SizedBox(
//                       width: double.infinity,
//                       height: 64,
//                       child: ElevatedButton(
//                         onPressed: ctrl.empId == null
//                             ? null
//                             : () async {
//                                 if (!hasCheckedIn) {
//                                   // تسجيل الدخول
//                                   await controller.checkIn(ctrl.empId!);
//                                 } else {
//                                   // تحقق إذا فعلاً مسجل دخول قبل الخروج
//                                   if (ctrl.todayAttendance?.checkInTime ==
//                                       null) {
//                                     Get.snackbar(
//                                       "تنبيه",
//                                       "يجب تسجيل الدخول أولاً قبل تسجيل الخروج",
//                                     );
//                                     return;
//                                   }
//                                   await controller.checkOut(ctrl.empId!);
//                                 }
//                                 await controller.fetchTodayAttendance();
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: hasCheckedIn
//                               ? const Color(0xFFEF4444) // أحمر للخروج
//                               : const Color(0xFF10B981), // أخضر للدخول
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shadowColor:
//                               (hasCheckedIn
//                                       ? const Color(0xFFEF4444)
//                                       : const Color(0xFF10B981))
//                                   .withOpacity(0.3),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               hasCheckedIn
//                                   ? Icons.logout_rounded
//                                   : Icons.login_rounded,
//                               size: 28,
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               hasCheckedIn ? "تسجيل الخروج" : "تسجيل الدخول",
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ]

                    
//                      else ...[
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFDCFCE7),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: const Color(0xFF86EFAC),
//                             width: 2,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF10B981),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Icon(
//                                 Icons.check_circle_rounded,
//                                 color: Colors.white,
//                                 size: 28,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             const Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "تم إنهاء الدوام",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w700,
//                                       color: Color(0xFF065F46),
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     "لقد سجلت الدخول والخروج اليوم",
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Color(0xFF047857),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],

//                     const SizedBox(height: 32),

//                     // Today Info
//                     if (hasCheckedIn) ...[
//                       Row(
//                         children: [
//                           Container(
//                             width: 4,
//                             height: 24,
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Text(
//                             "معلومات اليوم",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFF1A1A1A),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),

//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               blurRadius: 20,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             _buildInfoRow(
//                               icon: Icons.login_rounded,
//                               label: "وقت الدخول",
//                               value: ctrl.todayAttendance?.checkInTime ?? "---",
//                               color: const Color(0xFF10B981),
//                             ),
//                             const Divider(height: 32),
//                             _buildInfoRow(
//                               icon: Icons.logout_rounded,
//                               label: "وقت الخروج",
//                               value:
//                                   ctrl.todayAttendance?.checkOutTime ?? "---",
//                               color: const Color(0xFFEF4444),
//                             ),
//                             if (ctrl.todayAttendance?.totalHours != null) ...[
//                               const Divider(height: 32),
//                               _buildInfoRow(
//                                 icon: Icons.access_time_rounded,
//                                 label: "إجمالي الساعات",
//                                 value:
//                                     "${ctrl.todayAttendance!.totalHours.toStringAsFixed(2)} ساعة",
//                                 color: const Color(0xFF6366F1),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ],

//                     const SizedBox(height: 24),

//                     // Tips Card
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF7ED),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: const Color(0xFFFED7AA),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFFFEDD5),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(
//                               Icons.lightbulb_rounded,
//                               color: Color(0xFFF59E0B),
//                               size: 20,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Text(
//                               "تذكر تسجيل الدخول عند بدء العمل والخروج عند الانتهاء",
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Color(0xFF92400E),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       // ),
//     );
//   }

//   Widget _buildStatusCard({
//     required String title,
//     required String time,
//     required IconData icon,
//     required bool isActive,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isActive ? const Color(0xFF10B981) : Colors.grey.shade200,
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: isActive
//                   ? const Color(0xFF10B981).withOpacity(0.1)
//                   : Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: isActive ? const Color(0xFF10B981) : Colors.grey.shade400,
//               size: 24,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF6B7280),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             time,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: isActive
//                   ? const Color(0xFF10B981)
//                   : const Color(0xFF9CA3AF),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: Color(0xFF6B7280),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


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
      await controller.fetchAttendanceHistory();

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


          final canCheckIn = ctrl.todayAttendance?.noAttendance != null;
          final canCheckOut = ctrl.todayAttendance?.hasAttendance != null;

          return RefreshIndicator(
            color: const Color(0xFFE85D4A),
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Time Card
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

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: ctrl.empId == null
                          ? null
                          : () async {
                              if (canCheckIn) {
                                await controller.checkIn(ctrl.empId!);
                              } else if (canCheckOut) {
                                await controller.checkOut(ctrl.empId!);
                              }
                              await controller.fetchTodayAttendance();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canCheckIn
                            ? const Color(0xFF10B981) // أخضر للدخول
                            : const Color(0xFFEF4444), // أحمر للخروج
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor:
                            (canCheckIn
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444))
                                .withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            canCheckIn
                                ? Icons.login_rounded
                                : Icons.logout_rounded,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            canCheckIn ? "تسجيل الدخول" : "تسجيل الخروج",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
               
               
                const SizedBox(height: 32),

                  // جدول أو قائمة سجل الحضور
                 // استبدل القسم القديم بهذا الكود
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
                        "سجل الحضور",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ctrl.attendanceHistory.isEmpty
                      ? Container(
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
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.access_time_rounded,
                                    size: 40,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "لا توجد سجلات حضور",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ctrl.attendanceHistory.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final attendance = ctrl.attendanceHistory[index];
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
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.fingerprint_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                attendance.checkInReason ??
                                                    'دوام',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1A1A1A),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              // Text(
                                              //   "تاريخ: ${attendance.date ?? '-'}",
                                              //   style: const TextStyle(
                                              //     fontSize: 13,
                                              //     color: Color(0xFF9CA3AF),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(height: 1),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
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
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                attendance.checkInTime ?? '---',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: Colors.grey.shade200,
                                        ),
                                        Expanded(
                                          child: Column(
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
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                attendance.checkOutTime ??
                                                    '---',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFFEF4444),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // if (attendance.totalHours != null) ...[
                                    //   const SizedBox(height: 12),
                                    //   Container(
                                    //     padding: const EdgeInsets.all(12),
                                    //     decoration: BoxDecoration(
                                    //       color: const Color(0xFFF8F9FA),
                                    //       borderRadius: BorderRadius.circular(
                                    //         10,
                                    //       ),
                                    //     ),
                                    //     child: Row(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.center,
                                    //       children: [
                                    //         const Icon(
                                    //           Icons.access_time_rounded,
                                    //           color: Color(0xFF6366F1),
                                    //           size: 18,
                                    //         ),
                                    //         const SizedBox(width: 8),
                                    //         Text(
                                    //           "إجمالي: ${attendance.totalHours!.toStringAsFixed(2)} ساعة",
                                    //           style: const TextStyle(
                                    //             fontSize: 14,
                                    //             fontWeight: FontWeight.w600,
                                    //             color: Color(0xFF6366F1),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ],
                                  ],
                                ),
                              ),
                            );
                          },
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
