import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prohori_app/core/network/api_client.dart';
import 'package:prohori_app/dashboard/data/outlet_dashboard_api.dart';

void main() {
  test('GET /outlets/:id/balances maps separate cash and provider balances',
      () async {
    const outletId = '30000000-0000-4000-8000-000000000001';
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        expect(options.path, '/outlets/$outletId/balances');
        handler.resolve(Response<Map<String, dynamic>>(
          requestOptions: options,
          data: {
            'outletId': outletId,
            'sharedCash': {
              'resource': 'shared_cash',
              'amountMinor': '148500',
            },
            'providerEMoney': [
              {
                'resource': 'provider_efloat',
                'amountMinor': '25400',
                'provider': {
                  'id': '10000000-0000-4000-8000-000000000001',
                  'code': 'PROVIDER_A',
                  'name': 'Provider A',
                },
              },
            ],
          },
        ));
      },
    ));

    final balances = await OutletBalancesApi(ApiClient(dio)).fetch(outletId);

    expect(balances.sharedCash.formattedBdt, 'BDT 148,500');
    expect(balances.providerEMoney.single.providerName, 'Provider A');
    expect(balances.providerEMoney.single.amount.formattedBdt, 'BDT 25,400');
  });

  test('balance API rejects non-integer amountMinor', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(Response<Map<String, dynamic>>(
          requestOptions: options,
          data: {
            'outletId': 'outlet-id',
            'sharedCash': {
              'resource': 'shared_cash',
              'amountMinor': '12.50',
            },
            'providerEMoney': const [],
          },
        ));
      },
    ));

    expect(
      () => OutletBalancesApi(ApiClient(dio)).fetch('outlet-id'),
      throwsFormatException,
    );
  });
}
