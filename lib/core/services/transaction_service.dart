import 'package:get/get.dart';
import 'package:human_resources/core/classes/api_client.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/constant/App_link.dart';
import 'package:human_resources/model/TransactionModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  final ApiClient apiClient = ApiClient();
List<TransactionModel> transactions = [];


  Future<Staterequest> addTransaction({
    required String transactionType,
    required int employeeId,
    required double amount,
    required String documentNumber,
    required String date,
    String? notes,
  }) async {
    try {
      final url = '${ServerConfig().serverLink}/transactions';
      print("Transaction URL: $url");

      // جلب التوكن من الـ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      ApiResponse<dynamic> response = await apiClient.postData(
        url: url,
        data: {
          "transaction_type": transactionType,
          "employee_id": employeeId,
          "amount": amount,
          "document_number": documentNumber,
          "date": date,
          "notes": notes ?? "",
        },
        headers: {"Authorization": "Bearer $token"},
      );

      print("Transaction Response Status: ${response.statusCode}");
      print("Transaction Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Staterequest.success;
      }

      return Staterequest.failure;
    } catch (error) {
      print("Transaction error: $error");
      Get.snackbar("خطأ", "حدث خطأ غير متوقع، تأكد من الاتصال بالإنترنت.");
      return Staterequest.failure;
    }
  }


  Future<Staterequest> addLeave({
    required String transactionType, // "daily_leave" أو "hourly_leave"
    required int employeeId,
    String? startDate, // للإجازة اليومية
    String? endDate, // للإجازة اليومية
    int? days, // للإجازة اليومية
    String? leaveDate, // للإجازة الساعية
    int? hours, // للإجازة الساعية
    String? startTime, // للإجازة الساعية
    String? endTime, // للإجازة الساعية
    String? reason,
  }) async {
    try {
      final url = '${ServerConfig().serverLink}/transactions';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      Map<String, dynamic> data = {
        "transaction_type": transactionType,
        "employee_id": employeeId,
      };

      if (transactionType == "daily_leave") {
        data.addAll({
          "start_date": startDate,
          "end_date": endDate,
          "days": days,
          "reason": reason ?? "",
        });
      } else if (transactionType == "hourly_leave") {
        data.addAll({
          "leave_date": leaveDate,
          "hours": hours,
          "start_time": startTime,
          "end_time": endTime,
          "reason": reason ?? "",
        });
      } else {
        print("Unknown leave type");
        return Staterequest.failure;
      }

      final response = await apiClient.postData(
        url: url,
        data: data,
        headers: {"Authorization": "Bearer $token"},
      );

      print("Leave Response Status: ${response.statusCode}");
      print("Leave Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Staterequest.success;
      }

      return Staterequest.failure;
    } catch (e) {
      print("Leave error: $e");
      Get.snackbar("خطأ", "حدث خطأ بالإجازة، تحقق من الإنترنت");
      return Staterequest.failure;
    }
  }


Future<List<TransactionModel>> getTransactions({
    String? type,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final employeeId = prefs.getInt('employee_id') ?? 0;

      final url =
          '${ServerConfig().serverLink}/transactions?employee_id=$employeeId';

      ApiResponse<dynamic> response = await apiClient.getData(
        url: url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = response.data['transactions'];
        return data.map((e) => TransactionModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print("Error fetching transactions: $e");
      return [];
    }
  }

}

