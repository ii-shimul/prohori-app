import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import 'auth_notifier.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthState>>(authNotifierProvider, (_, next) {
      if (next.value?.status == AuthStatus.unauthenticated) {
        context.go('/login');
      }
    });
    final user = ref.watch(authNotifierProvider).value?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prohori'),
        actions: [
          IconButton(tooltip: 'Inbox', onPressed: () => context.go('/inbox'), icon: const Icon(Icons.inbox_outlined)),
          IconButton(tooltip: 'Profile', onPressed: () => context.go('/profile'), icon: const Icon(Icons.person_outline)),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/splash');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined, size: 48),
              const SizedBox(height: 16),
              Text('Welcome, ${user?.email ?? 'agent'}'),
              const SizedBox(height: 8),
              const Text('Your assigned outlet is ready to review.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('View liquidity dashboard'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/alerts'),
                child: const Text('View alerts'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
