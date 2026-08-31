import 'package:go_router/go_router.dart';

import '/../features/dashboard/dashboard_page.dart';
import '/../features/transactions/transactions_page.dart';
import '/../features/budgets/budgets_page.dart';
import '/../features/analytics/analytics_page.dart';
import '/../features/goals/goals_page.dart';
import '/../features/settings/settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionsPage(),
    ),
    GoRoute(
      path: '/budgets',
      builder: (context, state) => const BudgetsPage(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsPage(),
    ),
    GoRoute(
      path: '/goals',
      builder: (context, state) => const GoalsPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
