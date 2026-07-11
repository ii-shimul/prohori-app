class OutletAlert {
  const OutletAlert({
    required this.id,
    required this.outletId,
    required this.type,
    required this.messageKey,
    required this.severity,
    required this.status,
    required this.active,
    required this.episodeStartedAt,
    required this.dataQuality,
    required this.modelConfidence,
    required this.evidenceSnapshots,
  });

  final String id;
  final String outletId;
  final String type;
  final String messageKey;
  final String severity;
  final String status;
  final bool active;
  final DateTime episodeStartedAt;
  final String dataQuality;
  final double modelConfidence;
  final List<AlertEvidenceSnapshot> evidenceSnapshots;

  String get title => type.replaceAll('_', ' ');
  String get summary => messageKey;
  DateTime get createdAt => episodeStartedAt;
  String? get caseId => null;

  factory OutletAlert.fromJson(Map<String, dynamic> json) {
    final message = json['message'];
    if (message is! Map) throw const FormatException('Alert message is invalid.');
    final startedAt = DateTime.tryParse(_text(json, 'episodeStartedAt'));
    if (startedAt == null) throw const FormatException('Alert episodeStartedAt is invalid.');
    final confidence = json['modelConfidence'];
    if (confidence is! num) throw const FormatException('Alert modelConfidence is invalid.');
    return OutletAlert(
      id: _text(json, 'id'),
      outletId: _text(json, 'outletId'),
      type: _text(json, 'type'),
      messageKey: _text(Map<String, dynamic>.from(message), 'key'),
      severity: _text(json, 'severity'),
      status: _text(json, 'status'),
      active: json['active'] is bool ? json['active'] as bool : (throw const FormatException('Alert active is invalid.')),
      episodeStartedAt: startedAt,
      dataQuality: _text(json, 'dataQuality'),
      modelConfidence: confidence.toDouble(),
      evidenceSnapshots: _snapshots(json['evidenceSnapshots']),
    );
  }
}

class AlertEvidenceSnapshot {
  const AlertEvidenceSnapshot({required this.kind, required this.observedAt});

  final String kind;
  final DateTime observedAt;
}

List<AlertEvidenceSnapshot> _snapshots(Object? value) {
  if (value == null) return const [];
  if (value is! List) throw const FormatException('Alert evidenceSnapshots is invalid.');
  return value.whereType<Map>().map((item) {
    final json = Map<String, dynamic>.from(item);
    final observedAt = DateTime.tryParse(_text(json, 'observedAt'));
    if (observedAt == null) throw const FormatException('Alert evidence observedAt is invalid.');
    return AlertEvidenceSnapshot(kind: _text(json, 'kind'), observedAt: observedAt);
  }).toList(growable: false);
}

String _text(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) throw FormatException('Alert $key is missing.');
  return value;
}
