import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/dto/current_user_response.dart';
import '../providers/app_cache.dart';
import '../providers/app_providers.dart';

class SessionScope {
  const SessionScope({
    required this.userId,
    required this.locale,
    required this.memberships,
    required this.assignments,
  });

  final String userId;
  final String locale;
  final List<ProviderMembershipDto> memberships;
  final List<OutletAssignmentDto> assignments;

  List<String> get outletIds => assignments
      .map((assignment) => assignment.outletId)
      .toSet()
      .toList(growable: false);

  String? get primaryOutletId => outletIds.isEmpty ? null : outletIds.first;

  factory SessionScope.fromResponse(CurrentUserResponse response) {
    return SessionScope(
      userId: response.id,
      locale: response.locale,
      memberships: response.memberships,
      assignments: response.assignments,
    );
  }
}

class SessionScopeApi {
  SessionScopeApi(this._apiClient);
  final ApiClient _apiClient;

  Future<SessionScope> fetch() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/me');
    final body = response.data;
    if (body == null) {
      throw const FormatException('GET /me returned an empty response.');
    }
    return SessionScope.fromResponse(CurrentUserResponse.fromJson(body));
  }
}

final sessionScopeProvider = FutureProvider.autoDispose<SessionScope>((ref) {
  ref.watch(appCacheEpochProvider);
  return SessionScopeApi(ref.watch(apiClientProvider)).fetch();
});
