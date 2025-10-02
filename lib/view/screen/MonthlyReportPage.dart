// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:human_resources/controller/report_controller.dart';
// // import 'package:human_resources/core/classes/staterequest.dart';
// // import 'package:human_resources/model/EmployeeMonthlyReportModel.dart';

// // class MonthlyReportPage extends StatefulWidget {
// //   const MonthlyReportPage({super.key});

// //   @override
// //   State<MonthlyReportPage> createState() => _MonthlyReportPageState();
// // }

// // class _MonthlyReportPageState extends State<MonthlyReportPage> {
// //   final AttendanceController controller = Get.put(AttendanceController());

// //   String selectedMonth = "يناير 2025";
// //   final List<String> months = [
// //     "يناير 2025",
// //     "فبراير 2025",
// //     "مارس 2025",
// //     "أبريل 2025",
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchReport();
// //   }

// //   void _fetchReport() {
// //     // تحويل الشهر إلى نطاق تاريخي مناسب
// //     final startDate = "2024-09-01";
// //     final endDate = "2024-09-30";

// //     controller.fetchEmployeeMonthlyReport(
// //     );
// //   }

// //   Color getStatusColor(String status) {
// //     switch (status) {
// //       case "حاضر":
// //         return Colors.green;
// //       case "غياب":
// //         return Colors.red;
// //       case "إجازة":
// //         return Colors.orange;
// //       case "تأخير":
// //         return Colors.amber[700]!;
// //       default:
// //         return Colors.grey;
// //     }
// //   }

// //   IconData getStatusIcon(String status) {
// //     switch (status) {
// //       case "حاضر":
// //         return Icons.check_circle;
// //       case "غياب":
// //         return Icons.cancel;
// //       case "إجازة":
// //         return Icons.event;
// //       case "تأخير":
// //         return Icons.schedule;
// //       default:
// //         return Icons.help;
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Directionality(
// //       textDirection: TextDirection.rtl,
// //       child: Scaffold(
// //         backgroundColor: Colors.grey[50],
// //         appBar: AppBar(
// //           title: const Text(
// //             "التقرير الشهري",
// //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
// //           ),
// //           centerTitle: true,
// //           backgroundColor: Colors.blue[600],
// //           foregroundColor: Colors.white,
// //           elevation: 0,
// //           toolbarHeight: 70,
// //         ),
// //         body: GetBuilder<AttendanceController>(
// //           builder: (controller) {
// //             if (controller.staterequest == Staterequest.loading) {
// //               return const Center(child: CircularProgressIndicator());
// //             }

// //             if (controller.staterequest == Staterequest.failure ||
// //                 controller.monthlyReport == null) {
// //               return Center(
// //                 child: Text(
// //                   "فشل جلب البيانات",
// //                   style: TextStyle(color: Colors.red[700], fontSize: 16),
// //                 ),
// //               );
// //             }

// //             final EmployeeMonthlyReportModel report = controller.monthlyReport!;

// //             // إحصائيات
// //             final statistics = {
// //               'حاضر': report.presentCount,
// //               'غياب': report.absentCount,
// //               'تأخير': report.lateCount,
// //               'إجازة': report.vacationCount,
// //             };

// //             final totalHours = report.totalHours;

// //             return SingleChildScrollView(
// //               physics: const BouncingScrollPhysics(),
// //               child: Padding(
// //                 padding: const EdgeInsets.all(20.0),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   children: [
// //                     // اختيار الشهر
// //                     Container(
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(16),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.grey.withOpacity(0.1),
// //                             blurRadius: 8,
// //                             offset: const Offset(0, 2),
// //                           ),
// //                         ],
// //                       ),
// //                       padding: const EdgeInsets.all(20),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             "اختر الفترة",
// //                             style: TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.grey[800],
// //                             ),
// //                           ),
// //                           const SizedBox(height: 12),
// //                           DropdownButtonFormField<String>(
// //                             value: selectedMonth,
// //                             decoration: InputDecoration(
// //                               labelText: "الشهر والسنة",
// //                               prefixIcon: const Icon(Icons.calendar_month),
// //                               border: OutlineInputBorder(
// //                                 borderRadius: BorderRadius.circular(12),
// //                               ),
// //                             ),
// //                             items: months
// //                                 .map(
// //                                   (month) => DropdownMenuItem(
// //                                     value: month,
// //                                     child: Text(month),
// //                                   ),
// //                                 )
// //                                 .toList(),
// //                             onChanged: (value) {
// //                               setState(() {
// //                                 selectedMonth = value!;
// //                                 _fetchReport();
// //                               });
// //                             },
// //                           ),
// //                         ],
// //                       ),
// //                     ),

// //                     const SizedBox(height: 24),

// //                     // ملخص الشهر
// //                     Container(
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(16),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.grey.withOpacity(0.1),
// //                             blurRadius: 8,
// //                             offset: const Offset(0, 2),
// //                           ),
// //                         ],
// //                       ),
// //                       padding: const EdgeInsets.all(20),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             "ملخص الشهر",
// //                             style: TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.grey[800],
// //                             ),
// //                           ),
// //                           const SizedBox(height: 16),

// //                           // شبكة الإحصائيات
// //                           GridView.count(
// //                             shrinkWrap: true,
// //                             physics: const NeverScrollableScrollPhysics(),
// //                             crossAxisCount: 2,
// //                             crossAxisSpacing: 12,
// //                             mainAxisSpacing: 12,
// //                             childAspectRatio: 2.2,
// //                             children: [
// //                               _buildStatCard(
// //                                 "حاضر",
// //                                 statistics['حاضر']!,
// //                                 Colors.green,
// //                                 Icons.check_circle,
// //                               ),
// //                               _buildStatCard(
// //                                 "غياب",
// //                                 statistics['غياب']!,
// //                                 Colors.red,
// //                                 Icons.cancel,
// //                               ),
// //                               _buildStatCard(
// //                                 "تأخير",
// //                                 statistics['تأخير']!,
// //                                 Colors.amber[700]!,
// //                                 Icons.schedule,
// //                               ),
// //                               _buildStatCard(
// //                                 "إجازة",
// //                                 statistics['إجازة']!,
// //                                 Colors.orange,
// //                                 Icons.event,
// //                               ),
// //                             ],
// //                           ),

// //                           const SizedBox(height: 16),

// //                           // إجمالي الساعات
// //                           Container(
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               gradient: LinearGradient(
// //                                 colors: [Colors.blue[600]!, Colors.blue[400]!],
// //                                 begin: Alignment.topLeft,
// //                                 end: Alignment.bottomRight,
// //                               ),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     const Text(
// //                                       "إجمالي ساعات العمل",
// //                                       style: TextStyle(
// //                                         color: Colors.white,
// //                                         fontSize: 14,
// //                                       ),
// //                                     ),
// //                                     Text(
// //                                       "${totalHours.toStringAsFixed(1)} ساعة",
// //                                       style: const TextStyle(
// //                                         color: Colors.white,
// //                                         fontSize: 24,
// //                                         fontWeight: FontWeight.bold,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 const Icon(
// //                                   Icons.access_time,
// //                                   color: Colors.white,
// //                                   size: 32,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),

// //                     const SizedBox(height: 24),

// //                     // التفاصيل اليومية
// //                     _buildDailyDetails(report),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildStatCard(String title, int count, Color color, IconData icon) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: color.withOpacity(0.3)),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: color, size: 20),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Text(
// //                   count.toString(),
// //                   style: TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                     color: color,
// //                   ),
// //                 ),
// //                 Text(
// //                   title,
// //                   style: TextStyle(fontSize: 12, color: Colors.grey[700]),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildDailyDetails(EmployeeMonthlyReportModel report) {
// //     final data = report.attendanceList; // افترض عندك List<AttendanceItem>
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Padding(
// //             padding: EdgeInsets.all(20),
// //             child: Text(
// //               "التفاصيل اليومية",
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //           ),
// //           // عناوين الجدول
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //             decoration: BoxDecoration(
// //               color: Colors.grey[100],
// //               borderRadius: const BorderRadius.only(
// //                 topLeft: Radius.circular(16),
// //                 topRight: Radius.circular(16),
// //               ),
// //             ),
// //             child: const Row(
// //               children: [
// //                 Expanded(
// //                   flex: 2,
// //                   child: Text(
// //                     "التاريخ",
// //                     style: TextStyle(fontWeight: FontWeight.bold),
// //                   ),
// //                 ),
// //                 Expanded(
// //                   flex: 2,
// //                   child: Text(
// //                     "الحالة",
// //                     style: TextStyle(fontWeight: FontWeight.bold),
// //                   ),
// //                 ),
// //                 Expanded(
// //                   flex: 3,
// //                   child: Text(
// //                     "الأوقات",
// //                     style: TextStyle(fontWeight: FontWeight.bold),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           ListView.builder(
// //             shrinkWrap: true,
// //             physics: const NeverScrollableScrollPhysics(),
// //             itemCount: data.length,
// //             itemBuilder: (context, index) {
// //               final item = data[index];
// //               final isLast = index == data.length - 1;
// //               return Container(
// //                 padding: const EdgeInsets.all(20),
// //                 decoration: BoxDecoration(
// //                   border: !isLast
// //                       ? Border(bottom: BorderSide(color: Colors.grey[200]!))
// //                       : null,
// //                   borderRadius: isLast
// //                       ? const BorderRadius.only(
// //                           bottomLeft: Radius.circular(16),
// //                           bottomRight: Radius.circular(16),
// //                         )
// //                       : null,
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       flex: 2,
// //                       child: Text(
// //                         item.date,
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.w600,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       flex: 2,
// //                       child: Row(
// //                         children: [
// //                           Icon(
// //                             getStatusIcon(item.status),
// //                             color: getStatusColor(item.status),
// //                             size: 18,
// //                           ),
// //                           const SizedBox(width: 6),
// //                           Text(
// //                             item.status,
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.w600,
// //                               color: getStatusColor(item.status),
// //                               fontSize: 13,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     Expanded(
// //                       flex: 3,
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.center,
// //                         children: [
// //                           if (item.inTime != "-" && item.outTime != "-") ...[
// //                             Row(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(
// //                                   Icons.login,
// //                                   size: 14,
// //                                   color: Colors.grey[600],
// //                                 ),
// //                                 const SizedBox(width: 4),
// //                                 Text(
// //                                   item.inTime,
// //                                   style: const TextStyle(fontSize: 13),
// //                                 ),
// //                                 const SizedBox(width: 12),
// //                                 Icon(
// //                                   Icons.logout,
// //                                   size: 14,
// //                                   color: Colors.grey[600],
// //                                 ),
// //                                 const SizedBox(width: 4),
// //                                 Text(
// //                                   item.outTime,
// //                                   style: const TextStyle(fontSize: 13),
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 4),
// //                             Text(
// //                               "${item.hours.toStringAsFixed(2)} ساعة",
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.grey[600],
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                           ] else
// //                             Text(
// //                               "-",
// //                               style: TextStyle(color: Colors.grey[500]),
// //                             ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:human_resources/controller/report_controller.dart';
// import 'package:human_resources/core/classes/staterequest.dart';
// import 'package:human_resources/model/EmployeeMonthlyReportModel.dart';

// class MonthlyReportPage extends StatefulWidget {
//   const MonthlyReportPage({super.key});

//   @override
//   State<MonthlyReportPage> createState() => _MonthlyReportPageState();
// }

// class _MonthlyReportPageState extends State<MonthlyReportPage> {
//   final AttendanceController controller = Get.put(AttendanceController());

//   String selectedMonth = "يناير";
//   int selectedYear = DateTime.now().year;

//   final List<String> months = [
//     "يناير",
//     "فبراير",
//     "مارس",
//     "أبريل",
//     "مايو",
//     "يونيو",
//     "يوليو",
//     "أغسطس",
//     "سبتمبر",
//     "أكتوبر",
//     "نوفمبر",
//     "ديسمبر",
//   ];

//   late final List<int> years;

//   @override
//   void initState() {
//     super.initState();
//     // توليد سنوات: 5 سنوات قبل و5 بعد
//     years = List.generate(10, (index) => DateTime.now().year - 5 + index);
//     _fetchReport();
//   }

//   void _fetchReport() {
//     final monthMap = {
//       "يناير": 1,
//       "فبراير": 2,
//       "مارس": 3,
//       "أبريل": 4,
//       "مايو": 5,
//       "يونيو": 6,
//       "يوليو": 7,
//       "أغسطس": 8,
//       "سبتمبر": 9,
//       "أكتوبر": 10,
//       "نوفمبر": 11,
//       "ديسمبر": 12,
//     };

//     final month = monthMap[selectedMonth] ?? 1;
//     final startDate = DateTime(selectedYear, month, 1);
//     final endDate = DateTime(selectedYear, month + 1, 0);

//     final startDateStr =
//         "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
//     final endDateStr =
//         "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

//     controller.fetchEmployeeMonthlyReport(
//       startDateParam: startDateStr,
//       endDateParam: endDateStr,
//     );
//   }

//   String getDayName(String dateStr) {
//     try {
//       final date = DateTime.parse(dateStr);
//       final days = [
//         "الأحد",
//         "الإثنين",
//         "الثلاثاء",
//         "الأربعاء",
//         "الخميس",
//         "الجمعة",
//         "السبت",
//       ];
//       return days[date.weekday % 7];
//     } catch (e) {
//       return "-";
//     }
//   }

//   Color getStatusColor(String status) {
//     final s = status.trim();
//     switch (s) {
//       case "حاضر":
//         return Colors.green;
//       case "غائب":
//       case "غياب":
//         return Colors.red;
//       case "تأخير":
//         return Colors.amber[700]!;
//       case "إجازة":
//       case "إجازة أسبوعية":
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData getStatusIcon(String status) {
//     final s = status.trim();
//     switch (s) {
//       case "حاضر":
//         return Icons.check_circle;
//       case "غائب":
//       case "غياب":
//         return Icons.cancel;
//       case "تأخير":
//         return Icons.schedule;
//       case "إجازة":
//       case "إجازة أسبوعية":
//         return Icons.event;
//       default:
//         return Icons.help;
//     }
//   }

//   Widget _buildStatCard(String title, int count, Color color, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   count.toString(),
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         appBar: AppBar(
//           title: const Text(
//             "التقرير الشهري",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.blue[600],
//           foregroundColor: Colors.white,
//           elevation: 0,
//           toolbarHeight: 70,
//         ),
//         body: GetBuilder<AttendanceController>(
//           builder: (controller) {
//             if (controller.staterequest == Staterequest.loading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (controller.staterequest == Staterequest.failure ||
//                 controller.monthlyReport == null) {
//               return Center(
//                 child: Text(
//                   "فشل جلب البيانات",
//                   style: TextStyle(color: Colors.red[700], fontSize: 16),
//                 ),
//               );
//             }

//             final EmployeeMonthlyReportModel report = controller.monthlyReport!;
//             final statistics = {
//               'حاضر': report.presentCount,
//               'غياب': report.absentCount,
//               'تأخير': report.lateCount,
//               'إجازة': report.vacationCount,
//             };
//             final totalHours = report.totalHours;

//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     // اختيار الشهر والسنة
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "اختر الفترة",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               // Dropdown للشهر
//                               Expanded(
//                                 child: DropdownButtonFormField<String>(
//                                   value: selectedMonth,
//                                   decoration: InputDecoration(
//                                     labelText: "الشهر",
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 14,
//                                     ),
//                                   ),
//                                   items: months
//                                       .map(
//                                         (month) => DropdownMenuItem(
//                                           value: month,
//                                           child: Text(month),
//                                         ),
//                                       )
//                                       .toList(),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       selectedMonth = value!;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 12),

//                               // Dropdown للسنة
//                               Expanded(
//                                 child: DropdownButtonFormField<int>(
//                                   value: selectedYear,
//                                   decoration: InputDecoration(
//                                     labelText: "السنة",
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 14,
//                                     ),
//                                   ),
//                                   items: years
//                                       .map(
//                                         (y) => DropdownMenuItem(
//                                           value: y,
//                                           child: Text(y.toString()),
//                                         ),
//                                       )
//                                       .toList(),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       selectedYear = value!;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(width: 12),

//                           Align(
//                             alignment: Alignment.centerLeft, // الزر على اليسار
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor:
//                                     Colors.blue[600], // لون مناسب مع AppBar
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 12,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               onPressed: _fetchReport,
//                               child: const Text(
//                                 "عرض التقرير",
//                                 style: TextStyle(
//                                   color: Colors.white, // هنا اللون أبيض

//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // ملخص الشهر
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "ملخص الشهر",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           // شبكة الإحصائيات
//                           GridView.count(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 12,
//                             childAspectRatio: 2.2,
//                             children: [
//                               _buildStatCard(
//                                 "حاضر",
//                                 statistics['حاضر']!,
//                                 Colors.green,
//                                 Icons.check_circle,
//                               ),
//                               _buildStatCard(
//                                 "غياب",
//                                 statistics['غياب']!,
//                                 Colors.red,
//                                 Icons.cancel,
//                               ),
//                               _buildStatCard(
//                                 "تأخير",
//                                 statistics['تأخير']!,
//                                 Colors.amber[700]!,
//                                 Icons.schedule,
//                               ),
//                               _buildStatCard(
//                                 "إجازة",
//                                 statistics['إجازة']!,
//                                 Colors.orange,
//                                 Icons.event,
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           // إجمالي الساعات
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Colors.blue[600]!, Colors.blue[400]!],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       "إجمالي ساعات العمل",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                     Text(
//                                       "${totalHours.toStringAsFixed(1)} ساعة",
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const Icon(
//                                   Icons.access_time,
//                                   color: Colors.white,
//                                   size: 32,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // التفاصيل اليومية
//                     _buildDailyDetails(report),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyDetails(EmployeeMonthlyReportModel report) {
//     final data = report.attendanceList;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // عنوان التفاصيل
//           const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text(
//               "التفاصيل اليومية",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),

//           // عناوين الجدول
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             child: const Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     "التاريخ",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     "الحالة",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: Text(
//                     "الأوقات",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // البيانات اليومية
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: data.length,
//             separatorBuilder: (_, __) =>
//                 Divider(height: 1, color: Colors.grey[200]),
//             itemBuilder: (context, index) {
//               final item = data[index];
//               print("Status raw: '${item.status}'");
//               print("Status trimmed: '${item.status.trim()}'");

//               final statusColor = getStatusColor(item.status);
//               final statusIcon = getStatusIcon(item.status);

//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//                 child: Row(
//                   children: [
//                     // التاريخ
//                     Expanded(
//                       flex: 2,
//                       child: Text(
//                         item.date,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),

//                     // الحالة + أيقونة
//                     Expanded(
//                       flex: 2,
//                       child: Row(
//                         children: [
//                           Icon(statusIcon, color: statusColor, size: 18),
//                           const SizedBox(width: 6),
//                           Flexible(
//                             child: Text(
//                               item.status,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 color: statusColor,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // الأوقات
//                     Expanded(
//                       flex: 3,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           if (item.inTime != "-" && item.outTime != "-") ...[
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.login,
//                                   size: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   item.inTime,
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Icon(
//                                   Icons.logout,
//                                   size: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   item.outTime,
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               "${item.hours.toStringAsFixed(2)} ساعة",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ] else
//                             Text(
//                               "-",
//                               style: TextStyle(color: Colors.grey[500]),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
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

  @override
  void initState() {
    super.initState();
    years = List.generate(10, (index) => DateTime.now().year - 5 + index);
    _fetchReport();
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

    controller.fetchEmployeeMonthlyReport(
      startDateParam: startDateStr,
      endDateParam: endDateStr,
    );
  }

  Color getStatusColor(String status) {
    final s = status.trim();
    switch (s) {
      case "حاضر":
        return const Color(0xFF10B981);
      case "غائب":
      case "غياب":
        return const Color(0xFFEF4444);
      case "تأخير":
        return const Color(0xFFF59E0B);
      case "إجازة":
      case "إجازة أسبوعية":
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData getStatusIcon(String status) {
    final s = status.trim();
    switch (s) {
      case "حاضر":
        return Icons.check_circle_rounded;
      case "غائب":
      case "غياب":
        return Icons.cancel_rounded;
      case "تأخير":
        return Icons.schedule_rounded;
      case "إجازة":
      case "إجازة أسبوعية":
        return Icons.event_rounded;
      default:
        return Icons.help_rounded;
    }
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
            if (controller.staterequest == Staterequest.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE85D4A),
                  strokeWidth: 3,
                ),
              );
            }

            if (controller.staterequest == Staterequest.failure ||
                controller.monthlyReport == null) {
              return Center(
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
              );
            }

            final EmployeeMonthlyReportModel report = controller.monthlyReport!;

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

                    const SizedBox(height: 24),

                    // ملخص الإحصائيات
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

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          title: "حاضر",
                          value: report.presentCount,
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF10B981),
                        ),
                        _buildStatCard(
                          title: "غياب",
                          value: report.absentCount,
                          icon: Icons.cancel_rounded,
                          color: const Color(0xFFEF4444),
                        ),
                        _buildStatCard(
                          title: "تأخير",
                          value: report.lateCount,
                          icon: Icons.schedule_rounded,
                          color: const Color(0xFFF59E0B),
                        ),
                        _buildStatCard(
                          title: "إجازة",
                          value: report.vacationCount,
                          icon: Icons.event_rounded,
                          color: const Color(0xFF6366F1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // إجمالي ساعات العمل
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
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
                              Icons.access_time_rounded,
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
                                  "إجمالي ساعات العمل",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${report.totalHours.toStringAsFixed(1)} ساعة",
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
                              colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
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
                                  color: const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.inTime,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.logout_rounded,
                                  size: 14,
                                  color: const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.outTime,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.hours.toStringAsFixed(2)} ساعة",
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
