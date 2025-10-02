// attendance_service.dart
import 'package:human_resources/core/classes/api_client.dart';
import 'package:human_resources/core/constant/App_link.dart';
import 'package:human_resources/model/EmployeeMonthlyReportModel.dart';
import '../classes/staterequest_result.dart';

class AttendanceService {
  final ApiClient apiClient = ApiClient();

  Future<StaterequestResult<EmployeeMonthlyReportModel>>
  getEmployeeMonthlyReport({
    required int employeeId,
    required String startDate,
    required String endDate,
    String? token,
  }) async {
    try {
      final url =
          '${ServerConfig().serverLink}/attendances/employee-monthly-report/$employeeId'
          '?startDate=$startDate&endDate=$endDate';

      final response = await apiClient.getData(
        url: url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final report = EmployeeMonthlyReportModel.fromJson(data['data']);
          return StaterequestResult(isSuccess: true, data: report);
        }
      }

      return StaterequestResult(
        isSuccess: false,
        message: "فشل جلب تقرير الحضور",
      );
    } catch (error) {
      return StaterequestResult(isSuccess: false, message: error.toString());
    }
  }
}
