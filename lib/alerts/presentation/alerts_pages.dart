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
      appBar: AppBar(title: const Text('Alerts')),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(onRetry: () => ref.invalidate(alertsProvider)),
        data: (poll) => poll.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(onRetry: () => ref.invalidate(alertsProvider)),
          data: (alerts) => alerts.isEmpty
              ? const Center(child: Text('No alerts need your attention.'))
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(alertsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _AlertCard(alert: alerts[index]),
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
      appBar: AppBar(title: const Text('Alert detail')),
      body: alert.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(onRetry: () => ref.invalidate(alertDetailProvider(alertId))),
        data: (value) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AlertCard(alert: value, interactive: false),
            const SizedBox(height: 24),
            const Text('What this means', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(value.summary.isEmpty ? 'No additional detail supplied.' : value.summary),
            const SizedBox(height: 32),
            _AcknowledgeButton(alertId: alertId),
          ],
        ),
      ),
    );
  }
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
  const _AcknowledgeButton({required this.alertId});
  final String alertId;

  @override
  ConsumerState<_AcknowledgeButton> createState() => _AcknowledgeButtonState();
}

class _AcknowledgeButtonState extends ConsumerState<_AcknowledgeButton> {
  bool _submitting = false;

  Future<void> _acknowledge() async {
    setState(() => _submitting = true);
    try {
      await ref.read(alertsApiProvider).acknowledge(widget.alertId);
      if (mounted) context.go('/cases/case-${widget.alertId}');
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
