import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prohori_app/core/config/app_environment.dart';
import 'package:prohori_app/core/network/api_client.dart';
import 'package:prohori_app/core/network/api_failure.dart';
import 'package:prohori_app/core/network/dto/api_error_response.dart';
import 'package:prohori_app/core/network/request_metadata_interceptor.dart';

void main() {
  test('live configuration accepts an explicit API v1 base URL', () {
    expect(
      () => AppEnvironment.validateValues(
        apiBaseUrl: 'https://prohori-api.onrender.com/api/v1',
        supabaseUrl: 'https://project.supabase.co',
        supabasePublishableKey: 'live-publishable-key',
      ),
      returnsNormally,
    );
  });

  test('live configuration rejects demo and malformed values', () {
    expect(
      () => AppEnvironment.validateValues(
        apiBaseUrl: 'https://prohori-api.onrender.com',
        supabaseUrl: 'https://demo.supabase.co',
        supabasePublishableKey: '',
      ),
      throwsStateError,
    );
  });

  test('metadata interceptor supplies a valid correlation ID', () async {
    final dio = Dio();
    dio.interceptors.add(RequestMetadataInterceptor(
      createCorrelationId: () => '123e4567-e89b-42d3-a456-426614174000',
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        expect(options.headers['X-Correlation-Id'],
            '123e4567-e89b-42d3-a456-426614174000');
        handler.resolve(Response<void>(requestOptions: options));
      },
    ));

    await dio.get<void>('/health');
  });

  test('API error payload maps into a safe failure', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response<Object>(
            requestOptions: options,
            statusCode: 409,
            data: {
              'code': 'CASE_VERSION_CONFLICT',
              'message': 'Case changed. Refresh and try again.',
              'fieldErrors': {'version': ['Current version is newer.']},
              'correlationId': '123e4567-e89b-42d3-a456-426614174000',
            },
          ),
        ));
      },
    ));

    expect(
      () => ApiClient(dio).post<void>('/cases/example/notes'),
      throwsA(
        isA<ApiFailure>()
            .having((error) => error.code, 'code', 'CASE_VERSION_CONFLICT')
            .having((error) => error.fieldErrors['version'], 'field errors', isNotEmpty)
            .having(
              (error) => error.correlationId,
              'correlation ID',
              '123e4567-e89b-42d3-a456-426614174000',
            ),
      ),
    );
  });

  test('standard error DTO tolerates untyped decoded JSON', () {
    final error = ApiErrorResponse.fromJson({
      'code': 'INVALID_FILTER',
      'message': 'Filter is invalid.',
      'fieldErrors': {'outletId': ['Must be a UUID.']},
    });

    expect(error.code, 'INVALID_FILTER');
    expect(error.fieldErrors['outletId'], ['Must be a UUID.']);
  });
}
