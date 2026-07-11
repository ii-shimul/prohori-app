import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../alerts/presentation/alerts_pages.dart';
import '../../cases/presentation/case_detail_page.dart';
import '../../inbox/presentation/inbox_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../auth/presentation/home_page.dart';
import '../../dashboard/presentation/outlet_dashboard_page.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/presentation/splash_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const OutletDashboardPage(),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertListPage(),
      ),
      GoRoute(
        path: '/alerts/:id',
        builder: (context, state) => AlertDetailPage(alertId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/cases/:id',
        builder: (context, state) => CaseDetailPage(caseId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/inbox', builder: (context, state) => const InboxPage()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    ],
  );
});
