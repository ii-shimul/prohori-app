class ApiErrorResponse {
  const ApiErrorResponse({
    required this.code,
    required this.message,
    required this.fieldErrors,
    this.correlationId,
  });

  final String code;
  final String message;
  final Map<String, List<String>> fieldErrors;
  final String? correlationId;

  factory ApiErrorResponse.fromJson(Object? value) {
    final json = value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};
    return ApiErrorResponse(
      code: '${json['code'] ?? 'API_ERROR'}',
      message: '${json['message'] ?? 'Request could not be completed.'}',
      fieldErrors: _fieldErrors(json['fieldErrors']),
      correlationId: json['correlationId'] as String?,
    );
  }

  static Map<String, List<String>> _fieldErrors(Object? value) {
    if (value is! Map) return const <String, List<String>>{};
    return Map.unmodifiable({
      for (final entry in value.entries)
        '${entry.key}': entry.value is List
            ? List.unmodifiable(entry.value.map((item) => '$item'))
            : <String>['${entry.value}'],
    });
  }
}
