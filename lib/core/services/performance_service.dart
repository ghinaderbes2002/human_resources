// performance_service.dart
import 'package:human_resources/core/classes/manager_api.dart';
import 'package:human_resources/core/classes/staterequest_result.dart';
import 'package:human_resources/model/MyPerformanceModel.dart';

class PerformanceService {
  /// جلب تقييم الموظف الحالي (الموظف يُحدد من التوكن)
  Future<StaterequestResult<MyPerformanceModel>> getMyPerformance({
    required int year,
    required int month,
  }) async {
    final res = await ManagerApi.instance.get(
      '/kpi/my/performance',
      query: {'year': year, 'month': month},
    );

    if (res.ok && res.data is Map<String, dynamic>) {
      return StaterequestResult(
        isSuccess: true,
        data: MyPerformanceModel.fromJson(res.data),
      );
    }

    // رسالة الخادم (مثلاً انتهاء الجلسة) أو رسالة عامة
    return StaterequestResult(
      isSuccess: false,
      message: res.messageOr("فشل جلب بيانات التقييم"),
    );
  }
}
