import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/scope/session_scope.dart';
import '../domain/outlet_dashboard.dart';
import 'dashboard_providers.dart';
import '../../outlets/domain/outlet_catalog_item.dart';
import '../../outlets/presentation/outlet_providers.dart';
import '../../theme.dart';

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
        error: (_, __) => _RetryView(
          label: 'Retry account scope',
          onRetry: () => ref.invalidate(sessionScopeProvider),
        ),
        data: (scope) => scope.outletIds.isEmpty
            ? const _NoOutletAssignment()
            : const _OutletCatalogDashboard(),
      ),
    );
  }
}

class _OutletCatalogDashboard extends ConsumerWidget {
  const _OutletCatalogDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outlets = ref.watch(outletCatalogProvider);
    return outlets.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _RetryView(
        label: 'Retry outlet catalog',
        onRetry: () => ref.invalidate(outletCatalogProvider),
      ),
      data: (items) {
        if (items.isEmpty) return const _NoOutletAssignment();
        final selectedId = ref.watch(selectedOutletIdProvider);
        final selectedItems = items.where((item) => item.id == selectedId);
        final selected = selectedItems.isEmpty ? items.first : selectedItems.first;
        return _OutletCatalogContent(
          outlets: items,
          selected: selected,
          onSelected: (id) => ref.read(selectedOutletIdProvider.notifier).select(id),
        );
      },
    );
  }
}

class _OutletCatalogContent extends StatelessWidget {
  const _OutletCatalogContent({
    required this.outlets,
    required this.selected,
    required this.onSelected,
  });

  final List<OutletCatalogItem> outlets;
  final OutletCatalogItem selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (outlets.length > 1) ...[
            DropdownButtonFormField<String>(
              value: selected.id,
              decoration: const InputDecoration(labelText: 'Assigned outlet'),
              items: outlets
                  .map(
                    (outlet) => DropdownMenuItem(
                      value: outlet.id,
                      child: Text(
                        outlet.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (id) {
                if (id != null) onSelected(id);
              },
            ),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selected.code} · ${selected.area.name}',
                    style: const TextStyle(color: AppPalette.inkMuted),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Status: ${selected.status}')),
                      Chip(label: Text('Tier ${selected.tier}')),
                      Chip(label: Text(selected.timezone)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _BalancesSection(outletId: selected.id),
        ],
      );
}

class _BalancesSection extends ConsumerWidget {
  const _BalancesSection({required this.outletId});
  final String outletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(outletBalancesProvider(outletId));
    return balances.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Balances could not be loaded.'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(outletBalancesProvider(outletId)),
                child: const Text('Retry balances'),
              ),
            ],
          ),
        ),
      ),
      data: (value) => _BalanceCards(balances: value),
    );
  }
}

class _BalanceCards extends StatelessWidget {
  const _BalanceCards({required this.balances});
  final OutletBalances balances;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payments_outlined),
                      SizedBox(width: 12),
                      Text(
                        'Shared physical cash',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    balances.sharedCash.formattedBdt,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppPalette.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (balances.providerEMoney.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No provider e-money balances were returned.'),
              ),
            )
          else
            ...balances.providerEMoney.map(
              (balance) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    title: Text(
                      balance.providerName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      balance.providerCode,
                      style: const TextStyle(color: AppPalette.inkMuted),
                    ),
                    trailing: Text(
                      balance.amount.formattedBdt,
                      style: const TextStyle(
                        color: AppPalette.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
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

class _RetryView extends StatelessWidget {
  const _RetryView({required this.label, required this.onRetry});
  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: ElevatedButton(onPressed: onRetry, child: Text(label)),
      );
}

class _DashboardNavigation extends StatelessWidget {
  const _DashboardNavigation({required this.onDestinationSelected});
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
