import 'package:dio/dio.dart';

import 'api_failure.dart';

class ApiClient {
  ApiClient(this.dio);

  final Dio dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(() => dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    String? idempotencyKey,
  }) {
    return _request(
      () => dio.post<T>(
        path,
        data: data,
        options: idempotencyKey == null
            ? null
            : Options(headers: {'Idempotency-Key': idempotencyKey}),
      ),
    );
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}
