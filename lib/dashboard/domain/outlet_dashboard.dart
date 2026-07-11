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

class OutletDashboard {
  const OutletDashboard({
    required this.sharedPhysicalCash,
    required this.providerEMoney,
    required this.limitingResource,
    required this.forecastSummary,
    required this.freshness,
  });

  final MoneyAmount sharedPhysicalCash;
  final MoneyAmount providerEMoney;
  final String limitingResource;
  final String forecastSummary;
  final String freshness;

  factory OutletDashboard.fromJson(
    Map<String, dynamic> balances,
    Map<String, dynamic> forecast,
  ) {
    return OutletDashboard(
      sharedPhysicalCash: MoneyAmount.fromJson(
        balances['sharedPhysicalCash'] ?? balances['physicalCash'],
      ),
      providerEMoney: MoneyAmount.fromJson(
        balances['providerEMoney'] ?? balances['eMoney'],
      ),
      limitingResource: forecast['limitingResource'] as String? ??
          balances['limitingResource'] as String? ??
          'No limiting resource reported.',
      forecastSummary: forecast['summary'] as String? ??
          forecast['message'] as String? ??
          'No forecast summary reported.',
      freshness: forecast['freshness'] as String? ??
          balances['freshness'] as String? ??
          'Latest API refresh',
    );
  }
}
