import 'dart:async';

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
  Timer? _timeout;
  bool _canRetry = false;
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    _timeout = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _canRetry = true);
    });
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(authNotifierProvider, (_, next) {
      _routeWhenReady(next);
    });
    final auth = ref.watch(authNotifierProvider);
    _routeWhenReady(auth);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Restoring secure session',
                child: CircularProgressIndicator(),
              ),
              if (_canRetry) ...[
                const SizedBox(height: 24),
                const Text(
                  'Session restore is taking longer than expected.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    setState(() => _canRetry = false);
                    ref.invalidate(authNotifierProvider);
                  },
                  child: const Text('Retry session restore'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _routeWhenReady(AsyncValue<AuthState> auth) {
    if (_routed || !mounted || (!auth.hasValue && !auth.hasError)) return;
    _routed = true;
    _timeout?.cancel();
    final signedIn = auth.value?.isAuthenticated ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(signedIn ? '/home' : '/login');
    });
  }
}
