import 'package:get/get.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/transaction_service.dart';
import 'package:human_resources/model/TransactionModel.dart';

class TransactionController extends GetxController {
  final TransactionService _service = TransactionService();
  List<TransactionModel> transactions = [];

  Staterequest staterequest = Staterequest.none;
  // انشاء سلفة
  Future<void> createTransaction({
    required String transactionType,
    required int employeeId,
    required double amount,
    required String documentNumber,
    required String date,
    String? notes,
  }) async {
    staterequest = Staterequest.loading;
    update();

    staterequest = await _service.addTransaction(
      transactionType: transactionType,
      employeeId: employeeId,
      amount: amount,
      documentNumber: documentNumber,
      date: date,
      notes: notes,
    );

    update();

    if (staterequest == Staterequest.success) {
      Get.snackbar("تم", "تمت إضافة العملية بنجاح");
      Get.back();
    } else {
      Get.snackbar("فشل", "لم تتم إضافة العملية");
    }
  }

  // إنشاء إجازة (يومية أو ساعية)
  Future<void> createLeave({
    required String transactionType, // "daily_leave" أو "hourly_leave"
    required int employeeId,
    String? startDate,
    String? endDate,
    int? days,
    String? leaveDate,
    int? hours,
    String? startTime,
    String? endTime,
    String? reason,
  }) async {
    staterequest = Staterequest.loading;
    update();

    staterequest = await _service.addLeave(
      transactionType: transactionType,
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
      days: days,
      leaveDate: leaveDate,
      hours: hours,
      startTime: startTime,
      endTime: endTime,
      reason: reason,
    );

    update();

    if (staterequest == Staterequest.success) {
      Get.snackbar("تم", "تمت إضافة الإجازة بنجاح");
      Get.back();
    } else {
      Get.snackbar("فشل", "لم تتم إضافة الإجازة");
    }
  }

Future<void> fetchTransactions() async {
    staterequest = Staterequest.loading;
    update();

    transactions = await _service.getTransactions();

    staterequest = Staterequest.success;
    update();
  }


}
