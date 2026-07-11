import '../../core/network/api_client.dart';
import '../domain/outlet_forecast.dart';

class OutletForecastApi {
  OutletForecastApi(this._apiClient);
  final ApiClient _apiClient;

  Future<OutletForecast> fetch(String outletId) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/outlets/$outletId/forecasts');
    final json = response.data;
    if (json == null) throw const FormatException('Forecast response is empty.');
    final forecast = _fromJson(json);
    if (forecast.outletId != outletId) throw const FormatException('Forecast outlet does not match request.');
    return forecast;
  }

  OutletForecast _fromJson(Map<String, dynamic> json) => OutletForecast(
        outletId: _text(json, 'outletId'),
        dataQuality: _text(json, 'dataQuality'),
        modelConfidence: (json['modelConfidence'] as num?)?.toDouble() ??
            (throw const FormatException('Forecast modelConfidence is invalid.')),
        limitingResource: json['limitingResource'] == null
            ? null
            : _resource(_map(json['limitingResource'], 'limitingResource'), pointsRequired: false),
        resources: _list(json['resources'], 'resources')
            .map((item) => _resource(item, pointsRequired: true))
            .toList(growable: false),
      );

  ForecastResource _resource(Map<String, dynamic> json, {required bool pointsRequired}) {
    final rawPoints = json['points'];
    final points = rawPoints == null && !pointsRequired
        ? const <ForecastPoint>[]
        : _list(rawPoints, 'points').map(_point).toList(growable: false);
    return ForecastResource(
      resource: _text(json, 'resource'),
      providerId: json['providerId'] as String?,
      points: points,
    );
  }

  ForecastPoint _point(Map<String, dynamic> json) => ForecastPoint(
        riskBand: _text(json, 'riskBand'),
        likelyDepletionEtaMinutes: json['likelyDepletionEtaMinutes'] as int?,
      );

  Map<String, dynamic> _map(Object? value, String name) {
    if (value is! Map) throw FormatException('Forecast $name is invalid.');
    return Map<String, dynamic>.from(value);
  }

  List<Map<String, dynamic>> _list(Object? value, String name) {
    if (value is! List) throw FormatException('Forecast $name is invalid.');
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList(growable: false);
  }

  String _text(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) throw FormatException('Forecast $key is missing.');
    return value;
  }
}
