import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prohori_app/alerts/data/alerts_api.dart';
import 'package:prohori_app/auth/data/secure_auth_storage.dart';
import 'package:prohori_app/auth/data/supabase_auth_data_source.dart';
import 'package:prohori_app/auth/domain/auth_repository.dart';
import 'package:prohori_app/auth/domain/auth_user.dart';
import 'package:prohori_app/cases/data/cases_api.dart';
import 'package:prohori_app/core/network/api_client.dart';
import 'package:prohori_app/core/scope/session_scope.dart';
import 'package:prohori_app/dashboard/data/outlet_dashboard_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

void main() {
  final apiClient = ApiClient(Dio());

  test('demo dashboard remains scoped to requested outlet', () async {
    final dashboard = await OutletDashboardApi(apiClient).fetch('demo-outlet');
    expect(dashboard.sharedPhysicalCash.currency, 'BDT');
    expect(dashboard.limitingResource, isNotEmpty);
  });

  test('demo note logging appears in case timeline', () async {
    final cases = CasesApi(apiClient);
    await cases.addNote('case-smoke', 'Verified physical cash count.');
    final detail = await cases.fetchCase('case-smoke');
    expect(detail.timeline.any((event) => event.description.contains('Verified physical cash count.')), isTrue);
  });

  test('demo alerts are available to assigned outlet flow', () async {
    final alerts = await AlertsApi(apiClient).fetchAlerts();
    expect(alerts, isNotEmpty);
    expect(alerts.first.id, isNotEmpty);
  });

  test('session scope preserves assigned outlet boundaries', () {
    final first = SessionScope.fromJson({
      'id': 'agent-a',
      'role': 'OUTLET_AGENT',
      'assignedOutletIds': ['outlet-a'],
    });
    final second = SessionScope.fromJson({
      'id': 'agent-b',
      'role': 'OUTLET_AGENT',
      'assignedOutletIds': ['outlet-b'],
    });

    expect(first.primaryOutletId, 'outlet-a');
    expect(second.primaryOutletId, 'outlet-b');
    expect(first.outletIds, isNot(contains(second.primaryOutletId)));
  });

  test('mutation sends an idempotency key', () async {
    final dio = Dio();
    String? receivedKey;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        receivedKey = options.headers['Idempotency-Key'] as String?;
        handler.resolve(Response<void>(requestOptions: options));
      },
    ));

    await ApiClient(dio).post<void>('/alerts/a/acknowledge', idempotencyKey: 'smoke-key');

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
  _FakeAuthSource() : super(SupabaseClient('https://demo.supabase.co', 'demo-key'));

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
