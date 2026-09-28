// performance_service.dart
import 'package:human_resources/core/classes/api_client.dart';
import 'package:human_resources/core/classes/staterequest_result.dart';
import 'package:human_resources/core/constant/App_link.dart';
import 'package:human_resources/model/MyPerformanceModel.dart';

class PerformanceService {
  final ApiClient apiClient = ApiClient();

  /// جلب تقييم الموظف الحالي (الموظف يُحدد من التوكن)
  Future<StaterequestResult<MyPerformanceModel>> getMyPerformance({
    required int year,
    required int month,
  }) async {
    try {
      final url = '${ServerConfig().serverLink}/kpi/my/performance';

      final response = await apiClient.getData(
        url: url,
        queryParameters: {'year': year, 'month': month},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return StaterequestResult(
          isSuccess: true,
          data: MyPerformanceModel.fromJson(response.data),
        );
      }

      return StaterequestResult(
        isSuccess: false,
        message: "فشل جلب بيانات التقييم",
      );
    } catch (error) {
      print("Error fetching performance: $error");
      return StaterequestResult(
        isSuccess: false,
        message: "تعذر الاتصال بالخادم",
      );
    }
  }
}
