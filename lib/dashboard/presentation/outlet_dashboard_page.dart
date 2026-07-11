import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

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
        loading: () => const _DashboardSkeleton(),
        error: (error, _) => _DashboardError(
          onRetry: () => ref.invalidate(outletDashboardProvider(AppEnvironment.outletId)),
        ),
        data: (poll) => poll.when(
          loading: () => const _DashboardSkeleton(),
          error: (error, _) => _DashboardError(
            onRetry: () => ref.invalidate(outletDashboardProvider(AppEnvironment.outletId)),
          ),
          data: (dashboard) => TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            tween: Tween(begin: 0, end: 1),
            builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
            child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(outletDashboardProvider(AppEnvironment.outletId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Liquidity status', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(dashboard.freshness, style: const TextStyle(color: AppPalette.inkMuted)),
                const SizedBox(height: 24),
                _TelemetryCard(quality: dashboard.dataQuality),
                const SizedBox(height: 16),
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
      ),
    );
  }
}

class _TelemetryCard extends StatelessWidget {
  const _TelemetryCard({required this.quality});
  final String quality;

  @override
  Widget build(BuildContext context) {
    final normalized = quality.toLowerCase();
    final color = normalized == 'critical'
        ? AppPalette.error
        : normalized == 'degraded'
            ? AppPalette.primary
            : AppPalette.success;
    final label = normalized == 'critical'
        ? 'CRITICAL'
        : normalized == 'degraded'
            ? 'DEGRADED'
            : 'GOOD';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        border: Border.all(color: AppPalette.border, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.sensors_outlined),
        const SizedBox(width: 12),
        const Expanded(child: Text('Data telemetry', maxLines: 1, overflow: TextOverflow.ellipsis)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppPalette.surface,
        highlightColor: AppPalette.extraSurface,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _SkeletonBlock(height: 28, width: 180),
            SizedBox(height: 24),
            _SkeletonBlock(height: 150),
            SizedBox(height: 16),
            _SkeletonBlock(height: 120),
            SizedBox(height: 16),
            _SkeletonBlock(height: 76),
          ],
        ),
      );
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, this.width = double.infinity});
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      );
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
