import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../domain/outlet_dashboard.dart';

class OutletDashboardApi {
  OutletDashboardApi(this._apiClient);

  final ApiClient _apiClient;

  Future<OutletDashboard> fetch(String outletId) async {
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
