import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this.dio);

  final Dio dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    String? idempotencyKey,
  }) {
    return dio.post<T>(
      path,
      data: data,
      options: idempotencyKey == null
          ? null
          : Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }
}
