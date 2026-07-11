import '../../core/network/api_client.dart';
import '../domain/outlet_dashboard.dart';

class OutletBalancesApi {
  OutletBalancesApi(this._apiClient);

  final ApiClient _apiClient;

  Future<OutletBalances> fetch(String outletId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/outlets/$outletId/balances',
    );
    final body = response.data;
    if (body == null) {
      throw const FormatException('GET /outlets/:id/balances returned no body.');
    }
    final balances = _fromJson(body);
    if (balances.outletId != outletId) {
      throw const FormatException('Balance response outlet does not match request.');
    }
    return balances;
  }

  OutletBalances _fromJson(Map<String, dynamic> json) {
    final sharedCash = _asMap(json['sharedCash'], 'sharedCash');
    final providerEMoney = json['providerEMoney'];
    if (providerEMoney is! List) {
      throw const FormatException('Balance response has invalid providerEMoney.');
    }

    return OutletBalances(
      outletId: _requiredString(json, 'outletId'),
      sharedCash: _money(sharedCash, expectedResource: 'shared_cash'),
      providerEMoney: providerEMoney
          .whereType<Map>()
          .map((item) => _providerBalance(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }

  ProviderEMoneyBalance _providerBalance(Map<String, dynamic> json) {
    final provider = _asMap(json['provider'], 'providerEMoney.provider');
    return ProviderEMoneyBalance(
      providerId: _requiredString(provider, 'id'),
      providerCode: _requiredString(provider, 'code'),
      providerName: _requiredString(provider, 'name'),
      amount: _money(json, expectedResource: 'provider_efloat'),
    );
  }

  MoneyAmount _money(
    Map<String, dynamic> json, {
    required String expectedResource,
  }) {
    if (_requiredString(json, 'resource') != expectedResource) {
      throw FormatException('Balance response has unexpected $expectedResource resource.');
    }
    final amount = _requiredString(json, 'amountMinor');
    if (!RegExp(r'^\d+$').hasMatch(amount)) {
      throw const FormatException('Balance amountMinor must be an integer string.');
    }
    return MoneyAmount(amountMinor: BigInt.parse(amount));
  }

  Map<String, dynamic> _asMap(Object? value, String field) {
    if (value is! Map) throw FormatException('Balance response is missing $field.');
    return Map<String, dynamic>.from(value);
  }

  String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Balance response is missing $key.');
    }
    return value.trim();
  }
}
