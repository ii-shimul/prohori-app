import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_cache.dart';
import '../../core/providers/app_providers.dart';
import '../data/outlet_dashboard_api.dart';
import '../data/outlet_forecast_api.dart';
import '../data/outlet_health_api.dart';
import '../domain/outlet_dashboard.dart';
import '../domain/outlet_forecast.dart';
import '../domain/outlet_health.dart';

const _pollInterval = Duration(seconds: 30);

final outletBalancesApiProvider = Provider<OutletBalancesApi>(
  (ref) => OutletBalancesApi(ref.watch(apiClientProvider)),
);

final outletBalancesProvider = StreamProvider.autoDispose
    .family<OutletBalances, String>((ref, outletId) async* {
  ref.watch(appCacheEpochProvider);
  while (true) {
    yield await ref.read(outletBalancesApiProvider).fetch(outletId);
    await Future<void>.delayed(_pollInterval);
  }
});

final outletForecastApiProvider = Provider<OutletForecastApi>(
  (ref) => OutletForecastApi(ref.watch(apiClientProvider)),
);

final outletForecastProvider = FutureProvider.autoDispose.family<OutletForecast, String>(
  (ref, outletId) => ref.watch(outletForecastApiProvider).fetch(outletId),
);

final outletHealthApiProvider = Provider<OutletHealthApi>(
  (ref) => OutletHealthApi(ref.watch(apiClientProvider)),
);

final outletHealthProvider = FutureProvider.autoDispose.family<OutletHealth, String>(
  (ref, outletId) => ref.watch(outletHealthApiProvider).fetch(outletId),
);
