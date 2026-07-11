import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../core/config/app_environment.dart';
import '../domain/auth_user.dart';

class SupabaseAuthDataSource {
  SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  Stream<AuthUser?> get authStateChanges => AppEnvironment.useDemoData
      ? const Stream.empty()
      : _client.auth.onAuthStateChange.map(
          (state) => _toAuthUser(state.session?.user),
        );

  AuthUser? get currentUser =>
      AppEnvironment.useDemoData ? null : _toAuthUser(_client.auth.currentUser);

  Future<AuthUser> signInWithSeededCredentials({
    required String email,
    required String password,
  }) async {
    if (AppEnvironment.useDemoData) {
      return AuthUser(id: 'demo-agent', email: email);
    }
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = _toAuthUser(response.user);
    if (user == null) throw StateError('Supabase did not return an authenticated user.');
    return user;
  }

  Future<void> signOut() =>
      AppEnvironment.useDemoData ? Future.value() : _client.auth.signOut();

  AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(id: user.id, email: user.email);
  }
}
