import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth/data/secure_auth_storage.dart';
import 'l10n/app_localizations.dart';
import 'core/config/app_environment.dart';
import 'core/providers/app_providers.dart';
import 'core/localization/locale_provider.dart';
import 'core/routing/routing.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
    AppEnvironment.validate();

    final secureStorage = const FlutterSecureStorage();
    final authStorage = SecureAuthStorage(secureStorage);
    await Supabase.initialize(
      url: AppEnvironment.supabaseUrl,
      publishableKey: AppEnvironment.supabasePublishableKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        localStorage: authStorage,
        pkceAsyncStorage: authStorage,
      ),
    );

    runApp(
      ProviderScope(
        overrides: [secureStorageProvider.overrideWithValue(secureStorage)],
        child: const MyApp(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('App initialization failed: $error\n$stackTrace');
    runApp(const StartupErrorApp());
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'App startup failed. Set SUPABASE_URL and '
              'SUPABASE_PUBLISHABLE_KEY in prohori-app/.env.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Prohori',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      locale: ref.watch(localeProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('bn')],
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
