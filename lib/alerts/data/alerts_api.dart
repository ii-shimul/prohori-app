import '../../core/network/api_client.dart';
import '../domain/outlet_alert.dart';

class AlertsApi {
  AlertsApi(this._apiClient);
  final ApiClient _apiClient;

  Future<List<OutletAlert>> fetchAlerts() async {
    final response = await _apiClient.get<Object>(
      '/alerts',
      queryParameters: const {'active': true},
    );
    final payload = response.data;
    final items = payload is List
        ? payload
        : payload is Map<String, dynamic>
            ? payload['items'] as List? ?? payload['data'] as List? ?? const []
            : const [];
    return items
        .whereType<Map>()
        .map((item) => OutletAlert.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<OutletAlert> fetchAlert(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/alerts/$id');
    return OutletAlert.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<void> acknowledge(String id) async {
    await _apiClient.post<void>(
      '/alerts/$id/acknowledge',
      idempotencyKey: 'alert-ack-$id-${DateTime.now().microsecondsSinceEpoch}',
    );
  }
}
