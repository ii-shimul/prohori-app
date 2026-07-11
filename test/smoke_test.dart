import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prohori_app/auth/data/secure_auth_storage.dart';
import 'package:prohori_app/auth/data/supabase_auth_data_source.dart';
import 'package:prohori_app/auth/domain/auth_repository.dart';
import 'package:prohori_app/core/network/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

void main() {
  test('mutation forwards an idempotency key', () async {
    final dio = Dio();
    String? receivedKey;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        receivedKey = options.headers['Idempotency-Key'] as String?;
        handler.resolve(Response<void>(requestOptions: options));
      },
    ));

    await ApiClient(dio).post<void>(
      '/alerts/a/acknowledge',
      idempotencyKey: 'smoke-key',
    );

    expect(receivedKey, 'smoke-key');
  });

  test('logout clears secure storage after sign-out', () async {
    final source = _FakeAuthSource();
    final storage = _FakeSecureStorage();
    final repository = AuthRepository(dataSource: source, secureStorage: storage);

    await repository.logout();

    expect(source.signedOut, isTrue);
    expect(storage.wiped, isTrue);
  });
}

class _FakeAuthSource extends SupabaseAuthDataSource {
  _FakeAuthSource()
      : super(SupabaseClient('https://test-project.supabase.co', 'test-key'));

  bool signedOut = false;

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

class _FakeSecureStorage extends SecureAuthStorage {
  _FakeSecureStorage() : super(const FlutterSecureStorage());

  bool wiped = false;

  @override
  Future<void> wipeDatabase() async {
    wiped = true;
  }
}
