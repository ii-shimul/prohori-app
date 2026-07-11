class CaseTimelineEvent {
  const CaseTimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.occurredAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime? occurredAt;

  factory CaseTimelineEvent.fromJson(Map<String, dynamic> json) => CaseTimelineEvent(
        id: '${json['id'] ?? ''}',
        title: json['action'] as String? ?? json['title'] as String? ?? 'Case update',
        description: json['description'] as String? ?? json['note'] as String? ?? '',
        occurredAt: DateTime.tryParse('${json['occurredAt'] ?? json['createdAt'] ?? ''}'),
      );
}

class CaseDetail {
  const CaseDetail({required this.id, required this.status, required this.timeline});

  final String id;
  final String status;
  final List<CaseTimelineEvent> timeline;

  factory CaseDetail.fromJson(Map<String, dynamic> json, List<CaseTimelineEvent> timeline) =>
      CaseDetail(id: '${json['id'] ?? ''}', status: json['status'] as String? ?? 'OPEN', timeline: timeline);
}
