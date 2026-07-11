import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_cache.dart';
import '../../core/providers/app_providers.dart';
import '../data/outlet_dashboard_api.dart';
import '../domain/outlet_dashboard.dart';

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
