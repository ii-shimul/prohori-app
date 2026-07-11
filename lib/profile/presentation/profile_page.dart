import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/auth_notifier.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final user = ref.watch(authNotifierProvider).value?.user;
    final email = user?.email ?? 'agent@prohori.demo';
    final name = email.startsWith('agent@') ? 'Outlet Agent' : email.split('@').first;

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
            child: Center(child: Text('ID: 4829 | DHAKA')),
          ),
        ],
      ),
      bottomNavigationBar: _ProfileNavigation(
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
            case 1:
              context.go('/alerts');
            case 2:
              context.go('/inbox');
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          _IdentityCard(name: name, email: email),
          const SizedBox(height: 24),
          Card(
            child: Column(children: [
              const _StaticSettingRow(
                icon: Icons.sync_outlined,
                title: 'Data freshness',
                value: 'Last sync: just now',
              ),
              const Divider(height: 1),
              _LanguageRow(
                locale: locale,
                onChanged: (value) => ref
                    .read(localeProvider.notifier)
                    .setLocale(Locale(value)),
              ),
              const Divider(height: 1),
              const _StaticSettingRow(
                icon: Icons.shield_outlined,
                title: 'Security',
                value: 'PKCE session active',
                valueColor: AppPalette.success,
              ),
              const Divider(height: 1),
              const _StaticSettingRow(
                icon: Icons.manage_accounts_outlined,
                title: 'Account settings',
                trailing: Icon(Icons.chevron_right),
              ),
            ]),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go('/splash');
              },
              icon: const Icon(Icons.logout),
              label: Text(strings.signOut),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.name, required this.email});
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              child: Text(
                _initials(name),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Chip(label: Text('OUTLET_AGENT')),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      );

  String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    return words.take(2).map((word) => word.isEmpty ? '' : word[0].toUpperCase()).join();
  }
}

class _StaticSettingRow extends StatelessWidget {
  const _StaticSettingRow({
    required this.icon,
    required this.title,
    this.value,
    this.valueColor,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String? value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
        minVerticalPadding: 16,
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        trailing: trailing ??
            (value == null
                ? null
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      value!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(color: valueColor ?? AppPalette.inkMuted),
                    ),
                  )),
      );
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.locale, required this.onChanged});
  final Locale locale;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
        minVerticalPadding: 12,
        leading: const Icon(Icons.language_outlined),
        title: const Text('Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        trailing: SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'en', label: Text('English')),
            ButtonSegment(value: 'bn', label: Text('বাংলা')),
          ],
          selected: {locale.languageCode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      );
}

class _ProfileNavigation extends StatelessWidget {
  const _ProfileNavigation({required this.onDestinationSelected});
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: 3,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      );
}
