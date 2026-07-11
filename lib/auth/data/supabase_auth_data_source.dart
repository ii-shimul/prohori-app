import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../domain/auth_user.dart';

class SupabaseAuthDataSource {
  SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  Stream<AuthUser?> get authStateChanges => _client.auth.onAuthStateChange.map(
        (state) => _toAuthUser(state.session?.user),
      );

  AuthUser? get currentUser => _toAuthUser(_client.auth.currentUser);

  Future<AuthUser?> restoreSessionUser() async {
    var session = _client.auth.currentSession;
    if (session == null) return null;

    if (_needsRefresh(session)) {
      try {
        session = (await _client.auth.refreshSession()).session;
      } catch (_) {
        await _client.auth.signOut();
        return null;
      }
    }
    return _toAuthUser(session?.user);
  }

  Future<AuthUser> signInWithSeededCredentials({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = _toAuthUser(response.user);
    if (user == null) throw StateError('Supabase did not return an authenticated user.');
    return user;
  }

  Future<void> signOut() => _client.auth.signOut();

  bool _needsRefresh(Session session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return !expiry.isAfter(DateTime.now().add(const Duration(minutes: 1)));
  }

  AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(id: user.id, email: user.email);
  }
}
