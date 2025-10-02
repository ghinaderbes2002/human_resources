import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:human_resources/core/constant/App_routes.dart';
import 'package:human_resources/view/screen/DailyFingerprintPage.dart';
import 'package:human_resources/view/screen/DashboardPage.dart';
import 'package:human_resources/view/screen/MonthlyReportPage.dart';
import 'package:human_resources/view/screen/TransactionPage.dart';
import 'package:human_resources/view/screen/auth/login.dart';
import 'package:human_resources/view/screen/profilePage.dart';

List<GetPage<dynamic>>? routes = [

  // GetPage(
  //   name: "/",
  //   page: () => const MainHome(),
  // ),
  // GetPage(name: "/", page: () => const Login()),

  GetPage(name: "/", page: () => const DashboardPage()),
  // GetPage(name: AppRoute.dashboardPage, page: () => const DashboardPage()),
  GetPage(name: AppRoute.monthlyReport, page: () => const MonthlyReportPage()),
  GetPage(name: AppRoute.transactionScreen, page: () => const TransactionScreen()),
  GetPage(
    name: AppRoute.dailyFingerprint,
    page: () => const DailyFingerprintPage(),
  ),
  GetPage(
    name: AppRoute.profile,
    page: () => const Profilepage(),
  ),
];
