import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/locale_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../core/scope/session_scope.dart';
import '../../theme.dart';
import 'auth_notifier.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(sessionScopeProvider);
    ref.listen<AsyncValue<SessionScope>>(sessionScopeProvider, (_, next) {
      final session = next.value;
      if (session != null) {
        ref.read(localeProvider.notifier).setLocale(Locale(session.locale));
      }
    });

    final email = ref.watch(authNotifierProvider).value?.user?.email ?? 'Signed-in user';
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined),
            SizedBox(width: 8),
            Text('PROHORI', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      bottomNavigationBar: _HomeNavigation(
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              context.go('/alerts');
            case 2:
              context.go('/inbox');
            case 3:
              context.go('/profile');
          }
        },
      ),
      body: scope.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ScopeError(
          onRetry: () => ref.invalidate(sessionScopeProvider),
        ),
        data: (session) => session.outletIds.isEmpty
            ? const _NoOutletAssignment()
            : _HomeContent(email: email),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppPalette.primary,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.storefront_outlined, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Outlet command center',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppPalette.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your assigned outlet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Liquidity dashboard'),
                  subtitle: const Text('Shared cash, e-money, forecast, and constraint'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/dashboard'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Alerts'),
                  subtitle: const Text('Review alerts in your assigned scope'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/alerts'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.inbox_outlined),
                  title: const Text('Inbox'),
                  subtitle: const Text('Operational alerts and updates'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/inbox'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('Open liquidity dashboard'),
          ),
        ],
      );
}

class _NoOutletAssignment extends StatelessWidget {
  const _NoOutletAssignment();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No active outlet assignment is available for this account.',
            textAlign: TextAlign.center,
          ),
        ),
      );
}

class _ScopeError extends StatelessWidget {
  const _ScopeError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: ElevatedButton(
          onPressed: onRetry,
          child: const Text('Retry account scope'),
        ),
      );
}

class _HomeNavigation extends StatelessWidget {
  const _HomeNavigation({required this.onDestinationSelected});
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      );
}
