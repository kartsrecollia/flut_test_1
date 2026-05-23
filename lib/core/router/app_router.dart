import 'package:go_router/go_router.dart';
import '../../data/repositories/i_auth_repository.dart';
import '../../presentation/auth/pages/login_page.dart';
import '../../presentation/home/pages/home_page.dart';
import '../../presentation/onboarding/pages/onboarding_page.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  final IAuthRepository _authRepository;
  final bool _hasSeenOnboarding;
  late final GoRouterRefreshStream _refreshListenable;

  AppRouter(this._authRepository, {bool hasSeenOnboarding = false})
      : _hasSeenOnboarding = hasSeenOnboarding {
    _refreshListenable =
        GoRouterRefreshStream(_authRepository.authStateStream);
  }

  late final GoRouter router = GoRouter(
    // If onboarding was already seen, land on login; otherwise show onboarding.
    initialLocation: _hasSeenOnboarding ? '/login' : '/onboarding',
    refreshListenable: _refreshListenable,
    redirect: (context, state) {
      final loggedIn = _authRepository.currentUser != null;
      final path     = state.uri.path;

      // Authenticated users never stay on auth/onboarding screens.
      if (loggedIn && (path == '/login' || path == '/onboarding')) {
        return '/home';
      }

      // Unauthenticated users can only be on /login or /onboarding.
      if (!loggedIn && path != '/login' && path != '/onboarding') {
        return _hasSeenOnboarding ? '/login' : '/onboarding';
      }

      return null; // no redirect needed
    },
    routes: [
      GoRoute(
        path:    '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path:    '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path:    '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );

  void dispose() => _refreshListenable.dispose();
}
