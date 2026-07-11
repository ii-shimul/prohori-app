import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  const AppEnvironment._();

  static String get supabaseUrl => _value('SUPABASE_URL');
  static String get supabasePublishableKey =>
      _value('SUPABASE_PUBLISHABLE_KEY');
  static String get apiBaseUrl => _value(
        'API_BASE_URL',
        fallback: 'https://prohori-api.onrender.com/api/v1',
      );

  static void validate() {
    validateValues(
      apiBaseUrl: apiBaseUrl,
      supabaseUrl: supabaseUrl,
      supabasePublishableKey: supabasePublishableKey,
    );
  }

  /// All runtime data comes from authenticated API calls. No demo fallback.
  static void validateValues({
    required String apiBaseUrl,
    required String supabaseUrl,
    required String supabasePublishableKey,
  }) {
    final apiUri = _requireHttpUri('API_BASE_URL', apiBaseUrl);
    if (apiUri.path.replaceFirst(RegExp(r'/+$'), '') != '/api/v1') {
      throw StateError('API_BASE_URL must end with /api/v1.');
    }

    final supabaseUri = _requireHttpUri('SUPABASE_URL', supabaseUrl);
    if (supabaseUri.scheme != 'https') {
      throw StateError('SUPABASE_URL must use HTTPS.');
    }

    final key = supabasePublishableKey.trim();
    if (key.isEmpty ||
        key.startsWith('REPLACE_') ||
        key == 'your-public-anon-or-publishable-key') {
      throw StateError('SUPABASE_PUBLISHABLE_KEY is required.');
    }
  }

  static Uri _requireHttpUri(String name, String rawValue) {
    final value = rawValue.trim();
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw StateError('$name must be an absolute HTTP(S) URL.');
    }
    return uri;
  }

  static String _value(String name, {String fallback = ''}) {
    final fileValue = dotenv.env[name]?.trim();
    if (fileValue != null && fileValue.isNotEmpty) return fileValue;

    return switch (name) {
      'SUPABASE_URL' => const String.fromEnvironment('SUPABASE_URL'),
      'SUPABASE_PUBLISHABLE_KEY' =>
        const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
      'API_BASE_URL' => const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://prohori-api.onrender.com/api/v1',
        ),
      _ => fallback,
    };
  }
}
