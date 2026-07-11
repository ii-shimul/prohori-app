import 'dart:math';

import 'package:dio/dio.dart';

typedef CorrelationIdFactory = String Function();

class CorrelationIds {
  const CorrelationIds._();

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static String newId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static bool isValid(String value) => _uuidPattern.hasMatch(value);
}

/// Adds a trace ID to every request. Callers may provide a valid ID to retain
/// a trace across a user workflow; malformed or missing values are replaced.
class RequestMetadataInterceptor extends Interceptor {
  RequestMetadataInterceptor({CorrelationIdFactory? createCorrelationId})
      : _createCorrelationId = createCorrelationId ?? CorrelationIds.newId;

  final CorrelationIdFactory _createCorrelationId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final existing = options.headers['X-Correlation-Id'] ??
        options.headers['x-correlation-id'];
    final value = existing is String && CorrelationIds.isValid(existing)
        ? existing
        : _createCorrelationId();
    options.headers['X-Correlation-Id'] = value;
    options.headers.remove('x-correlation-id');
    handler.next(options);
  }
}
