// performance_controller.dart
import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/performance_service.dart';
import 'package:human_resources/model/MyPerformanceModel.dart';

class PerformanceController extends GetxController {
  final PerformanceService _service = PerformanceService();

  Staterequest staterequest = Staterequest.none;
  MyPerformanceModel? performance;
  String? errorMessage;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void onInit() {
    super.onInit();
    fetchPerformance();
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return selectedYear == now.year && selectedMonth == now.month;
  }

  void previousMonth() {
    if (selectedMonth == 1) {
      selectedMonth = 12;
      selectedYear--;
    } else {
      selectedMonth--;
    }
    fetchPerformance();
  }

  void nextMonth() {
    if (isCurrentMonth) return;
    if (selectedMonth == 12) {
      selectedMonth = 1;
      selectedYear++;
    } else {
      selectedMonth++;
    }
    fetchPerformance();
  }

  Future<void> fetchPerformance() async {
    staterequest = Staterequest.loading;
    update();

    final result = await _service.getMyPerformance(
      year: selectedYear,
      month: selectedMonth,
    );

    if (result.isSuccess) {
      performance = result.data;
      errorMessage = null;
      staterequest = Staterequest.success;
    } else {
      errorMessage = result.message;
      staterequest = Staterequest.failure;
    }

    update();
  }
}
