import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_cache.dart';
import '../../core/providers/app_providers.dart';
import '../../core/scope/session_scope.dart';
import '../data/outlets_api.dart';
import '../domain/outlet_catalog_item.dart';

final outletsApiProvider = Provider<OutletsApi>(
  (ref) => OutletsApi(ref.watch(apiClientProvider)),
);

final outletCatalogProvider =
    FutureProvider.autoDispose<List<OutletCatalogItem>>((ref) async {
  ref.watch(appCacheEpochProvider);
  final scope = await ref.watch(sessionScopeProvider.future);
  final allowedOutletIds = scope.outletIds.toSet();
  final catalog = await ref.watch(outletsApiProvider).fetchOutlets();

  return catalog
      .where((outlet) => allowedOutletIds.contains(outlet.id))
      .toList(growable: false);
});

class SelectedOutletId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;
}

final selectedOutletIdProvider =
    NotifierProvider<SelectedOutletId, String?>(SelectedOutletId.new);
