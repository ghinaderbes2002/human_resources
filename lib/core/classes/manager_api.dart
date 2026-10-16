// manager_api.dart
// عميل HTTP لشاشات الإدارة: لا يرمي استثناءات، ويُرجع رسالة الخطأ من الخادم.
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:human_resources/core/constant/App_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiResult {
  final bool ok;
  final int statusCode;
  final dynamic data;
  final String? message;

  ApiResult({
    required this.ok,
    required this.statusCode,
    this.data,
    this.message,
  });

  /// الرسالة القادمة من الخادم أو رسالة افتراضية
  String messageOr(String fallback) =>
      (message != null && message!.trim().isNotEmpty) ? message! : fallback;
}

class ManagerApi {
  ManagerApi._();
  static final ManagerApi instance = ManagerApi._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      // لا نرمي استثناء عند 4xx/5xx حتى نقرأ رسالة الخادم
      validateStatus: (_) => true,
    ),
  );

  String url(String path) => '${ServerConfig().serverLink}$path';

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResult> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);

  Future<ApiResult> post(String path, {dynamic body}) =>
      _send('POST', path, body: body ?? {});

  Future<ApiResult> put(String path, {dynamic body}) =>
      _send('PUT', path, body: body ?? {});

  Future<ApiResult> delete(String path, {dynamic body}) =>
      _send('DELETE', path, body: body);

  /// إرسال multipart (رفع ملفات). [fields] قيم نصية، [files] اسم الحقل -> مسار الملف.
  Future<ApiResult> postMultipart(
    String path, {
    Map<String, dynamic> fields = const {},
    Map<String, String> files = const {},
  }) async {
    final form = FormData();
    fields.forEach((k, v) {
      if (v != null) form.fields.add(MapEntry(k, v.toString()));
    });
    for (final e in files.entries) {
      form.files.add(MapEntry(
        e.key,
        await MultipartFile.fromFile(e.value, filename: e.value.split(RegExp(r'[\\/]')).last),
      ));
    }
    return _send('POST', path, body: form);
  }

  /// تنزيل ملف كبايتات (مثلاً صورة الموظف أو مرفق)
  Future<Uint8List?> downloadBytes(String path) async {
    try {
      final res = await _dio.get<List<int>>(
        url(path),
        options: Options(
          headers: await _headers(),
          responseType: ResponseType.bytes,
        ),
      );
      if (res.statusCode == 200 && res.data != null) {
        return Uint8List.fromList(res.data!);
      }
    } catch (_) {}
    return null;
  }

  Future<ApiResult> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    dynamic body,
  }) async {
    try {
      final res = await _dio.request(
        url(path),
        data: body,
        queryParameters: query,
        options: Options(method: method, headers: await _headers()),
      );
      final code = res.statusCode ?? 0;
      final data = res.data;
      String? message;
      if (data is Map && data['message'] is String) message = data['message'];
      // بعض النقاط تُرجع 200 مع status داخلي = 400
      final bodyStatus = data is Map ? data['status'] : null;
      final ok = code >= 200 && code < 300 && bodyStatus != 400;
      return ApiResult(ok: ok, statusCode: code, data: data, message: message);
    } on DioException catch (e) {
      final offline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      return ApiResult(
        ok: false,
        statusCode: 0,
        message: offline ? 'تعذر الاتصال بالخادم' : 'حدث خطأ غير متوقع',
      );
    } catch (_) {
      return ApiResult(ok: false, statusCode: 0, message: 'حدث خطأ غير متوقع');
    }
  }
}
