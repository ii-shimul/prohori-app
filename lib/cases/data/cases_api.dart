import '../../core/network/api_client.dart';
import '../domain/case_detail.dart';

class CasesApi {
  CasesApi(this._apiClient);
  final ApiClient _apiClient;

  Future<CaseDetail> fetchCase(String id) async {
    final caseRequest = _apiClient.get<Map<String, dynamic>>('/cases/$id');
    final timelineRequest = _apiClient.get<Object>('/cases/$id/timeline');
    final caseResponse = await caseRequest;
    final timelineResponse = await timelineRequest;
    final timelinePayload = timelineResponse.data;
    final items = timelinePayload is List
        ? timelinePayload
        : timelinePayload is Map<String, dynamic>
            ? timelinePayload['items'] as List? ??
                timelinePayload['data'] as List? ??
                const []
            : const [];
    return CaseDetail.fromJson(
      caseResponse.data ?? const <String, dynamic>{},
      items
          .whereType<Map>()
          .map((item) => CaseTimelineEvent.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Future<void> addNote(String caseId, String note) async {
    await _apiClient.post<void>(
      '/cases/$caseId/notes',
      data: {'note': note},
      idempotencyKey: 'case-note-$caseId-${DateTime.now().microsecondsSinceEpoch}',
    );
  }
}
