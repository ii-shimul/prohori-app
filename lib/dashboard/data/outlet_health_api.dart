import '../../core/network/api_client.dart';
import '../domain/outlet_health.dart';

class OutletHealthApi {
  OutletHealthApi(this._apiClient);
  final ApiClient _apiClient;

  Future<OutletHealth> fetch(String outletId) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/outlets/$outletId/health');
    final json = response.data;
    if (json == null) throw const FormatException('Health response is empty.');
    final result = OutletHealth(
      outletId: _text(json, 'outletId'),
      dataQuality: _text(json, 'dataQuality'),
      modelConfidence: (json['modelConfidence'] as num?)?.toDouble() ??
          (throw const FormatException('Health confidence is invalid.')),
      unusualActivityCount: _list(json['unusualActivity'], 'unusualActivity').length,
    );
    if (result.outletId != outletId) throw const FormatException('Health outlet does not match request.');
    return result;
  }

  String _text(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) throw FormatException('Health $key is missing.');
    return value;
  }

  List<Object?> _list(Object? value, String key) {
    if (value is! List) throw FormatException('Health $key is invalid.');
    return value;
  }
}
