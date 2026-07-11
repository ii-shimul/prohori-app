import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import 'auth_notifier.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _routed = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(authNotifierProvider, (_, next) {
      _route(next);
    });
    _route(ref.watch(authNotifierProvider));

    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'Restoring secure session',
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void _route(AsyncValue<AuthState> auth) {
    if (_routed || !mounted || !auth.hasValue) return;
    _routed = true;
    final path = auth.requireValue.isAuthenticated ? '/home' : '/login';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(path);
    });
  }
}
