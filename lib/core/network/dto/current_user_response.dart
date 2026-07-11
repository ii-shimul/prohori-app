class OutletAssignmentDto {
  const OutletAssignmentDto({
    required this.areaId,
    required this.outletId,
    required this.providerId,
    required this.role,
  });

  final String areaId;
  final String outletId;
  final String? providerId;
  final String role;

  factory OutletAssignmentDto.fromJson(Map<String, dynamic> json) {
    return OutletAssignmentDto(
      areaId: _requiredString(json, 'areaId'),
      outletId: _requiredString(json, 'outletId'),
      providerId: _nullableString(json['providerId']),
      role: _requiredString(json, 'role'),
    );
  }
}

class ProviderMembershipDto {
  const ProviderMembershipDto({
    required this.providerId,
    required this.role,
  });

  final String providerId;
  final String role;

  factory ProviderMembershipDto.fromJson(Map<String, dynamic> json) {
    return ProviderMembershipDto(
      providerId: _requiredString(json, 'providerId'),
      role: _requiredString(json, 'role'),
    );
  }
}

class CurrentUserResponse {
  const CurrentUserResponse({
    required this.id,
    required this.locale,
    required this.memberships,
    required this.assignments,
  });

  final String id;
  final String locale;
  final List<ProviderMembershipDto> memberships;
  final List<OutletAssignmentDto> assignments;

  factory CurrentUserResponse.fromJson(Map<String, dynamic> json) {
    final locale = _requiredString(json, 'locale');
    if (locale != 'en' && locale != 'bn') {
      throw const FormatException('GET /me returned an unsupported locale.');
    }

    return CurrentUserResponse(
      id: _requiredString(json, 'id'),
      locale: locale,
      memberships: _list(json['memberships'])
          .map(ProviderMembershipDto.fromJson)
          .toList(growable: false),
      assignments: _list(json['assignments'])
          .map(OutletAssignmentDto.fromJson)
          .toList(growable: false),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _nullableString(json[key]);
  if (value == null) {
    throw FormatException('GET /me response is missing $key.');
  }
  return value;
}

String? _nullableString(Object? value) {
  final text = value is String ? value.trim() : null;
  return text == null || text.isEmpty ? null : text;
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) {
    throw const FormatException('GET /me response has an invalid list field.');
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
