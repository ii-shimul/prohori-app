import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/app_cache.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

enum AuthStatus { authenticated, unauthenticated, loading, failure }

class AuthState {
  const AuthState._({required this.status, this.user, this.error});

  const AuthState.authenticated(AuthUser user)
      : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);
  const AuthState.loading(AuthUser? user)
      : this._(status: AuthStatus.loading, user: user);
  const AuthState.failure(Object error)
      : this._(status: AuthStatus.failure, error: error);

  final AuthStatus status;
  final AuthUser? user;
  final Object? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final AuthRepository _repository;
  StreamSubscription<AuthUser?>? _subscription;

  @override
  Future<AuthState> build() async {
    _repository = ref.watch(authRepositoryProvider);
    _subscription = _repository.authStateChanges.listen(_onAuthChanged);
    ref.onDispose(() => _subscription?.cancel());

    final user = await _repository.restoreSessionUser();
    return user == null
        ? const AuthState.unauthenticated()
        : AuthState.authenticated(user);
  }

  Future<void> login({required String email, required String password}) async {
    state = AsyncData(AuthState.loading(state.value?.user));
    try {
      state = AsyncData(AuthState.authenticated(
        await _repository.login(email: email, password: password),
      ));
    } catch (error) {
      state = AsyncData(AuthState.failure(error));
      rethrow;
    }
  }

  Future<void> logout() async {
    state = AsyncData(AuthState.loading(state.value?.user));
    try {
      await _repository.logout();
      ref.read(appCacheEpochProvider.notifier).clear();
      state = const AsyncData(AuthState.unauthenticated());
    } catch (error) {
      state = AsyncData(AuthState.failure(error));
      rethrow;
    }
  }

  void _onAuthChanged(AuthUser? user) {
    state = AsyncData(user == null
        ? const AuthState.unauthenticated()
        : AuthState.authenticated(user));
  }
}
