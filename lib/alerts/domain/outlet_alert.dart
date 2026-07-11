class OutletAlert {
  const OutletAlert({
    required this.id,
    required this.title,
    required this.summary,
    required this.severity,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String title;
  final String summary;
  final String severity;
  final String status;
  final DateTime? createdAt;

  factory OutletAlert.fromJson(Map<String, dynamic> json) => OutletAlert(
        id: '${json['id'] ?? ''}',
        title: json['title'] as String? ?? json['type'] as String? ?? 'Outlet alert',
        summary: json['summary'] as String? ?? json['message'] as String? ?? '',
        severity: json['severity'] as String? ?? 'UNKNOWN',
        status: json['status'] as String? ?? 'OPEN',
        createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      );
}
