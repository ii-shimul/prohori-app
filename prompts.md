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
commit - 3
  I'm trying to finish up Phase 4 to make Screens 8, 9, and 10 look really clean and professional, but I need some help writing the code.

For Screen 9, instead of just displaying boring text for our status, let's build a cool telemetry card with a light gray #F5F7FA background, a thin #D7DCE1 border, and show the data state as tiny colorful badges using #22A94F for good and #C23934 for critical with white text. To make the app feel premium, let's add a skeletal loading screen using Shimmer.fromColors with #F5F7FA and #EEF0F3 that smoothly fades our actual Riverpod data into view once it's finished loading. For Screen 8, let's swap out the basic list tiles in our notification inbox with minimalist cards using a #EEF0F3 background and really clean modern fonts. On Screen 10, the profile page, we need a language toggle that feels awesome to use, so let's make a sliding segmented button with a bouncy elastic animation to switch between English and Bangla instantly. Finally, I need to make sure our logout button does a complete secure cleanup, so when clicked it should call Supabase sign-out, run a deleteAll() on our secure storage so absolutely nothing is left behind, clear all our Riverpod caches, and throw the user back to the login screen.

Could you write the Dart code for these UI screens, the shimmer loader, and the secure logout logic for me?




commit-4: update the alert screen like reference design, and make that happen using plain material ui, dont use any fancy library or packages, " make sure the ui looks good

commit -5: update the profile,home,inbox,alert screen ui design only using material 3


commit -6: inject smoke test to ensure everything's alright, and provide updated audit' what we done , what need to done

commit -7: findout the gaps and missing features by compare with backend 

commit-8: we got some issue in dashboard screen, currently we got one central emoney amount but we need to show multiple provider remaining amount, fix the feature mismatch

commit 9  lets start with phase 0, complete the task, test it, and provide short review , what you did
why you are still keeping demodata? we are connecting backend for replace the static data entirely, we dont need to keep the demodata
what do you mean we need to have real supabase connection? we already have the real connection in backedn, which is prohori-api, we just using the enpoint withj a base url to replace the dummy data in frontend app
i got the real env value, i added them in backend, do i need to add them in frontned aswell? if so i got the real envs to work on and replae all the dummy data from our frontend
it worked when i flutter run with the env, but it supposed to live in the root with the .env file, so that every time i do flutter run  and try to login the app should take the env value and verify the auth" i think currently we dont installed env in app , do that for me

commit -10 we have successfully completed phase 0 , now we gonna start our phase 1, we wont keep any demo data, backend is the only source of the truth, we successfully added real supabaseurl and publishable key in .env, our auth login has been succssful as well" let's begin phase 1

commit-11 we completed phase 1 and tested properly, now we need to connect phase 1 with phase 2,3 , lets complete the phase 2 and phase 3 according our plan

commit -12 can we start our phase 4? or we reamin any unfinshed work in privious phases? if everything clear, continue with our phase works