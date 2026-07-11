class AppEnvironment {
  const AppEnvironment._();

  static const useDemoData = true;
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://demo.supabase.co',
  );
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'demo-publishable-key',
  );
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://demo.invalid',
  );
  static const outletId = String.fromEnvironment(
    'OUTLET_ID',
    defaultValue: 'demo-outlet',
  );

  static void validate() {}
}
