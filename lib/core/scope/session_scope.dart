import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../providers/app_providers.dart';

class SessionScope {
  const SessionScope({
    required this.userId,
    required this.role,
    required this.outletIds,
  });

  final String userId;
  final String role;
  final List<String> outletIds;

  String? get primaryOutletId => outletIds.isEmpty ? null : outletIds.first;

  factory SessionScope.fromJson(Map<String, dynamic> json) {
    final ids = json['assignedOutletIds'] ?? json['outletIds'] ?? const [];
    return SessionScope(
      userId: '${json['id'] ?? json['userId'] ?? ''}',
      role: '${json['role'] ?? ''}',
      outletIds: ids is List ? ids.map((id) => '$id').toList(growable: false) : const [],
    );
  }
}

class SessionScopeApi {
  SessionScopeApi(this._apiClient);
  final ApiClient _apiClient;

  Future<SessionScope> fetch() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/me');
    return SessionScope.fromJson(response.data ?? const <String, dynamic>{});
  }
}

final sessionScopeProvider = FutureProvider.autoDispose<SessionScope>((ref) {
  return SessionScopeApi(ref.watch(apiClientProvider)).fetch();
});
