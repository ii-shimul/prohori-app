import 'package:dio/dio.dart';

import 'dto/api_error_response.dart';

class ApiFailure implements Exception {
  const ApiFailure({
    required this.code,
    required this.message,
    this.fieldErrors = const <String, List<String>>{},
    this.correlationId,
  });

  final String code;
  final String message;
  final Map<String, List<String>> fieldErrors;
  final String? correlationId;

  factory ApiFailure.fromDio(DioException error) {
    if (error.response?.data is Map) {
      final response = ApiErrorResponse.fromJson(error.response!.data);
      return ApiFailure(
        code: response.code,
        message: response.message,
        fieldErrors: response.fieldErrors,
        correlationId: response.correlationId,
      );
    }
    return const ApiFailure(
      code: 'NETWORK_ERROR',
      message: 'Connection to the operations service failed.',
    );
  }
}
