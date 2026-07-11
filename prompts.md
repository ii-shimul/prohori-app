commit-1: Theme Engine & Global Design Tokens
Context: Flutter stable, Material 3 underlying architecture, custom theme configuration using a precise corporate palette.
Task:
Create a global theme configuration file (theme.dart) that overrides Material 3’s default tonal generation. You must explicitly map the following hex codes into a strict ColorScheme and ThemeData:

Primary Brand Colors: primary: #003087, onPrimary: #ffffff, secondary: #009CDE, onSecondary: #ffffff.

Action & UI Surface Colors: error: #C23934, surface: #F5F7FA (Surface 1), scaffoldBackgroundColor: #ffffff (Canvas).

Typography & Borders: Use #2C2E2F (Ink) for primary body text, #687173 (Ink-muted) for subtext/captions, and #D7DCE1 for all dividers/card outlines.

Shape Constraints: Material 3 uses large 28dp rounded corners by default. Override this globally. All CardTheme, DialogTheme, ButtonTheme, and InputDecorationTheme must enforce a rigid, flat geometric layout with a maximum borderRadius of 8.0 or 12.0 to match the PayPal design system aesthetic.

Component Overrides: Define ElevatedButtonThemeData for the Call-To-Action (CTA) elements using background color #FFD140 (CTA-gold) and foreground text color #003087 (On-CTA). Ensure all buttons have an interactive splash state that darkens to #002070 for primary components.
Output: Provide the complete, production-ready ThemeData configuration class along with custom extension properties for the extra surface (#EEF0F3) and success (#22A94F) states.

 commit-2: Setup a Flutter core layer using Riverpod, Supabase with PKCE flow, Dio, and flutter_secure_storage. Write an AuthRepository and an AsyncNotifier provider managing the auth state with login and logout functions. Use flutter_secure_storage exclusively for session persistence, ensuring SharedPreferences is completely avoided and that logout explicitly fires a clear or delete-all command to wipe the storage database clean. Build a Dio client provider equipped with a custom interceptor that dynamically pulls the current Supabase session token on every outgoing request to inject it into the Authorization Bearer header for a NestJS backend. Deliver the complete Dart files containing isolated providers for supabaseClientProvider, secureStorageProvider, dioClientProvider, and authNotifierProvider alongside the repo and interceptor implementations.

  I'm working on Phase 3 for our prohori-app screens 6 and 7 right now. Can you drop the code modules for this? On the Alert Detail screen, make sure there is exactly one clean action element showing, either the main acknowledge button styled with our specific yellow color code #FFD140 or a clean text link to hit up operations if it isn't active. Double check that you keep any kind of wallet transfers, financial controls, or balance adjustment stuff completely out of this layout because it is a strict guardrail. Make sure you hook up the button and note forms to hit our NestJS api backend endpoints via Dio using POST /alerts/:id/acknowledge and POST /cases/:id/notes. Also create our local translation system using standard ARB configuration setup containing strings for English and Bangla. For the UI protection, make sure all our text widgets handling language variables are safely wrapped in Flexible or SingleChildScrollView layouts with explicit TextOverflow.ellipsis properties so that long Bangla character rendering on lower-end emulators never clips or breaks our grid. Let's make this UI look dark, ultra clean, and consistent with our team architecture plan so we don't mess up the pipeline.