import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prohori_app/core/network/api_client.dart';
import 'package:prohori_app/core/network/dto/current_user_response.dart';
import 'package:prohori_app/core/scope/session_scope.dart';

void main() {
  const currentUser = {
    'id': '40000000-0000-4000-8000-000000000002',
    'locale': 'bn',
    'memberships': [
      {
        'providerId': '10000000-0000-4000-8000-000000000001',
        'role': 'PROVIDER_OPERATOR',
      },
    ],
    'assignments': [
      {
        'areaId': '20000000-0000-4000-8000-000000000001',
        'outletId': '30000000-0000-4000-8000-000000000001',
        'providerId': '10000000-0000-4000-8000-000000000001',
        'role': 'OUTLET_AGENT',
      },
      {
        'areaId': '20000000-0000-4000-8000-000000000001',
        'outletId': '30000000-0000-4000-8000-000000000001',
        'providerId': null,
        'role': 'OUTLET_AGENT',
      },
    ],
  };

  test('GET /me maps locale and deduplicated assigned outlet scope', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        expect(options.path, '/me');
        handler.resolve(Response<Map<String, dynamic>>(
          requestOptions: options,
          data: Map<String, dynamic>.from(currentUser),
        ));
      },
    ));

    final scope = await SessionScopeApi(ApiClient(dio)).fetch();

    expect(scope.userId, currentUser['id']);
    expect(scope.locale, 'bn');
    expect(scope.outletIds, ['30000000-0000-4000-8000-000000000001']);
    expect(scope.memberships.single.role, 'PROVIDER_OPERATOR');
    expect(scope.assignments, hasLength(2));
  });

  test('GET /me rejects unknown locales', () {
    expect(
      () => SessionScope.fromResponse(
        CurrentUserResponse.fromJson({
          ...currentUser,
          'locale': 'fr',
        }),
      ),
      throwsFormatException,
    );
  });
}
