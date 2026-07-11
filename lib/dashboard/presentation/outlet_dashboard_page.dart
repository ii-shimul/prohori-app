import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/scope/session_scope.dart';
import '../../theme.dart';
import '../domain/outlet_dashboard.dart';
import 'dashboard_providers.dart';

class OutletDashboardPage extends ConsumerWidget {
  const OutletDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(sessionScopeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined),
            SizedBox(width: 8),
            Text('PROHORI', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Chip(
              avatar: Icon(Icons.circle, size: 10, color: AppPalette.success),
              label: Text('SYNCED'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _DashboardNavigation(
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
        error: (_, __) => _ErrorView(onRetry: () => ref.invalidate(sessionScopeProvider)),
        data: (scope) => scope.primaryOutletId == null
            ? const Center(child: Text('No outlet assignment is available.'))
            : _ScopedDashboard(outletId: scope.primaryOutletId!),
      ),
    );
  }
}

class _ScopedDashboard extends ConsumerWidget {
  const _ScopedDashboard({required this.outletId});
  final String outletId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(outletDashboardProvider(outletId));
    return dashboard.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _ErrorView(onRetry: () => ref.invalidate(outletDashboardProvider(outletId))),
      data: (poll) => poll.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorView(onRetry: () => ref.invalidate(outletDashboardProvider(outletId))),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(outletDashboardProvider(outletId)),
          child: _DashboardContent(data: data),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});
  final OutletDashboard data;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CashCard(value: data.sharedPhysicalCash, freshness: data.freshness),
          const SizedBox(height: 16),
          ...data.providerEMoneyBalances.map(
            (balance) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _EMoneyCard(balance: balance),
            ),
          ),
          const SizedBox(height: 16),
          _DepletionCard(
            summary: data.forecastSummary,
            provider: data.limitingProvider,
            etaMinutes: data.depletionEtaMinutes,
          ),
          const SizedBox(height: 16),
          _ConstraintCard(
            value: data.limitingProvider == null
                ? data.limitingResource
                : '${data.limitingProvider} e-money · ${data.depletionEtaMinutes ?? '?'} mins remaining',
          ),
          const SizedBox(height: 16),
          _TelemetryCard(quality: data.dataQuality, freshness: data.freshness),
          const SizedBox(height: 80),
        ],
      );
}

class _CashCard extends StatelessWidget {
  const _CashCard({required this.value, required this.freshness});
  final MoneyAmount value;
  final String freshness;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.payments_outlined),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Shared physical cash',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const Chip(label: Text('VAULT A')),
            ]),
            const SizedBox(height: 24),
            Text(
              '${value.currency} ${value.amount}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppPalette.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              freshness,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppPalette.inkMuted),
            ),
          ]),
        ),
      );
}

class _EMoneyCard extends StatelessWidget {
  const _EMoneyCard({required this.balance});
  final ProviderEMoneyBalance balance;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          title: Text(
            balance.provider,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'E-MONEY BALANCE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.inkMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${balance.amount.currency} ${balance.amount.amount}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppPalette.secondary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ]),
          ),
          trailing: const Chip(
            avatar: Icon(Icons.link, size: 16),
            label: Text('CONNECTED'),
          ),
        ),
      );
}

class _DepletionCard extends StatelessWidget {
  const _DepletionCard({
    required this.summary,
    required this.provider,
    required this.etaMinutes,
  });
  final String summary;
  final String? provider;
  final int? etaMinutes;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.timeline_outlined),
              title: Text(
                'Depletion horizon',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9E7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.warning_amber_rounded, color: AppPalette.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider == null || etaMinutes == null
                        ? summary
                        : '$provider may deplete in $etaMinutes mins. $summary',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
}

class _ConstraintCard extends StatelessWidget {
  const _ConstraintCard({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppPalette.extraSurface,
              child: Icon(Icons.account_balance_wallet_outlined),
            ),
            const SizedBox(height: 16),
            const Text(
              'CURRENT CONSTRAINT',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
                color: AppPalette.inkMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      );
}

class _TelemetryCard extends StatelessWidget {
  const _TelemetryCard({required this.quality, required this.freshness});
  final String quality;
  final String freshness;

  @override
  Widget build(BuildContext context) {
    final normalized = quality.toLowerCase();
    final color = normalized == 'critical'
        ? AppPalette.error
        : normalized == 'degraded'
            ? AppPalette.primary
            : AppPalette.success;
    return Card(
      color: AppPalette.surface,
      child: ListTile(
        leading: const Icon(Icons.sensors_outlined),
        title: const Text('Data telemetry'),
        subtitle: Text(freshness, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Chip(
          backgroundColor: color,
          label: Text(
            normalized.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _DashboardNavigation extends StatelessWidget {
  const _DashboardNavigation({required this.onDestinationSelected});
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: ElevatedButton(onPressed: onRetry, child: const Text('Retry dashboard')),
      );
}
