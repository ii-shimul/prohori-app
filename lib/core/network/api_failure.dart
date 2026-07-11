import 'package:dio/dio.dart';

class ApiFailure implements Exception {
  const ApiFailure({required this.code, required this.message, this.correlationId});

  final String code;
  final String message;
  final String? correlationId;

  factory ApiFailure.fromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiFailure(
        code: '${data['code'] ?? 'API_ERROR'}',
        message: '${data['message'] ?? 'Request could not be completed.'}',
        correlationId: data['correlationId'] as String?,
      );
    }
    return const ApiFailure(
      code: 'NETWORK_ERROR',
      message: 'Connection to the operations service failed.',
    );
  }
}
