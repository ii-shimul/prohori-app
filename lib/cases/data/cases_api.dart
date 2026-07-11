import '../../core/config/app_environment.dart';
import '../../core/network/api_client.dart';
import '../domain/case_detail.dart';

class CasesApi {
  CasesApi(this._apiClient);
  final ApiClient _apiClient;
  final Map<String, List<CaseTimelineEvent>> _demoTimeline = {};

  Future<CaseDetail> fetchCase(String id) async {
    if (AppEnvironment.useDemoData) {
      final timeline = _demoTimeline.putIfAbsent(id, _initialTimeline);
      return CaseDetail(id: id, status: 'ACKNOWLEDGED', timeline: List.of(timeline));
    }
    final caseRequest = _apiClient.get<Map<String, dynamic>>('/cases/$id');
    final timelineRequest = _apiClient.get<Object>('/cases/$id/timeline');
    final caseResponse = await caseRequest;
    final timelineResponse = await timelineRequest;
    final timelinePayload = timelineResponse.data;
    final items = timelinePayload is List
        ? timelinePayload
        : timelinePayload is Map<String, dynamic>
            ? timelinePayload['items'] as List? ?? timelinePayload['data'] as List? ?? const []
            : const [];
    return CaseDetail.fromJson(
      caseResponse.data ?? const <String, dynamic>{},
      items.whereType<Map>().map((item) => CaseTimelineEvent.fromJson(Map<String, dynamic>.from(item))).toList(),
    );
  }

  Future<void> addNote(String caseId, String note) async {
    if (AppEnvironment.useDemoData) {
      _demoTimeline.putIfAbsent(caseId, _initialTimeline).add(CaseTimelineEvent(
        id: 'note-${DateTime.now().microsecondsSinceEpoch}',
        title: 'Scoped note added',
        description: note,
        occurredAt: DateTime.now(),
      ));
      return;
    }
    await _apiClient.post<void>('/cases/$caseId/notes', data: {'note': note});
  }

  List<CaseTimelineEvent> _initialTimeline() => [
        CaseTimelineEvent(
          id: 'acknowledged',
          title: 'Alert acknowledged',
          description: 'Outlet agent acknowledged this alert for review.',
          occurredAt: DateTime.now(),
        ),
      ];
}
