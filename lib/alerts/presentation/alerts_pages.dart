import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import '../domain/outlet_alert.dart';
import 'alerts_providers.dart';

class AlertListPage extends ConsumerWidget {
  const AlertListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(alertsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.shield_outlined),
          SizedBox(width: 8),
          Text('PROHORI', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Center(child: Text('ALERTS')))],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/dashboard');
            case 2: context.go('/inbox');
            case 3: context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(onRetry: () => ref.invalidate(alertsProvider)),
        data: (poll) => poll.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(onRetry: () => ref.invalidate(alertsProvider)),
          data: (alerts) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(alertsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Active alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Review alerts for your assigned outlet.', style: TextStyle(color: AppPalette.inkMuted)),
                const SizedBox(height: 20),
                if (alerts.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No alerts need your attention.'))))
                else
                  ...alerts.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _AlertCard(alert: item))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlertDetailPage extends ConsumerWidget {
  const AlertDetailPage({super.key, required this.alertId});
  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(alertDetailProvider(alertId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to alerts',
          onPressed: () => context.go('/alerts'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Alert: ${alert.value?.title ?? 'Details'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: alert.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          onRetry: () => ref.invalidate(alertDetailProvider(alertId)),
        ),
        data: (value) => _AlertEvidencePage(alert: value, alertId: alertId),
      ),
    );
  }
}

class _AlertEvidencePage extends StatelessWidget {
  const _AlertEvidencePage({required this.alert, required this.alertId});
  final OutletAlert alert;
  final String alertId;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppPalette.canvas,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _AcknowledgeButton(alertId: alertId, caseId: alert.caseId),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _SeverityBadge(severity: alert.severity),
                Text(
                  'Detected: ${_timeLabel(alert.createdAt)}',
                  style: const TextStyle(color: AppPalette.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 24),
            _EvidenceCard(
              icon: Icons.description_outlined,
              title: 'Situation summary',
              child: Text(
                alert.summary.isEmpty
                    ? 'This alert needs review by the assigned outlet agent.'
                    : alert.summary,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            const _EvidenceCard(
              icon: Icons.fact_check_outlined,
              title: 'Evidence',
              child: Text(
                'Backend evidence will appear here when alert-detail mapping is connected.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      );

  String _timeLabel(DateTime? value) {
    if (value == null) return 'recently';
    final elapsed = DateTime.now().difference(value).inMinutes;
    return elapsed <= 1 ? 'just now' : '$elapsed mins ago';
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            child,
          ]),
        ),
      );
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, this.interactive = true});
  final OutletAlert alert;
  final bool interactive;

  @override
  Widget build(BuildContext context) => Card(
        color: AppPalette.extraSurface,
        child: InkWell(
          onTap: interactive ? () => context.go('/alerts/${alert.id}') : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(
                    alert.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _SeverityBadge(severity: alert.severity),
              ]),
              const SizedBox(height: 8),
              Text(
                alert.summary.isEmpty ? 'Open alert' : alert.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text('${alert.status} · ${alert.createdAt?.toLocal().toString() ?? 'Time unavailable'}', style: const TextStyle(color: AppPalette.inkMuted)),
            ]),
          ),
        ),
      );
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});
  final String severity;
  @override
  Widget build(BuildContext context) => Text(severity, style: TextStyle(color: severity == 'HIGH' ? AppPalette.error : AppPalette.inkMuted, fontWeight: FontWeight.w700));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child: ElevatedButton(onPressed: onRetry, child: const Text('Retry alerts')));
}

class _AcknowledgeButton extends ConsumerStatefulWidget {
  const _AcknowledgeButton({required this.alertId, required this.caseId});
  final String alertId;
  final String? caseId;

  @override
  ConsumerState<_AcknowledgeButton> createState() => _AcknowledgeButtonState();
}

class _AcknowledgeButtonState extends ConsumerState<_AcknowledgeButton> {
  bool _submitting = false;

  Future<void> _acknowledge() async {
    setState(() => _submitting = true);
    try {
      await ref.read(alertsApiProvider).acknowledge(widget.alertId);
      if (mounted && widget.caseId != null) context.go('/cases/${widget.caseId}');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.actionFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: strings.acknowledgeAlert,
      child: ElevatedButton(
        onPressed: _submitting ? null : _acknowledge,
        child: _submitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(strings.acknowledgeAlert, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
