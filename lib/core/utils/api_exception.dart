class ApiException implements Exception {
  final dynamic message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() {
    if (message is String) {
      //return 'Error: $message';
      return '$message';
      //return 'ApiException: $message (code: $statusCode)';
    }
    // return 'Error: $message, Status Code: $statusCode';
    return '$message, $statusCode';
  }
}