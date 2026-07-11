class MoneyAmount {
  const MoneyAmount({required this.amountMinor});

  final BigInt amountMinor;

  String get formattedBdt {
    final digits = amountMinor.toString();
    final groups = <String>[];
    for (var end = digits.length; end > 0; end -= 3) {
      groups.add(digits.substring(end < 3 ? 0 : end - 3, end));
    }
    return 'BDT ${groups.reversed.join(',')}';
  }
}

class ProviderEMoneyBalance {
  const ProviderEMoneyBalance({
    required this.providerId,
    required this.providerCode,
    required this.providerName,
    required this.amount,
  });

  final String providerId;
  final String providerCode;
  final String providerName;
  final MoneyAmount amount;
}

class OutletBalances {
  const OutletBalances({
    required this.outletId,
    required this.sharedCash,
    required this.providerEMoney,
  });

  final String outletId;
  final MoneyAmount sharedCash;
  final List<ProviderEMoneyBalance> providerEMoney;
}
