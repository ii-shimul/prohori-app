import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_environment.dart';
import '../../theme.dart';
import '../domain/outlet_dashboard.dart';
import 'dashboard_providers.dart';

class OutletDashboardPage extends ConsumerWidget {
  const OutletDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(outletDashboardProvider(AppEnvironment.outletId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outlet overview'),
        actions: [
          IconButton(
            tooltip: 'Alerts',
            onPressed: () => context.go('/alerts'),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DashboardError(
          onRetry: () => ref.invalidate(outletDashboardProvider(AppEnvironment.outletId)),
        ),
        data: (poll) => poll.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _DashboardError(
            onRetry: () => ref.invalidate(outletDashboardProvider(AppEnvironment.outletId)),
          ),
          data: (dashboard) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(outletDashboardProvider(AppEnvironment.outletId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Liquidity status', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(dashboard.freshness, style: const TextStyle(color: AppPalette.inkMuted)),
                const SizedBox(height: 24),
                _CashCard(value: dashboard.sharedPhysicalCash),
                const SizedBox(height: 16),
                _EMoneyCard(value: dashboard.providerEMoney),
                const SizedBox(height: 24),
                _InsightCard(
                  title: 'Limiting resource',
                  icon: Icons.warning_amber_outlined,
                  value: dashboard.limitingResource,
                ),
                const SizedBox(height: 12),
                _InsightCard(
                  title: 'Forecast',
                  icon: Icons.schedule_outlined,
                  value: dashboard.forecastSummary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CashCard extends StatelessWidget {
  const _CashCard({required this.value});
  final MoneyAmount value;

  @override
  Widget build(BuildContext context) => Card(
        color: AppPalette.primary,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Shared physical cash', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            Text('${value.currency} ${value.amount}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _EMoneyCard extends StatelessWidget {
  const _EMoneyCard({required this.value});
  final MoneyAmount value;

  @override
  Widget build(BuildContext context) => Card(
        color: AppPalette.secondary,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Provider e-money', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            Text('${value.currency} ${value.amount}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.icon, required this.value});
  final String title;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(value)),
      );
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Could not load outlet liquidity. Check API connection and outlet assignment.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ]),
        ),
      );
}
