// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiResponse<T> {
//   final int statusCode;
//   final T data;

//   ApiResponse({required this.statusCode, required this.data});
// }

// class ApiClient {
//   final Dio _dio = Dio();

//   Future<ApiResponse<dynamic>> patchData({
//     required String url,
//     required dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Map<String, dynamic>? headers,
//   }) async {
//     try {
//       print("Attempting to patch data to $url with data: $data");

//       // ✅ استرجاع SharedPreferences
//       final prefs = await SharedPreferences.getInstance();

//       // ✅ استرجاع التوكن
//       final token = prefs.getString('token');

//       // ✅ بناء الهيدر
//       final defaultHeaders = {
//         "Authorization": "Bearer $token",
//         "Accept": "application/json",
//         if (headers != null) ...headers,
//       };

//       var response = await _dio.patch(
//         url,
//         data: data,
//         queryParameters: queryParameters,
//         options: Options(headers: defaultHeaders),
//       );

//       print(
//         "Data patched successfully with status code ${response.statusCode}",
//       );
//       return ApiResponse(statusCode: response.statusCode!, data: response.data);
//     } catch (error, stacktrace) {
//       print("Failed to patch data: $error");
//       print("Stacktrace: $stacktrace");

//       throw DioError(
//         requestOptions: RequestOptions(path: url),
//         error: 'Failed to patch data: $error',
//       );
//     }
//   }

//   // Future<ApiResponse<dynamic>> postData({
//   //   required String url,
//   //   required dynamic data,
//   //   Map<String, dynamic>? queryParameters,
//   //   Map<String, dynamic>? headers,
//   // }) async {
//   //   try {
//   //     print("Attempting to post data to $url with data: $data");
//   //     var response = await _dio.post(
//   //       url,
//   //       data: data,
//   //       queryParameters: queryParameters,
//   //       options: Options(headers: headers),
//   //     );
//   //     print("Data posted successfully with status code ${response.statusCode}");
//   //     return ApiResponse(statusCode: response.statusCode!, data: response.data);
//   //   } catch (error, stacktrace) {
//   //     print("Failed to post data: $error");
//   //     print("Stacktrace: $stacktrace");
//   //     rethrow; // لا ترمي خطأ جديد، رجّع الأصلي
//   //   }
//   // }
// Future<ApiResponse<dynamic>> postData({
//     required String url,
//     required dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Map<String, dynamic>? headers,
//   }) async {
//     try {
//       print("Attempting to post data to $url with data: $data");

//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');

//       final defaultHeaders = {
//         "Authorization": "Bearer $token",
//         "Accept": "application/json",
//         if (headers != null) ...headers,
//       };

//       final response = await _dio.post(
//         url,
//         data: data,
//         queryParameters: queryParameters,
//         options: Options(
//           headers: defaultHeaders,
//           sendTimeout: const Duration(seconds: 10),
//           receiveTimeout: const Duration(seconds: 10),
//         ),
//       );

//       print(
//         "Data posted successfully with status code: ${response.statusCode}",
//       );
//       print("Response data: ${response.data}");

//       return ApiResponse(
//         statusCode: response.statusCode ?? 0,
//         data: response.data ?? {},
//       );
//     } on DioError catch (e) {
//       print("DioError: ${e.message}");
//       if (e.response != null) {
//         print("Response data: ${e.response?.data}");
//         print("Response status: ${e.response?.statusCode}");
//       }
//       return ApiResponse(
//         statusCode: e.response?.statusCode ?? 0,
//         data: e.response?.data ?? {},
//       );
//     } catch (error, stacktrace) {
//       print("Unknown error: $error");
//       print("Stacktrace: $stacktrace");
//       return ApiResponse(statusCode: 0, data: {});
//     }
//   }

//   Future<ApiResponse<dynamic>> getData({
//     required String url,
//     Map<String, dynamic>? queryParameters,
//     Map<String, dynamic>? headers,
//   }) async {
//     try {
//       print("Attempting to GET data from $url");

//       // ✅ استرجاع SharedPreferences
//       final prefs = await SharedPreferences.getInstance();

//       // ✅ استرجاع التوكن من SharedPreferences
//       final token = prefs.getString('token');

//       // ✅ بناء الهيدر
//       final defaultHeaders = {
//         "Authorization": "Bearer $token",
//         "Accept": "application/json",
//         if (headers != null) ...headers,
//       };

//       var response = await _dio.get(
//         url,
//         queryParameters: queryParameters,
//         options: Options(headers: defaultHeaders),
//       );

//       print("GET successful - Status Code: ${response.statusCode}");
//       return ApiResponse(statusCode: response.statusCode!, data: response.data);
//     } catch (error, stacktrace) {
//       print("Failed to GET data: $error");
//       print("Stacktrace: $stacktrace");

//       throw DioError(
//         requestOptions: RequestOptions(path: url),
//         error: 'Failed to fetch data: $error',
//       );
//     }
//   }

//   Future<ApiResponse<dynamic>> deleteData({
//     required String url,
//     Map<String, dynamic>? queryParameters,
//     Map<String, dynamic>? headers,
//   }) async {
//     try {
//       print("Attempting to delete data at $url");
//       Response<dynamic> response = await _dio.delete(
//         url,
//         queryParameters: queryParameters,
//         options: Options(headers: headers),
//       );
//       print(
//         "Data deleted successfully with status code ${response.statusCode}",
//       );
//       return ApiResponse(statusCode: response.statusCode!, data: response.data);
//     } catch (error, stacktrace) {
//       print("Failed to delete data: $error");
//       print("Stacktrace: $stacktrace");
//       throw DioError(
//         requestOptions: RequestOptions(path: url),
//         error: 'Failed to delete data: $error',
//       );
//     }
//   }

//   Future<ApiResponse<dynamic>> putData({
//     required String url,
//     required dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Map<String, dynamic>? headers,
//   }) async {
//     try {
//       print("Attempting to put data to $url");
//       Response<dynamic> response = await _dio.put(
//         url,
//         data: data,
//         queryParameters: queryParameters,
//         options: Options(headers: headers),
//       );
//       print("Data put successfully with status code ${response.statusCode}");
//       return ApiResponse(statusCode: response.statusCode!, data: response.data);
//     } catch (error, stacktrace) {
//       print("Failed to put data: $error");
//       print("Stacktrace: $stacktrace");
//       throw DioError(
//         requestOptions: RequestOptions(path: url),
//         error: 'Failed to put data: $error',
//       );
//     }
//   }
// }



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

