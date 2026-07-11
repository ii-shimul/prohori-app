import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/config/app_environment.dart';
import '../domain/outlet_dashboard.dart';

class OutletDashboardApi {
  OutletDashboardApi(this._apiClient);

  final ApiClient _apiClient;

  Future<OutletDashboard> fetch(String outletId) async {
    if (AppEnvironment.useDemoData) {
      return OutletDashboard.fromJson(const {
        'sharedPhysicalCash': {'amount': 125000, 'currency': 'BDT'},
        'providerEMoney': {'amount': 68000, 'currency': 'BDT'},
        'freshness': 'Demo data · refreshed now',
      }, const {
        'limitingResource': 'Provider e-money is the limiting resource.',
        'summary': 'Expected to remain sufficient for the next 4 hours.',
      });
    }
    final responses = await Future.wait([
      _apiClient.get<Map<String, dynamic>>('/outlets/$outletId/balances'),
      _apiClient.get<Map<String, dynamic>>('/outlets/$outletId/forecasts'),
    ]);
    return OutletDashboard.fromJson(
      _body(responses[0]),
      _body(responses[1]),
    );
  }

  Map<String, dynamic> _body(Response<Map<String, dynamic>> response) {
    return response.data ?? const <String, dynamic>{};
  }
}
