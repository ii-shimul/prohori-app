import '../../core/network/api_client.dart';
import '../../core/config/app_environment.dart';
import '../domain/outlet_alert.dart';

class AlertsApi {
  AlertsApi(this._apiClient);
  final ApiClient _apiClient;

  Future<List<OutletAlert>> fetchAlerts() async {
    if (AppEnvironment.useDemoData) return _demoAlerts;
    final response = await _apiClient.get<Object>('/alerts');
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
    if (AppEnvironment.useDemoData) {
      return _demoAlerts.firstWhere((alert) => alert.id == id);
    }
    final response = await _apiClient.get<Map<String, dynamic>>('/alerts/$id');
    return OutletAlert.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<void> acknowledge(String id) async {
    if (AppEnvironment.useDemoData) return;
    await _apiClient.post<void>(
      '/alerts/$id/acknowledge',
      idempotencyKey: 'alert-ack-$id-${DateTime.now().microsecondsSinceEpoch}',
    );
  }

  static const _demoAlerts = [
    OutletAlert(
      id: 'cash-watch',
      title: 'Cash level needs attention',
      summary: 'Shared physical cash is below preferred operating range.',
      severity: 'HIGH',
      status: 'OPEN',
      caseId: 'case-cash-watch',
    ),
    OutletAlert(
      id: 'freshness-check',
      title: 'Feed freshness check',
      summary: 'Latest provider feed is available for review.',
      severity: 'LOW',
      status: 'OPEN',
      caseId: 'case-freshness-check',
    ),
  ];
}
