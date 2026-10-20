import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/auth_state.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/unauthorized_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/orders/cubit/orders_cubit.dart';
import '../../features/orders/pages/orders_page.dart';
import '../../services/order_service.dart';
import '../widgets/admin_shell.dart';
import '../widgets/section_placeholder.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/splash';
  static const login = '/login';
  static const unauthorized = '/unauthorized';
  static const dashboard = '/dashboard';
}

/// Re-runs the router redirect whenever the auth state changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

GoRoute _section(String path, Widget page) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => NoTransitionPage(child: page),
  );
}

GoRouter buildRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: _AuthRefresh(authCubit.stream),
    redirect: (context, state) {
      final status = authCubit.state.status;
      final loc = state.matchedLocation;

      switch (status) {
        case AuthStatus.unknown:
          return loc == AppRoutes.splash ? null : AppRoutes.splash;
        case AuthStatus.unauthenticated:
          return loc == AppRoutes.login ? null : AppRoutes.login;
        case AuthStatus.unauthorized:
          return loc == AppRoutes.unauthorized ? null : AppRoutes.unauthorized;
        case AuthStatus.authenticated:
          final onPublicPage = loc == AppRoutes.login ||
              loc == AppRoutes.splash ||
              loc == AppRoutes.unauthorized;
          return onPublicPage ? AppRoutes.dashboard : null;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.unauthorized,
        builder: (context, state) => const UnauthorizedPage(),
      ),
      // Everything below is admin-only and shown inside the sidebar shell.
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          _section(AppRoutes.dashboard, const DashboardPage()),
          _section(
            '/orders',
            BlocProvider(
              create: (_) => OrdersCubit(OrderService()),
              child: const OrdersPage(),
            ),
          ),
          _section(
            '/products',
            const SectionPlaceholder(
              title: 'Products',
              icon: Icons.shopping_basket_outlined,
              description: 'Add, edit and manage grocery products here.',
            ),
          ),
          _section(
            '/categories',
            const SectionPlaceholder(
              title: 'Categories',
              icon: Icons.category_outlined,
              description: 'Manage product categories here.',
            ),
          ),
          _section(
            '/inventory',
            const SectionPlaceholder(
              title: 'Inventory',
              icon: Icons.inventory_outlined,
              description: 'Track stock levels and low-stock items here.',
            ),
          ),
          _section(
            '/customers',
            const SectionPlaceholder(
              title: 'Customers',
              icon: Icons.people_outline,
              description: 'View customers and their order history here.',
            ),
          ),
          _section(
            '/delivery',
            const SectionPlaceholder(
              title: 'Delivery Partners',
              icon: Icons.delivery_dining_outlined,
              description: 'Manage riders and delivery assignments here.',
            ),
          ),
          _section(
            '/reports',
            const SectionPlaceholder(
              title: 'Reports',
              icon: Icons.bar_chart_outlined,
              description: 'Sales and order reports will appear here.',
            ),
          ),
          _section(
            '/settings',
            const SectionPlaceholder(
              title: 'Settings',
              icon: Icons.settings_outlined,
              description: 'Store settings will appear here.',
            ),
          ),
        ],
      ),
    ],
  );
}
