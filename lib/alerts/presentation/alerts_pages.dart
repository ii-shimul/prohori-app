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
      appBar: AppBar(
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
            child: _AcknowledgeButton(alertId: alertId),
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
            _VelocityCard(severity: alert.severity),
            const SizedBox(height: 16),
            _ContextCard(
              icon: Icons.psychology_outlined,
              title: 'AI context',
              accent: const Color(0xFFC9D5EE),
              child: const Text(
                'Possible normal explanation: activity may be approaching a known local market peak. Review recent outlet context before escalation.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            _ContextCard(
              icon: Icons.verified_user_outlined,
              title: 'Recommendation',
              accent: AppPalette.success,
              fill: const Color(0xFFE5F6F4),
              child: const Text(
                'Safe action: verify the physical cash count and confirm the next batch with authorized operations.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            const _FlaggedTransactions(),
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

class _VelocityCard extends StatelessWidget {
  const _VelocityCard({required this.severity});
  final String severity;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.bar_chart_outlined),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Velocity context',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Confidence', style: TextStyle(color: AppPalette.inkMuted)),
                Text('94%', style: TextStyle(color: AppPalette.success, fontSize: 24, fontWeight: FontWeight.w800)),
              ]),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  _Bar(height: 38, label: 'T-4'),
                  _Bar(height: 58, label: 'T-3'),
                  _Bar(height: 50, label: 'T-2'),
                  _Bar(height: 78, label: 'T-1'),
                  _Bar(height: 128, label: 'NOW', critical: true),
                ],
              ),
            ),
            const Divider(),
            const Wrap(spacing: 16, children: [
              _Legend(color: AppPalette.border, label: 'Baseline average'),
              _Legend(color: AppPalette.error, label: 'Actual velocity'),
            ]),
          ]),
        ),
      );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.label, this.critical = false});
  final double height;
  final String label;
  final bool critical;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            height: height,
            width: 38,
            decoration: BoxDecoration(
              color: critical ? AppPalette.error : AppPalette.border,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: critical ? AppPalette.error : AppPalette.inkMuted, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 7, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label),
      ]);
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.icon, required this.title, required this.accent, required this.child, this.fill});
  final IconData icon;
  final String title;
  final Color accent;
  final Color? fill;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
        color: fill,
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: accent, width: 4))),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, color: accent), const SizedBox(width: 8), Text(title.toUpperCase(), style: TextStyle(color: accent, fontWeight: FontWeight.w800, letterSpacing: 1.1))]),
            const SizedBox(height: 12),
            child,
          ]),
        ),
      );
}

class _FlaggedTransactions extends StatelessWidget {
  const _FlaggedTransactions();
  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text('Flagged transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [DataColumn(label: Text('Time')), DataColumn(label: Text('Amount')), DataColumn(label: Text('Ref'))],
              rows: const [
                DataRow(cells: [DataCell(Text('10:14 AM')), DataCell(Text('BDT 19,000')), DataCell(Text('TXN-882A'))]),
                DataRow(cells: [DataCell(Text('10:12 AM')), DataCell(Text('BDT 19,000')), DataCell(Text('TXN-881F'))]),
                DataRow(cells: [DataCell(Text('10 earlier transactions')), DataCell(Text('')), DataCell(Text(''))]),
              ],
            ),
          ),
        ]),
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
