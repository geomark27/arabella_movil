import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/auth/providers/auth_provider.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/auth/screens/register_screen.dart';
import '../presentation/auth/screens/change_password_screen.dart';
import '../presentation/home/screens/home_screen.dart';
import '../presentation/dashboard/screens/dashboard_screen.dart';
import '../presentation/accounts/screens/accounts_screen.dart';
import '../presentation/transactions/screens/transactions_screen.dart';
import '../presentation/categories/screens/categories_screen.dart';
import '../presentation/profile/screens/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      final authState = ref.read(authProvider);

      // Mientras está inicializando, no redirigir
      if (authState.status == AuthStatus.initial) return null;

      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute =
          state.uri.path == '/login' || state.uri.path == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';

      return null;
    },
    refreshListenable: _AuthStateListenable(ref),
    routes: [
      // ── Auth routes ────────────────────────────────────────────────
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // ── App shell (Bottom Navigation) ─────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/accounts',
            builder: (context, state) => const AccountsScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
        ],
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Página no encontrada: ${state.uri.path}')),
        ),
  );
});

/// Convierte el estado de autenticación en un Listenable para GoRouter
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(ProviderRef ref) {
    ref.listen(authProvider, (_, next) {
      notifyListeners();
    });
  }
}
