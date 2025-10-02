// staterequest_result.dart
class StaterequestResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;

  StaterequestResult({required this.isSuccess, this.data, this.message});
}
