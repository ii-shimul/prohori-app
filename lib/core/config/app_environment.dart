class AppEnvironment {
  const AppEnvironment._();

  static const useDemoData = bool.fromEnvironment(
    'USE_DEMO_DATA',
    defaultValue: true,
  );
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
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );
  /// Demo-only. Live outlet scope must come from authenticated `GET /me`.
  static const demoOutletId = String.fromEnvironment(
    'DEMO_OUTLET_ID',
    defaultValue: 'demo-outlet',
  );

  static void validate() {}
}
