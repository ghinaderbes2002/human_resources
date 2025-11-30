import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse<T> {
  final int statusCode;
  final T data;

  ApiResponse({required this.statusCode, required this.data});
}

class ApiClient {
  final Dio _dio = Dio();

  // POST
  Future<ApiResponse<dynamic>> postData({
    required String url,
    required dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      print("Attempting to POST to $url with data: $data");

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final defaultHeaders = {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
        if (headers != null) ...headers,
      };

      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: defaultHeaders,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      print("POST successful: ${response.statusCode}");
      print("Response: ${response.data}");

      return ApiResponse(
        statusCode: response.statusCode ?? 0,
        data: response.data ?? {},
      );
    } on DioError catch (e) {
      print("DioError: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Response status: ${e.response?.statusCode}");
      }
      return ApiResponse(
        statusCode: e.response?.statusCode ?? 0,
        data: e.response?.data ?? {},
      );
    } catch (error, stacktrace) {
      print("Unknown error: $error");
      print("Stacktrace: $stacktrace");
      return ApiResponse(statusCode: 0, data: {});
    }
  }

 // get 
  Future<ApiResponse<dynamic>> getData({
      required String url,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
    }) async {
      try {
        print("Attempting to GET data from $url");

        // ✅ استرجاع SharedPreferences
        final prefs = await SharedPreferences.getInstance();

        // ✅ استرجاع التوكن من SharedPreferences
        final token = prefs.getString('token');

        // ✅ بناء الهيدر
        final defaultHeaders = {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          if (headers != null) ...headers,
        };

        var response = await _dio.get(
          url,
          queryParameters: queryParameters,
          options: Options(headers: defaultHeaders),
        );

        print("GET successful - Status Code: ${response.statusCode}");
        return ApiResponse(statusCode: response.statusCode!, data: response.data);
      } catch (error, stacktrace) {
        print("Failed to GET data: $error");
        print("Stacktrace: $stacktrace");

        throw DioError(
          requestOptions: RequestOptions(path: url),
          error: 'Failed to fetch data: $error',
        );
      }
    }


// put
  Future<ApiResponse<dynamic>> putData({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      print("Attempting to PUT data to $url with body: $data");

      // ✅ استرجاع SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // ✅ استرجاع التوكن من SharedPreferences
      final token = prefs.getString('token');

      // ✅ بناء الهيدر
      final defaultHeaders = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
        if (headers != null) ...headers,
      };

      var response = await _dio.put(
        url,
        data: data,
        options: Options(headers: defaultHeaders),
      );

      print("PUT successful - Status Code: ${response.statusCode}");
      return ApiResponse(statusCode: response.statusCode!, data: response.data);
    } catch (error, stacktrace) {
      print("Failed to PUT data: $error");
      print("Stacktrace: $stacktrace");

      throw DioError(
        requestOptions: RequestOptions(path: url),
        error: 'Failed to PUT data: $error',
      );
    }
  }

  }

