import '../../core/network/api_client.dart';
import '../domain/outlet_catalog_item.dart';

class OutletsApi {
  OutletsApi(this._apiClient);
  final ApiClient _apiClient;

  Future<List<OutletCatalogItem>> fetchOutlets() async {
    final response = await _apiClient.get<Object>('/outlets');
    final body = response.data;
    if (body is! List) {
      throw const FormatException('GET /outlets must return a list.');
    }

    return body
        .whereType<Map>()
        .map((item) => _fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  OutletCatalogItem _fromJson(Map<String, dynamic> json) {
    final area = json['area'];
    if (area is! Map) {
      throw const FormatException('GET /outlets item is missing area.');
    }
    final areaJson = Map<String, dynamic>.from(area);
    return OutletCatalogItem(
      id: _requiredString(json, 'id'),
      code: _requiredString(json, 'code'),
      name: _requiredString(json, 'name'),
      area: OutletArea(
        id: _requiredString(areaJson, 'id'),
        code: _requiredString(areaJson, 'code'),
        name: _requiredString(areaJson, 'name'),
        parentId: _nullableString(areaJson['parentId']),
      ),
      tier: _requiredInt(json, 'tier'),
      timezone: _requiredString(json, 'timezone'),
      status: _requiredString(json, 'status'),
    );
  }

  String _requiredString(Map<String, dynamic> json, String key) {
    final value = _nullableString(json[key]);
    if (value == null) {
      throw FormatException('GET /outlets item is missing $key.');
    }
    return value;
  }

  String? _nullableString(Object? value) {
    final text = value is String ? value.trim() : null;
    return text == null || text.isEmpty ? null : text;
  }

  int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) {
      throw FormatException('GET /outlets item has an invalid $key.');
    }
    return value;
  }
}
