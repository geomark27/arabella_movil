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
import '../presentation/accounts/screens/account_form_screen.dart';
import '../presentation/accounts/screens/account_detail_screen.dart';
import '../presentation/transactions/screens/transactions_screen.dart';
import '../presentation/transactions/screens/transaction_form_screen.dart';
import '../presentation/categories/screens/categories_screen.dart';
import '../presentation/profile/screens/profile_screen.dart';
import '../presentation/splash/splash_screen.dart';
import '../data/models/account/account_model.dart';
import '../data/models/transaction/transaction_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      final authState = ref.read(authProvider);
      final path = state.uri.path;

      // Mientras inicializa, mantener en splash
      if (authState.status == AuthStatus.initial) {
        return path == '/' ? null : '/';
      }

      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = path == '/login' || path == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && (isAuthRoute || path == '/')) return '/dashboard';

      return null;
    },
    refreshListenable: _AuthStateListenable(ref),
    routes: [
      // ── Splash ────────────────────────────────────────────────────
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

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

      // ── Accounts (full-screen, sin shell) ─────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/accounts/new',
        builder: (context, state) => const AccountFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/accounts/:id',
        builder: (context, state) {
          final account = state.extra as AccountModel?;
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return AccountDetailScreen(accountId: id, account: account);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/accounts/:id/edit',
        builder: (context, state) {
          final account = state.extra as AccountModel?;
          return AccountFormScreen(account: account);
        },
      ),

      // ── Transactions (full-screen, sin shell) ──────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/transactions/new',
        builder: (context, state) => const TransactionFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/transactions/:id/edit',
        builder: (context, state) {
          final transaction = state.extra as TransactionModel?;
          return TransactionFormScreen(transaction: transaction);
        },
      ),

      // ── Shell con BottomNavigation ─────────────────────────────────
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
            path: '/categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

// ─── Auth state listenable ─────────────────────────────────────────────────

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}