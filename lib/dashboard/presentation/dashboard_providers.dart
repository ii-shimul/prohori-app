import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/app_cache.dart';
import '../data/outlet_dashboard_api.dart';
import '../domain/outlet_dashboard.dart';

const _pollInterval = Duration(seconds: 30);

final outletDashboardApiProvider = Provider<OutletDashboardApi>((ref) {
  return OutletDashboardApi(ref.watch(apiClientProvider));
});

final outletDashboardProvider = StreamProvider.autoDispose
    .family<AsyncValue<OutletDashboard>, String>((ref, outletId) async* {
  ref.watch(appCacheEpochProvider);
  while (true) {
    try {
      final dashboard = await ref.read(outletDashboardApiProvider).fetch(outletId);
      yield AsyncData(dashboard);
    } catch (error, stackTrace) {
      yield AsyncError(error, stackTrace);
    }
    await Future<void>.delayed(_pollInterval);
  }
});
