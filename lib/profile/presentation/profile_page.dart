import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/auth_notifier.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final user = ref.watch(authNotifierProvider).value?.user;
    return Scaffold(
      appBar: AppBar(title: Text(strings.profile)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(user?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 32),
        Text(strings.language, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _LanguageToggle(selected: locale, onChanged: (value) => ref.read(localeProvider.notifier).setLocale(value)),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).logout();
            if (context.mounted) context.go('/splash');
          },
          icon: const Icon(Icons.logout),
          label: Text(strings.signOut),
        ),
      ]),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.selected, required this.onChanged});
  final Locale selected;
  final ValueChanged<Locale> onChanged;
  @override
  Widget build(BuildContext context) {
    final isBangla = selected.languageCode == 'bn';
    return Semantics(
      label: 'Language selector',
      child: Container(
        height: 48,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border.all(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(8)),
        child: LayoutBuilder(builder: (context, constraints) => Stack(children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            alignment: isBangla ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(width: constraints.maxWidth / 2, margin: const EdgeInsets.all(3), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(6))),
          ),
          Row(children: [
            Expanded(child: _LanguageChoice(label: 'English', selected: !isBangla, onTap: () => onChanged(const Locale('en')))),
            Expanded(child: _LanguageChoice(label: 'বাংলা', selected: isBangla, onTap: () => onChanged(const Locale('bn')))),
          ]),
        ])),
      ),
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6), child: Center(child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), switchInCurve: Curves.elasticOut, child: Text(label, key: ValueKey(selected), style: TextStyle(color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)) )));
}
