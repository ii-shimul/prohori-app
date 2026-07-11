import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../data/alerts_api.dart';
import '../domain/outlet_alert.dart';

const _alertsPollInterval = Duration(seconds: 30);

final alertsApiProvider = Provider<AlertsApi>((ref) => AlertsApi(ref.watch(apiClientProvider)));

final alertsProvider = StreamProvider.autoDispose<AsyncValue<List<OutletAlert>>>((ref) async* {
  while (true) {
    try {
      yield AsyncData(await ref.read(alertsApiProvider).fetchAlerts());
    } catch (error, stackTrace) {
      yield AsyncError(error, stackTrace);
    }
    await Future<void>.delayed(_alertsPollInterval);
  }
});

final alertDetailProvider = FutureProvider.autoDispose.family<OutletAlert, String>((ref, id) {
  return ref.watch(alertsApiProvider).fetchAlert(id);
});
