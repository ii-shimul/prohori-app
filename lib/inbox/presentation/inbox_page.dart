import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../alerts/domain/outlet_alert.dart';
import '../../alerts/presentation/alerts_providers.dart';
import '../../theme.dart';

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(alertsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.shield_outlined),
          SizedBox(width: 8),
          Text('PROHORI', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('INBOX')),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
            case 1:
              context.go('/alerts');
            case 3:
              context.go('/profile');
          }
        },
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
      ),
      body: inbox.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _InboxUnavailable(),
        data: (poll) => poll.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const _InboxUnavailable(),
          data: (items) => _InboxList(items: items),
        ),
      ),
    );
  }
}

class _InboxList extends StatelessWidget {
  const _InboxList({required this.items});
  final List<OutletAlert> items;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Operational inbox', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Alerts and updates assigned to your outlet.', style: TextStyle(color: AppPalette.inkMuted)),
          const SizedBox(height: 20),
          if (items.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Your inbox is clear.'))))
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InboxCard(alert: item),
                )),
        ],
      );
}

class _InboxCard extends StatelessWidget {
  const _InboxCard({required this.alert});
  final OutletAlert alert;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: _severityColor(alert.severity).withOpacity(0.14),
            foregroundColor: _severityColor(alert.severity),
            child: const Icon(Icons.notifications_outlined),
          ),
          title: Text(
            alert.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              alert.summary.isEmpty ? 'Open alert requires review.' : alert.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text(alert.severity),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right),
          ]),
          onTap: () => context.go('/alerts/${alert.id}'),
        ),
      );

  Color _severityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'HIGH':
      case 'CRITICAL':
        return AppPalette.error;
      case 'MEDIUM':
        return AppPalette.primary;
      default:
        return AppPalette.success;
    }
  }
}

class _InboxUnavailable extends StatelessWidget {
  const _InboxUnavailable();
  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Inbox unavailable. Check your connection and try again.'),
      );
}
