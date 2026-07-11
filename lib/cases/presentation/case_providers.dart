import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/app_cache.dart';
import '../data/cases_api.dart';
import '../domain/case_detail.dart';

final casesApiProvider = Provider<CasesApi>((ref) => CasesApi(ref.watch(apiClientProvider)));

final caseDetailProvider = FutureProvider.autoDispose.family<CaseDetail, String>((ref, caseId) {
  ref.watch(appCacheEpochProvider);
  return ref.watch(casesApiProvider).fetchCase(caseId);
});
