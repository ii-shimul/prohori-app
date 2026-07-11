class MoneyAmount {
  const MoneyAmount({required this.amount, required this.currency});

  final num amount;
  final String currency;

  factory MoneyAmount.fromJson(Object? value) {
    final json = value is Map<String, dynamic> ? value : <String, dynamic>{};
    final amount = json['amount'] ?? json['value'] ?? value;
    return MoneyAmount(
      amount: amount is num ? amount : num.tryParse('$amount') ?? 0,
      currency: json['currency'] as String? ?? 'BDT',
    );
  }
}

class ProviderEMoneyBalance {
  const ProviderEMoneyBalance({required this.provider, required this.amount});

  final String provider;
  final MoneyAmount amount;

  factory ProviderEMoneyBalance.fromJson(Map<String, dynamic> json) {
    return ProviderEMoneyBalance(
      provider: '${json['provider'] ?? json['providerName'] ?? 'Provider'}',
      amount: MoneyAmount.fromJson(json['balance'] ?? json['amount']),
    );
  }
}

class OutletDashboard {
  const OutletDashboard({
    required this.sharedPhysicalCash,
    required this.providerEMoneyBalances,
    required this.limitingResource,
    required this.forecastSummary,
    required this.freshness,
    required this.dataQuality,
    this.limitingProvider,
    this.depletionEtaMinutes,
  });

  final MoneyAmount sharedPhysicalCash;
  final List<ProviderEMoneyBalance> providerEMoneyBalances;
  final String limitingResource;
  final String forecastSummary;
  final String freshness;
  final String dataQuality;
  final String? limitingProvider;
  final int? depletionEtaMinutes;

  factory OutletDashboard.fromJson(
    Map<String, dynamic> balances,
    Map<String, dynamic> forecast,
  ) {
    return OutletDashboard(
      sharedPhysicalCash: MoneyAmount.fromJson(
        balances['sharedPhysicalCash'] ?? balances['physicalCash'],
      ),
      providerEMoneyBalances: _providerBalances(balances),
      limitingResource: forecast['limitingResource'] as String? ??
          balances['limitingResource'] as String? ??
          'No limiting resource reported.',
      forecastSummary: forecast['summary'] as String? ??
          forecast['message'] as String? ??
          'No forecast summary reported.',
      freshness: forecast['freshness'] as String? ??
          balances['freshness'] as String? ??
          'Latest API refresh',
      dataQuality: forecast['dataQuality'] as String? ??
          balances['dataQuality'] as String? ??
          'good',
      limitingProvider: forecast['limitingProvider'] as String?,
      depletionEtaMinutes: _asInt(forecast['depletionEtaMinutes']),
    );
  }

  static List<ProviderEMoneyBalance> _providerBalances(
    Map<String, dynamic> balances,
  ) {
    final raw = balances['providerEMoneyBalances'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => ProviderEMoneyBalance.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false);
    }
    final legacy = balances['providerEMoney'] ?? balances['eMoney'];
    return legacy == null
        ? const []
        : [
            ProviderEMoneyBalance(
              provider: 'Provider e-money',
              amount: MoneyAmount.fromJson(legacy),
            ),
          ];
  }

  static int? _asInt(Object? value) => value is int
      ? value
      : value is num
          ? value.toInt()
          : int.tryParse('$value');
}
