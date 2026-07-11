import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    var session = _supabaseClient.auth.currentSession;
    if (session != null && _needsRefresh(session)) {
      try {
        session = (await _supabaseClient.auth.refreshSession()).session;
      } catch (_) {
        await _supabaseClient.auth.signOut();
        session = null;
      }
    }

    final token = session?.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }
    handler.next(options);
  }

  bool _needsRefresh(Session session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return !expiry.isAfter(DateTime.now().add(const Duration(minutes: 1)));
  }
}
